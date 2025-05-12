import os
import sys
import json
import subprocess
import tempfile
import threading
import logging
import time
import signal
import hashlib
from typing import Dict, List, Any, Optional, Tuple, Union
import traceback

class CodeRunner:
    """מודול הרצת קוד למאחד קוד חכם Pro 2.0"""
    
    def __init__(self):
        self.initialized = False
        self.config = {}
        self.logger = logging.getLogger(__name__)
        self.sandbox_dir = None
        self.languages_config = {}
        self.running_processes = {}
    
    def initialize(self, config: Dict[str, Any]) -> bool:
        """אתחול מריץ הקוד"""
        self.config = config
        
        # הגדרת תיקיית הסאנדבוקס
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.sandbox_dir = os.path.join(base_dir, "sandboxes")
        
        # יצירת תיקייה אם לא קיימת
        os.makedirs(self.sandbox_dir, exist_ok=True)
        
        # הגדרות הרצה
        self.timeout_seconds = config.get("timeout_seconds", 30)
        self.memory_limit_mb = config.get("memory_limit_mb", 512)
        self.sandbox_enabled = config.get("sandbox_enabled", True)
        
        # טעינת קונפיגורציה של שפות תכנות
        self._load_languages_config()
        
        # רשימת שפות נתמכות
        self.supported_languages = config.get("supported_languages", ["python", "javascript", "bash"])
        
        # בדיקת תמיכה בשפות
        for lang in self.supported_languages:
            if lang not in self.languages_config:
                self.logger.warning(f"שפה לא מוגדרת: {lang}, לא תהיה תמיכה בהרצת קוד בשפה זו")
        
        # דגל אתחול
        self.initialized = True
        self.logger.info("מריץ הקוד אותחל בהצלחה")
        
        return True
    
    def shutdown(self) -> bool:
        """כיבוי מריץ הקוד"""
        try:
            # עצירת כל התהליכים הרצים
            for pid in list(self.running_processes.keys()):
                self._kill_process(pid)
            
            self.initialized = False
            self.logger.info("מריץ הקוד כובה בהצלחה")
            return True
        except Exception as e:
            self.logger.error(f"שגיאה בכיבוי מריץ הקוד: {str(e)}")
            return False
    
    def run_file(self, file_path: str, parameters: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        הרצת קוד מקובץ
        
        Args:
            file_path: נתיב לקובץ
            parameters: פרמטרים להרצה
            
        Returns:
            Dict[str, Any]: תוצאות ההרצה
        """
        if not self.initialized:
            self.logger.error("מריץ הקוד לא אותחל")
            return {"status": "error", "error": "מריץ הקוד לא אותחל"}
        
        try:
            # יצירת מזהה הרצה
            run_id = self._generate_run_id(file_path)
            
            # זיהוי שפת התכנות
            language = self._detect_language(file_path)
            
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "file_path": file_path,
                    "language": language
                }
            
            # הכנת סביבת הרצה (סאנדבוקס)
            sandbox_path = self._prepare_sandbox(run_id, file_path, language, parameters)
            
            # הרצת הקוד
            run_results = self._execute_code(sandbox_path, language, parameters)
            run_results["language"] = language
            run_results["file_path"] = file_path
            run_results["run_id"] = run_id
            
            # ניקוי סביבת ההרצה (אם נדרש)
            if self.config.get("cleanup_after_run", True):
                self._cleanup_sandbox(sandbox_path)
            
            return run_results
            
        except Exception as e:
            self.logger.error(f"שגיאה בהרצת קובץ {file_path}: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "file_path": file_path,
                "traceback": traceback.format_exc()
            }
    
    def run_code_snippet(self, code: str, language: str, parameters: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        הרצת קטע קוד ללא קובץ
        
        Args:
            code: קטע הקוד להרצה
            language: שפת התכנות
            parameters: פרמטרים להרצה
            
        Returns:
            Dict[str, Any]: תוצאות ההרצה
        """
        if not self.initialized:
            self.logger.error("מריץ הקוד לא אותחל")
            return {"status": "error", "error": "מריץ הקוד לא אותחל"}
        
        try:
            # בדיקת תמיכה בשפה
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "language": language
                }
            
            # יצירת מזהה הרצה
            run_id = self._generate_run_id_for_snippet(code, language)
            
            # יצירת קובץ זמני עם הקוד
            temp_dir = tempfile.mkdtemp(prefix="code_snippet_", dir=self.sandbox_dir)
            
            # קביעת שם קובץ על פי השפה
            file_ext = self.languages_config[language].get("extension", ".txt")
            temp_file_path = os.path.join(temp_dir, f"snippet{file_ext}")
            
            # כתיבת הקוד לקובץ
            with open(temp_file_path, 'w', encoding='utf-8') as f:
                f.write(code)
            
            # הרצת הקובץ
            run_results = self.run_file(temp_file_path, parameters)
            
            # הוספת מידע נוסף לתוצאות
            run_results["language"] = language
            run_results["code_snippet"] = code[:100] + ("..." if len(code) > 100 else "")
            
            # ניקוי הקובץ הזמני
            if self.config.get("cleanup_after_run", True):
                try:
                    os.remove(temp_file_path)
                    os.rmdir(temp_dir)
                except:
                    pass
            
            return run_results
            
        except Exception as e:
            self.logger.error(f"שגיאה בהרצת קטע קוד: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "language": language,
                "traceback": traceback.format_exc()
            }
    
    def stop_execution(self, run_id: str) -> bool:
        """
        עצירת הרצת קוד
        
        Args:
            run_id: מזהה ההרצה לעצירה
            
        Returns:
            bool: האם העצירה הצליחה
        """
        if not self.initialized:
            self.logger.error("מריץ הקוד לא אותחל")
            return False
        
        try:
            # חיפוש התהליך לפי מזהה הרצה
            for pid, process_info in list(self.running_processes.items()):
                if process_info.get("run_id") == run_id:
                    # עצירת התהליך
                    self._kill_process(pid)
                    self.logger.info(f"הרצת קוד {run_id} נעצרה בהצלחה")
                    return True
            
            self.logger.warning(f"הרצת קוד {run_id} לא נמצאה או כבר הסתיימה")
            return False
            
        except Exception as e:
            self.logger.error(f"שגיאה בעצירת הרצת קוד {run_id}: {str(e)}")
            return False
    
    def get_run_status(self, run_id: str) -> Dict[str, Any]:
        """
        קבלת סטטוס הרצה
        
        Args:
            run_id: מזהה ההרצה
            
        Returns:
            Dict[str, Any]: סטטוס ההרצה
        """
        if not self.initialized:
            self.logger.error("מריץ הקוד לא אותחל")
            return {"status": "error", "error": "מריץ הקוד לא אותחל"}
        
        try:
            # חיפוש התהליך לפי מזהה הרצה
            for pid, process_info in self.running_processes.items():
                if process_info.get("run_id") == run_id:
                    # בדיקת סטטוס התהליך
                    status = process_info.get("status", "unknown")
                    return {
                        "status": status,
                        "pid": pid,
                        "run_id": run_id,
                        "start_time": process_info.get("start_time"),
                        "language": process_info.get("language"),
                        "sandbox_path": process_info.get("sandbox_path")
                    }
            
            # אם לא נמצא בתהליכים הרצים, אולי הסתיים
            run_log_path = os.path.join(self.sandbox_dir, f"{run_id}_results.json")
            if os.path.exists(run_log_path):
                try:
                    with open(run_log_path, 'r', encoding='utf-8') as f:
                        results = json.load(f)
                    return {
                        "status": "completed",
                        "run_id": run_id,
                        "results": results
                    }
                except:
                    pass
            
            return {
                "status": "unknown",
                "run_id": run_id,
                "error": "הרצה לא נמצאה"
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בקבלת סטטוס הרצה {run_id}: {str(e)}")
            return {
                "status": "error",
                "error": str(e),
                "run_id": run_id
            }
    
    def _detect_language(self, file_path: str) -> str:
        """
        זיהוי שפת תכנות לפי סיומת קובץ
        
        Args:
            file_path: נתיב לקובץ
            
        Returns:
            str: שפת התכנות
        """
        # בדיקה לפי סיומת קובץ
        ext = os.path.splitext(file_path)[1].lower()
        
        # מיפוי סיומות לשפות
        ext_to_lang = {
            '.py': 'python',
            '.js': 'javascript',
            '.html': 'html',
            '.sh': 'bash',
            '.css': 'css',
            '.java': 'java',
            '.c': 'c',
            '.cpp': 'cpp',
            '.cs': 'csharp',
            '.rb': 'ruby',
            '.php': 'php',
            '.go': 'go',
            '.rs': 'rust',
            '.ts': 'typescript',
            '.jsx': 'javascript',
            '.tsx': 'typescript'
        }
        
        # בדיקה על פי המיפוי
        if ext in ext_to_lang:
            return ext_to_lang[ext]
        
        # בדיקת תוכן הקובץ אם הסיומת לא נמצאה
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(1024)  # קריאת התחלת הקובץ
            
            # חיפוש מאפיינים של שפות שונות
            if '#!/usr/bin/env python' in content or '#!/usr/bin/python' in content:
                return 'python'
            elif '#!/usr/bin/env node' in content or '#!/usr/bin/node' in content:
                return 'javascript'
            elif '#!/bin/bash' in content or '#!/usr/bin/env bash' in content:
                return 'bash'
            
        except:
            pass
        
        # ברירת מחדל: לא ידוע
        return 'unknown'
    
    def _load_languages_config(self) -> None:
        """טעינת קונפיגורציה של שפות תכנות"""
        # קונפיגורציה בסיסית לשפות
        self.languages_config = {
            "python": {
                "command": "python",
                "extension": ".py",
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["python", "--version"]
            },
            "javascript": {
                "command": "node",
                "extension": ".js",
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["node", "--version"]
            },
            "bash": {
                "command": "bash",
                "extension": ".sh",
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["bash", "--version"]
            },
            "java": {
                "command": "java",
                "extension": ".java",
                "compile_command": "javac",
                "compile_args": [],
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["java", "--version"]
            },
            "c": {
                "command": "./a.out",
                "extension": ".c",
                "compile_command": "gcc",
                "compile_args": ["-o", "a.out"],
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["gcc", "--version"]
            },
            "cpp": {
                "command": "./a.out",
                "extension": ".cpp",
                "compile_command": "g++",
                "compile_args": ["-o", "a.out"],
                "args": [],
                "env": {},
                "file_position": "{file}",
                "version_command": ["g++", "--version"]
            }
        }
        
        # איתור קובץ קונפיגורציה של שפות
        config_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        languages_config_path = os.path.join(config_dir, 'languages_config.json')
        
        # טעינת קונפיגורציה מותאמת אם קיימת
        if os.path.exists(languages_config_path):
            try:
                with open(languages_config_path, 'r', encoding='utf-8') as f:
                    custom_config = json.load(f)
                
                # מיזוג עם הקונפיגורציה הקיימת
                for lang, config in custom_config.items():
                    if lang in self.languages_config:
                        # עדכון הגדרות קיימות
                        self.languages_config[lang].update(config)
                    else:
                        # הוספת שפה חדשה
                        self.languages_config[lang] = config
            
            except Exception as e:
                self.logger.error(f"שגיאה בטעינת קונפיגורציית שפות: {str(e)}")
    
    def _prepare_sandbox(self, run_id: str, file_path: str, language: str, parameters: Optional[Dict[str, Any]]) -> str:
        """
        הכנת סביבת הרצה מבודדת (סאנדבוקס)
        
        Args:
            run_id: מזהה הרצה
            file_path: נתיב לקובץ
            language: שפת התכנות
            parameters: פרמטרים להרצה
            
        Returns:
            str: נתיב לסאנדבוקס
        """
        # יצירת תיקייה לסאנדבוקס
        sandbox_path = os.path.join(self.sandbox_dir, f"sandbox_{run_id}")
        os.makedirs(sandbox_path, exist_ok=True)
        
        # העתקת הקובץ לסאנדבוקס
        file_name = os.path.basename(file_path)
        sandbox_file_path = os.path.join(sandbox_path, file_name)
        
        shutil.copy2(file_path, sandbox_file_path)
        
        # העתקת קבצים נלווים (אם צוין)
        if parameters and 'related_files' in parameters:
            for related_file in parameters['related_files']:
                if os.path.exists(related_file):
                    rel_file_name = os.path.basename(related_file)
                    shutil.copy2(related_file, os.path.join(sandbox_path, rel_file_name))
        
        # הכנת קובץ הגדרות להרצה
        config_file_path = os.path.join(sandbox_path, "run_config.json")
        
        run_config = {
            "run_id": run_id,
            "language": language,
            "file_path": file_name,
            "parameters": parameters or {},
            "timeout_seconds": self.timeout_seconds,
            "memory_limit_mb": self.memory_limit_mb,
            "created_at": time.time()
        }
        
        with open(config_file_path, 'w', encoding='utf-8') as f:
            json.dump(run_config, f, ensure_ascii=False, indent=2)
        
        return sandbox_path
    
    def _execute_code(self, sandbox_path: str, language: str, parameters: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """
        הרצת קוד בסאנדבוקס
        
        Args:
            sandbox_path: נתיב לסאנדבוקס
            language: שפת התכנות
            parameters: פרמטרים להרצה
            
        Returns:
            Dict[str, Any]: תוצאות ההרצה
        """
        # קריאת הגדרות ההרצה
        config_file_path = os.path.join(sandbox_path, "run_config.json")
        
        with open(config_file_path, 'r', encoding='utf-8') as f:
            run_config = json.load(f)
        
        run_id = run_config["run_id"]
        file_name = run_config["file_path"]
        file_path = os.path.join(sandbox_path, file_name)
        
        # הכנת לוגים
        stdout_path = os.path.join(sandbox_path, "stdout.log")
        stderr_path = os.path.join(sandbox_path, "stderr.log")
        
        # הכנת פקודת הרצה
        if language not in self.languages_config:
            return {
                "status": "error",
                "error": f"שפה לא נתמכת: {language}"
            }
        
        lang_config = self.languages_config[language]
        
        # בדיקה אם נדרש קומפילציה
        if "compile_command" in lang_config:
            # ביצוע קומפילציה
            compilation_result = self._compile_code(sandbox_path, file_path, language)
            
            if compilation_result.get("status") != "success":
                return compilation_result
        
        # הכנת פקודת הרצה
        command = lang_config["command"]
        args = lang_config.get("args", [])
        
        # החלפת תבניות בארגומנטים
        full_command = [command]
        
        # הוספת ארגומנטים
        for arg in args:
            arg = arg.replace("{file}", file_path)
            full_command.append(arg)
        
        # הוספת נתיב הקובץ (אם נדרש)
        file_position = lang_config.get("file_position", "{file}")
        if file_position == "{file}":
            full_command.append(file_path)
        
        # הגדרת משתני סביבה
        env = os.environ.copy()
        
        if lang_config.get("env"):
            env.update(lang_config["env"])
        
        # הוספת פרמטרים מותאמים
        if parameters and "command_args" in parameters:
            for arg in parameters["command_args"]:
                full_command.append(arg)
        
        # הגבלת משתמשים (לינוקס בלבד)
        limiters = []
        
        # הרצת הקוד
        try:
            # פתיחת קבצי לוג
            stdout_file = open(stdout_path, 'w', encoding='utf-8')
            stderr_file = open(stderr_path, 'w', encoding='utf-8')
            
            # תיעוד תחילת הרצה
            self.logger.info(f"מתחיל הרצת קוד {run_id} בשפה {language}: {' '.join(full_command)}")
            
            # תחילת מדידת זמן
            start_time = time.time()
            
            # הרצת התהליך
            process = subprocess.Popen(
                full_command,
                stdout=stdout_file,
                stderr=stderr_file,
                cwd=sandbox_path,
                env=env,
                preexec_fn=None  # יש להוסיף מגבלות משאבים בעתיד
            )
            
            # תיעוד תהליך הרצה
            self.running_processes[process.pid] = {
                "run_id": run_id,
                "process": process,
                "status": "running",
                "start_time": start_time,
                "language": language,
                "command": full_command,
                "sandbox_path": sandbox_path
            }
            
            # המתנה לסיום עם timeout
            try:
                process.wait(timeout=self.timeout_seconds)
                exit_code = process.returncode
                status = "completed"
            except subprocess.TimeoutExpired:
                # תהליך תקוע - הריגה
                process.kill()
                process.wait()
                exit_code = -1
                status = "timeout"
            
            # סיום מדידת זמן
            end_time = time.time()
            duration = end_time - start_time
            
            # סגירת קבצי לוג
            stdout_file.close()
            stderr_file.close()
            
            # קריאת הפלט
            with open(stdout_path, 'r', encoding='utf-8', errors='ignore') as f:
                stdout = f.read()
            
            with open(stderr_path, 'r', encoding='utf-8', errors='ignore') as f:
                stderr = f.read()
            
            # עדכון תיעוד תהליך
            self.running_processes[process.pid]["status"] = status
            self.running_processes[process.pid]["end_time"] = end_time
            self.running_processes[process.pid]["duration"] = duration
            self.running_processes[process.pid]["exit_code"] = exit_code
            
            # הכנת תוצאות
            results = {
                "status": "error" if exit_code != 0 else "success",
                "exit_code": exit_code,
                "duration": duration,
                "stdout": stdout,
                "stderr": stderr,
                "run_id": run_id,
            }
            
            # תוספות לפי סטטוס הרצה
            if status == "timeout":
                results["status"] = "timeout"
                results["error"] = f"הרצת הקוד חרגה מהגבלת הזמן ({self.timeout_seconds} שניות)"
            
            # שמירת תוצאות ההרצה
            results_path = os.path.join(sandbox_path, "results.json")
            with open(results_path, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)
            
            # ניקוי
            if process.pid in self.running_processes:
                del self.running_processes[process.pid]
            
            self.logger.info(f"הרצת קוד {run_id} הסתיימה עם קוד יציאה {exit_code} (משך: {duration:.2f}s, סטטוס: {status})")
            
            return results
            
        except Exception as e:
            self.logger.error(f"שגיאה בהרצת קוד {run_id}: {str(e)}")
            
            # שמירת השגיאה
            error_log_path = os.path.join(sandbox_path, "error.log")
            with open(error_log_path, 'w', encoding='utf-8') as f:
                f.write(f"שגיאה בהרצה: {str(e)}\n")
                f.write(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "traceback": traceback.format_exc(),
                "run_id": run_id
            }
    
    def _compile_code(self, sandbox_path: str, file_path: str, language: str) -> Dict[str, Any]:
        """
        קומפילציה של קוד בשפות מהודרות
        
        Args:
            sandbox_path: נתיב לסאנדבוקס
            file_path: נתיב לקובץ
            language: שפת התכנות
            
        Returns:
            Dict[str, Any]: תוצאות הקומפילציה
        """
        lang_config = self.languages_config[language]
        
        if "compile_command" not in lang_config:
            return {"status": "success"}
        
        # הכנת לוגים
        compile_stdout_path = os.path.join(sandbox_path, "compile_stdout.log")
        compile_stderr_path = os.path.join(sandbox_path, "compile_stderr.log")
        
        # הכנת פקודת קומפילציה
        compile_command = lang_config["compile_command"]
        compile_args = lang_config.get("compile_args", [])
        
        # החלפת תבניות בארגומנטים
        full_command = [compile_command]
        
        # הוספת ארגומנטים
        for arg in compile_args:
            arg = arg.replace("{file}", file_path)
            full_command.append(arg)
        
        # הוספת נתיב הקובץ
        if "{file}" not in " ".join(compile_args):
            full_command.append(file_path)
        
        # הגדרת משתני סביבה
        env = os.environ.copy()
        
        if lang_config.get("env"):
            env.update(lang_config["env"])
        
        # ביצוע קומפילציה
        try:
            # פתיחת קבצי לוג
            stdout_file = open(compile_stdout_path, 'w', encoding='utf-8')
            stderr_file = open(compile_stderr_path, 'w', encoding='utf-8')
            
            self.logger.info(f"מבצע קומפילציה בשפה {language}: {' '.join(full_command)}")
            
            # הרצת הקומפילציה
            process = subprocess.Popen(
                full_command,
                stdout=stdout_file,
                stderr=stderr_file,
                cwd=sandbox_path,
                env=env
            )
            
            # המתנה לסיום
            exit_code = process.wait()
            
            # סגירת קבצי לוג
            stdout_file.close()
            stderr_file.close()
            
            # קריאת הפלט
            with open(compile_stdout_path, 'r', encoding='utf-8', errors='ignore') as f:
                stdout = f.read()
            
            with open(compile_stderr_path, 'r', encoding='utf-8', errors='ignore') as f:
                stderr = f.read()
            
            # בדיקת תוצאה
            if exit_code != 0:
                self.logger.error(f"קומפילציה נכשלה עם קוד יציאה {exit_code}")
                
                return {
                    "status": "error",
                    "error": "קומפילציה נכשלה",
                    "exit_code": exit_code,
                    "stdout": stdout,
                    "stderr": stderr
                }
            
            self.logger.info(f"קומפילציה הושלמה בהצלחה")
            
            return {
                "status": "success",
                "exit_code": exit_code,
                "stdout": stdout,
                "stderr": stderr
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בקומפילציה: {str(e)}")
            
            return {
                "status": "error",
                "error": str(e),
                "traceback": traceback.format_exc()
            }
    
    def _cleanup_sandbox(self, sandbox_path: str) -> None:
        """
        ניקוי סביבת הרצה
        
        Args:
            sandbox_path: נתיב לסאנדבוקס
        """
        # שמירת קבצי התוצאות והלוגים
        results_dir = os.path.join(os.path.dirname(sandbox_path), "results")
        os.makedirs(results_dir, exist_ok=True)
        
        # חילוץ מזהה הרצה
        config_file_path = os.path.join(sandbox_path, "run_config.json")
        
        if os.path.exists(config_file_path):
            try:
                with open(config_file_path, 'r', encoding='utf-8') as f:
                    run_config = json.load(f)
                
                run_id = run_config.get("run_id", "unknown")
                
                # העתקת קבצי תוצאות ולוגים
                for file_name in ["results.json", "stdout.log", "stderr.log", "error.log", "run_config.json"]:
                    src_path = os.path.join(sandbox_path, file_name)
                    if os.path.exists(src_path):
                        dst_path = os.path.join(results_dir, f"{run_id}_{file_name}")
                        shutil.copy2(src_path, dst_path)
            except:
                pass
        
        # מחיקת הסאנדבוקס
        try:
            shutil.rmtree(sandbox_path)
        except Exception as e:
            self.logger.error(f"שגיאה בניקוי סאנדבוקס {sandbox_path}: {str(e)}")
    
    def _kill_process(self, pid: int) -> bool:
        """
        הריגת תהליך
        
        Args:
            pid: מזהה התהליך
            
        Returns:
            bool: האם ההריגה הצליחה
        """
        if pid not in self.running_processes:
            return False
        
        process_info = self.running_processes[pid]
        process = process_info.get("process")
        
        if not process:
            return False
        
        try:
            # ניסיון לסיים את התהליך
            process.terminate()
            
            # המתנה לסיום
            try:
                process.wait(timeout=3)
                return True
            except subprocess.TimeoutExpired:
                # התהליך לא הסתיים - הריגה בכוח
                process.kill()
                process.wait()
                return True
            
        except Exception as e:
            self.logger.error(f"שגיאה בהריגת תהליך {pid}: {str(e)}")
            return False
        finally:
            # הסרה מרשימת התהליכים הרצים
            if pid in self.running_processes:
                del self.running_processes[pid]
    
    def _generate_run_id(self, file_path: str) -> str:
        """
        יצירת מזהה הרצה
        
        Args:
            file_path: נתיב לקובץ
            
        Returns:
            str: מזהה הרצה
        """
        file_name = os.path.basename(file_path)
        timestamp = int(time.time())
        random_part = os.urandom(4).hex()
        
        return f"run_{timestamp}_{random_part}_{file_name}"
    
    def _generate_run_id_for_snippet(self, code: str, language: str) -> str:
        """
        יצירת מזהה הרצה לקטע קוד
        
        Args:
            code: קטע הקוד
            language: שפת התכנות
            
        Returns:
            str: מזהה הרצה
        """
        code_hash = hashlib.md5(code.encode('utf-8')).hexdigest()[:8]
        timestamp = int(time.time())
        random_part = os.urandom(4).hex()
        
        return f"run_{timestamp}_{random_part}_{language}_{code_hash}"