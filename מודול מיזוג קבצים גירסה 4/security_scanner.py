import os
import re
import json
import subprocess
import logging
import datetime
import hashlib
from typing import Dict, List, Any, Tuple, Optional, Set

class SecurityScanner:
    """סורק אבטחה למאחד קוד חכם Pro 2.0"""
    
    def __init__(self):
        self.initialized = False
        self.config = {}
        self.reports_dir = ""
        self.logger = logging.getLogger(__name__)
        
        # בדיקת כלים זמינים
        self.tools_available = {
            'bandit': self._check_tool_available('bandit'),
            'safety': self._check_tool_available('safety'),
            'eslint': self._check_tool_available('eslint'),
            'npm_audit': self._check_tool_available('npm')
        }
    
    def initialize(self, config: Dict[str, Any]) -> bool:
        """אתחול סורק האבטחה"""
        self.config = config
        
        # קביעת תיקיית דוחות
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.reports_dir = os.path.join(base_dir, config.get("report_path", "security_reports"))
        
        # יצירת תיקיית דוחות אם לא קיימת
        if not os.path.exists(self.reports_dir):
            os.makedirs(self.reports_dir, exist_ok=True)
        
        # הגדרת רמת סריקה
        self.scan_level = config.get("scan_level", "medium")
        
        # הגדרת תבניות להחרגה
        self.excluded_patterns = config.get("excluded_patterns", ["node_modules", "venv", "__pycache__", ".git"])
        
        # יצירת מסד נתוני פגיעויות אם צריך
        self.vulnerability_db = {}
        if config.get("vulnerability_db_update", True):
            self._update_vulnerability_db()
        
        self.initialized = True
        self.logger.info("סורק האבטחה אותחל בהצלחה")
        
        return True
    
    def shutdown(self) -> bool:
        """כיבוי סורק האבטחה"""
        self.initialized = False
        self.logger.info("סורק האבטחה כובה בהצלחה")
        
        return True
    
    def scan_file(self, file_path: str) -> Dict[str, Any]:
        """סריקת קובץ בודד"""
        if not self.initialized:
            self.logger.error("סורק האבטחה לא אותחל")
            return {"error": "סורק האבטחה לא אותחל"}
        
        try:
            # זיהוי סוג הקובץ
            file_type = self._identify_file_type(file_path)
            
            # תוצאות בסיסיות
            results = {
                "file_path": file_path,
                "file_type": file_type,
                "vulnerabilities": [],
                "scan_time": datetime.datetime.now().isoformat()
            }
            
            # סריקה לפי סוג הקובץ
            if file_type == "python":
                self._scan_python_file(file_path, results)
            elif file_type in ["javascript", "typescript"]:
                self._scan_js_file(file_path, results)
            elif file_type == "html":
                self._scan_html_file(file_path, results)
            elif file_type == "css":
                self._scan_css_file(file_path, results)
            elif file_type in ["java", "kotlin"]:
                self._scan_java_file(file_path, results)
            elif file_type in ["c", "cpp"]:
                self._scan_c_file(file_path, results)
                
            # סריקה כללית עבור כל סוגי הקבצים
            self._scan_general_issues(file_path, results)
            
            # חישוב רמת סיכון כוללת
            results["risk_level"] = self._calculate_risk_level(results["vulnerabilities"])
            
            return results
            
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת קובץ {file_path}: {str(e)}")
            return {
                "file_path": file_path,
                "error": str(e),
                "vulnerabilities": [],
                "risk_level": "unknown"
            }
    
    def scan_directory(self, directory_path: str) -> Dict[str, Any]:
        """סריקת תיקייה שלמה"""
        if not self.initialized:
            self.logger.error("סורק האבטחה לא אותחל")
            return {"error": "סורק האבטחה לא אותחל"}
        
        try:
            # בדיקת קיום תיקייה
            if not os.path.isdir(directory_path):
                self.logger.error(f"התיקייה {directory_path} לא קיימת")
                return {"error": f"התיקייה {directory_path} לא קיימת"}
            
            # תוצאות בסיסיות
            results = {
                "directory_path": directory_path,
                "files_scanned": 0,
                "vulnerabilities_found": 0,
                "risk_summary": {
                    "critical": 0,
                    "high": 0,
                    "medium": 0,
                    "low": 0,
                    "info": 0
                },
                "vulnerable_files": [],
                "scan_time": datetime.datetime.now().isoformat(),
                "tools_used": []
            }
            
            # זיהוי כלים זמינים
            if self.tools_available['bandit']:
                results["tools_used"].append("bandit")
            if self.tools_available['safety']:
                results["tools_used"].append("safety")
            if self.tools_available['eslint']:
                results["tools_used"].append("eslint")
            if self.tools_available['npm_audit']:
                results["tools_used"].append("npm_audit")
            
            # בדיקה אם יש קבצי תלויות שדורשים סריקה מיוחדת
            self._scan_dependency_files(directory_path, results)
            
            # סריקת קבצים
            for root, dirs, files in os.walk(directory_path):
                # פילטור תיקיות מוחרגות
                dirs[:] = [d for d in dirs if not any(re.match(pattern, d) for pattern in self.excluded_patterns)]
                
                for file in files:
                    file_path = os.path.join(root, file)
                    
                    # דילוג על קבצים מוחרגים
                    if any(re.search(pattern, file_path) for pattern in self.excluded_patterns):
                        continue
                    
                    # סריקת הקובץ
                    file_results = self.scan_file(file_path)
                    results["files_scanned"] += 1
                    
                    # אם נמצאו פגיעויות, הוספה לרשימה
                    if file_results.get("vulnerabilities"):
                        vulnerabilities = file_results["vulnerabilities"]
                        results["vulnerabilities_found"] += len(vulnerabilities)
                        
                        # עדכון סיכום רמות סיכון
                        for vuln in vulnerabilities:
                            severity = vuln.get("severity", "info").lower()
                            if severity in results["risk_summary"]:
                                results["risk_summary"][severity] += 1
                        
                        # הוספה לרשימת קבצים פגיעים
                        results["vulnerable_files"].append({
                            "file_path": file_path,
                            "risk_level": file_results.get("risk_level", "unknown"),
                            "vulnerabilities_count": len(vulnerabilities)
                        })
            
            # מיון קבצים פגיעים לפי רמת סיכון
            results["vulnerable_files"].sort(
                key=lambda x: {"critical": 4, "high": 3, "medium": 2, "low": 1, "info": 0, "unknown": -1}
                .get(x["risk_level"], -1),
                reverse=True
            )
            
            # חישוב רמת סיכון כוללת
            results["overall_risk_level"] = self._calculate_overall_risk(results["risk_summary"])
            
            # שמירת דוח
            report_path = self._save_report(results)
            results["report_path"] = report_path
            
            self.logger.info(f"סריקת תיקייה {directory_path} הסתיימה: מצאו {results['vulnerabilities_found']} פגיעויות ב-{len(results['vulnerable_files'])} קבצים.")
            
            return results
            
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת תיקייה {directory_path}: {str(e)}")
            return {
                "directory_path": directory_path,
                "error": str(e),
                "vulnerabilities_found": 0,
                "vulnerable_files": []
            }
    
    def scan_project(self, project_dir: str, project_name: str) -> Dict[str, Any]:
        """סריקת אבטחה מקיפה לפרויקט שלם"""
        if not self.initialized:
            self.logger.error("סורק האבטחה לא אותחל")
            return {"error": "סורק האבטחה לא אותחל"}
        
        try:
            # תוצאות בסיסיות
            results = {
                "project_name": project_name,
                "project_dir": project_dir,
                "scan_time": datetime.datetime.now().isoformat(),
                "directory_scan": None,
                "dependencies_scan": {
                    "python": None,
                    "javascript": None,
                    "java": None
                },
                "secrets_scan": None,
                "code_quality_scan": None
            }
            
            # סריקת תיקייה בסיסית
            directory_results = self.scan_directory(project_dir)
            results["directory_scan"] = directory_results
            
            # סריקת תלויות פייתון
            if os.path.exists(os.path.join(project_dir, "requirements.txt")):
                python_deps_results = self._scan_python_dependencies(project_dir)
                results["dependencies_scan"]["python"] = python_deps_results
            
            # סריקת תלויות JavaScript
            if os.path.exists(os.path.join(project_dir, "package.json")):
                js_deps_results = self._scan_js_dependencies(project_dir)
                results["dependencies_scan"]["javascript"] = js_deps_results
            
            # סריקת סודות
            secrets_results = self._scan_for_secrets(project_dir)
            results["secrets_scan"] = secrets_results
            
            # סריקת איכות קוד
            code_quality_results = self._scan_code_quality(project_dir)
            results["code_quality_scan"] = code_quality_results
            
            # חישוב ציון אבטחה כולל
            results["security_score"] = self._calculate_security_score(results)
            
            # שמירת דוח מלא
            report_path = self._save_report(results, f"project_{project_name}_security_scan")
            results["report_path"] = report_path
            
            self.logger.info(f"סריקת אבטחה לפרויקט {project_name} הסתיימה. ציון אבטחה: {results['security_score']}/100")
            
            return results
            
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת פרויקט {project_name}: {str(e)}")
            return {
                "project_name": project_name,
                "project_dir": project_dir,
                "error": str(e)
            }
    
    def _identify_file_type(self, file_path: str) -> str:
        """זיהוי סוג הקובץ לפי סיומת ותוכן"""
        ext = os.path.splitext(file_path)[1].lower()
        
        # זיהוי לפי סיומת
        if ext == '.py':
            return "python"
        elif ext in ['.js', '.jsx']:
            return "javascript"
        elif ext in ['.ts', '.tsx']:
            return "typescript"
        elif ext in ['.html', '.htm']:
            return "html"
        elif ext == '.css':
            return "css"
        elif ext in ['.java']:
            return "java"
        elif ext in ['.kt']:
            return "kotlin"
        elif ext in ['.c', '.h']:
            return "c"
        elif ext in ['.cpp', '.hpp']:
            return "cpp"
        elif ext in ['.rb']:
            return "ruby"
        elif ext in ['.go']:
            return "go"
        elif ext in ['.php']:
            return "php"
        elif ext in ['.cs']:
            return "csharp"
        
        # בדיקת תוכן הקובץ אם הסיומת לא מספיקה
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(4096)  # קריאת 4KB ראשונים
                
                # זיהוי לפי תוכן
                if '#!/usr/bin/env python' in content or '#!/usr/bin/python' in content:
                    return "python"
                elif '<?php' in content:
                    return "php"
                elif '<html' in content:
                    return "html"
                elif 'import React' in content or 'export default' in content:
                    return "javascript"
                elif 'public class' in content or 'package ' in content:
                    return "java"
        except:
            pass
        
        # ברירת מחדל - סוג לא ידוע
        return "unknown"
    
    def _scan_python_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ פייתון"""
        # 1. סריקת בעיות אבטחה נפוצות
        self._scan_python_security_issues(file_path, results)
        
        # 2. הרצת Bandit אם זמין
        if self.tools_available['bandit']:
            self._run_bandit_scan(file_path, results)
    
    def _scan_js_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ JavaScript/TypeScript"""
        # 1. סריקת בעיות אבטחה נפוצות
        self._scan_js_security_issues(file_path, results)
        
        # 2. הרצת ESLint אם זמין
        if self.tools_available['eslint']:
            self._run_eslint_scan(file_path, results)
    
    def _scan_html_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ HTML"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש תגים מסוכנים
            dangerous_patterns = [
                (r'<script\s+src\s*=\s*["\'](http:|https:)?\/\/[^"\']+["\']', "חיצוני script תג", "medium"),
                (r'<script\s+src\s*=\s*["\'](http:|https:)?\/\/[^"\']+["\']', "תג script חיצוני", "medium"),
                (r'javascript:\s*[\w\.]+\(.*\)', "פעולת JavaScript מסוכנת", "high"),
                (r'eval\s*\(', "שימוש ב-eval", "high"),
                (r'document\.write\s*\(', "שימוש ב-document.write", "medium"),
                (r'innerHTML\s*=', "שימוש ב-innerHTML", "medium"),
                (r'localStorage\.setItem', "שימוש ב-localStorage ללא בדיקה", "low"),
                (r'sessionStorage\.setItem', "שימוש ב-sessionStorage ללא בדיקה", "low"),
                (r'ondblclick|onclick|onload|onerror|onmouseover', "שימוש באירועי JavaScript מובנים", "low"),
                (r'http-equiv\s*=\s*["\']refresh["\']', "הפניה אוטומטית", "low")
            ]
            
            # בדיקת כל התבניות המסוכנות
            for pattern, description, severity in dangerous_patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "html_security_issue"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת קובץ HTML {file_path}: {str(e)}")
    
    def _scan_css_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ CSS"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש דפוסים מסוכנים
            dangerous_patterns = [
                (r'@import\s+["\']http', "ייבוא חיצוני עם HTTP", "medium"),
                (r'url\s*\(\s*["\']?http:', "שימוש ב-URL עם HTTP", "low"),
                (r'expression\s*\(', "שימוש ב-expression", "medium"),
                (r'behavior\s*:', "שימוש במאפיין behavior", "medium")
            ]
            
            # בדיקת כל התבניות המסוכנות
            for pattern, description, severity in dangerous_patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "css_security_issue"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת קובץ CSS {file_path}: {str(e)}")
    
    def _scan_java_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ Java/Kotlin"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש דפוסים מסוכנים
            dangerous_patterns = [
                (r'Runtime\.getRuntime\(\)\.exec\(', "הרצת פקודות מערכת", "high"),
                (r'ProcessBuilder', "בנייה והרצת תהליכים", "medium"),
                (r'System\.exit', "יציאה מאולצת מהתוכנית", "low"),
                (r'\.printStackTrace\(\)', "הדפסת מידע על שגיאות", "low"),
                (r'Class\.forName\(', "טעינה דינמית של מחלקות", "medium"),
                (r'java\.sql\.Statement', "שימוש ב-Statement ללא PreparedStatement", "high"),
                (r'java\.util\.Random', "שימוש בגנרטור אקראיות לא מאובטח", "medium"),
                (r'setSecurityManager\(null\)', "ביטול מנהל האבטחה", "high")
            ]
            
            # בדיקת כל התבניות המסוכנות
            for pattern, description, severity in dangerous_patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "java_security_issue"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת קובץ Java {file_path}: {str(e)}")
    
    def _scan_c_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ C/C++"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש פונקציות מסוכנות
            dangerous_functions = [
                (r'\bstrcpy\s*\(', "שימוש ב-strcpy (עדיף strncpy)", "high"),
                (r'\bstrcat\s*\(', "שימוש ב-strcat (עדיף strncat)", "high"),
                (r'\bsprintf\s*\(', "שימוש ב-sprintf (עדיף snprintf)", "high"),
                (r'\bgets\s*\(', "שימוש ב-gets (פונקציה לא בטוחה)", "critical"),
                (r'\breturn\s+[^;]*;', "ערך חזרה פוטנציאלי לא מאותחל", "medium"),
                (r'\bmalloc\s*\([^)]*\)[^;=]*;', "הקצאת זיכרון ללא בדיקת NULL", "medium"),
                (r'\bfree\s*\([^)]*\);\s*[^=]*\1', "שימוש בזיכרון לאחר שחרור (use-after-free)", "critical"),
                (r'\bsystem\s*\(', "הרצת פקודות מערכת", "high"),
                (r'\brealloc\s*\([^,]+,[^)]+\)[^;=]*;', "שימוש ב-realloc ללא בדיקת הערך המוחזר", "high")
            ]
            
            # בדיקת כל הפונקציות המסוכנות
            for pattern, description, severity in dangerous_functions:
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "c_security_issue"
                    })
            
            # בדיקת דליפות זיכרון פוטנציאליות
            if 'malloc' in content or 'calloc' in content:
                malloc_count = len(re.findall(r'\bmalloc\s*\(|\bcalloc\s*\(', content))
                free_count = len(re.findall(r'\bfree\s*\(', content))
                
                if malloc_count > free_count:
                    results["vulnerabilities"].append({
                        "severity": "medium",
                        "description": f"יתכן שיש דליפת זיכרון: {malloc_count} הקצאות אך רק {free_count} שחרורים",
                        "line": 0,
                        "code": "",
                        "type": "memory_leak"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת קובץ C/C++ {file_path}: {str(e)}")
    
    def _scan_general_issues(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת בעיות כלליות בכל סוגי הקבצים"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש מידע רגיש
            sensitive_patterns = [
                (r'(?:password|passwd|pwd)\s*=\s*["\'][^"\']+["\']', "סיסמה בטקסט", "high"),
                (r'(?:api[_-]?key|api[_-]?token|access[_-]?token|secret[_-]?key)\s*=\s*["\'][^"\']{10,}["\']', "מפתח API בטקסט", "high"),
                (r'(?:aws|amazon)[_-]?(?:access[_-]?key|secret[_-]?key)[_-]?id\s*=\s*["\'][^"\']+["\']', "מפתח AWS בטקסט", "critical"),
                (r'github[_-]?token\s*=\s*["\'][^"\']+["\']', "מפתח GitHub בטקסט", "high"),
                (r'-----BEGIN\s+(?:RSA|DSA|EC|OPENSSH|PGP|PRIVATE)\s+KEY-----', "מפתח פרטי בקובץ", "critical"),
                (r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+', "כתובת דוא\"ל בטקסט", "low"),
                (r'(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)', "כתובת IP בטקסט", "low")
            ]
            
            # בדיקת כל התבניות הרגישות
            for pattern, description, severity in sensitive_patterns:
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # מסתיר את הערך הרגיש בתצוגה
                    matched_text = match.group(0)
                    censored_text = self._censor_sensitive_data(matched_text)
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": censored_text,
                        "type": "sensitive_data"
                    })
            
            # חיפוש הערות DEBUG/TODO
            debug_patterns = [
                (r'(?://|#|<!--|/\*)\s*(?:TODO|FIXME|XXX|BUG|HACK):', "הערת פיתוח שלא טופלה", "info"),
                (r'console\.log\(|print\(|System\.out\.print|printf\(|puts\(', "הדפסות דיבאג", "low"),
                (r'(?://|#|<!--|/\*)\s*DEBUG', "קוד דיבאג שלא נמחק", "low")
            ]
            
            # בדיקת כל תבניות הדיבאג
            for pattern, description, severity in debug_patterns:
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "development_artifact"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת בעיות כלליות בקובץ {file_path}: {str(e)}")
    
    def _scan_python_security_issues(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת בעיות אבטחה נפוצות בפייתון"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש דפוסים מסוכנים
            dangerous_patterns = [
                (r'eval\s*\(', "שימוש ב-eval", "high"),
                (r'exec\s*\(', "שימוש ב-exec", "high"),
                (r'(?:import|from)\s+os(?:\s+import)?\s+(?:system|popen|execl|execle|execlp|execlpe|execv|execve|execvp|execvpe)', "ייבוא פונקציות מסוכנות מ-os", "high"),
                (r'os\.(?:system|popen|execl|execle|execlp|execlpe|execv|execve|execvp|execvpe)\s*\(', "הרצת פקודות מערכת", "high"),
                (r'subprocess\.(?:call|Popen|run|check_output)\s*\((?:[^)]*,\s*shell\s*=\s*True|[^),]*\))', "שימוש ב-subprocess עם shell=True", "high"),
                (r'pickle\.loads?\s*\(', "שימוש ב-pickle על נתונים לא אמינים", "high"),
                (r'django\.db\.models\.CharField\(.*,\s*max_length\s*=', "שדה CharField עם max_length גדול מדי", "low"),
                (r'\.objects\.raw\s*\(', "שימוש ב-raw SQL בלי הגנה", "high"),
                (r'(?:request|req)\.(?:GET|POST)\[\s*[\'"][^\'"]+[\'"]\s*\]', "גישה ישירה לפרמטרי בקשה", "medium"),
                (r'open\s*\(\s*(?!r)[^,]*,\s*["\']\w+["\']\s*\)', "פתיחת קבצים ללא הגנה", "medium"),
                (r'random\.\w+\s*\(', "שימוש במודול random לקריפטוגרפיה", "low")
            ]
            
            # בדיקת כל התבניות המסוכנות
            for pattern, description, severity in dangerous_patterns:
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "python_security_issue"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת בעיות אבטחה בפייתון {file_path}: {str(e)}")
    
    def _scan_js_security_issues(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת בעיות אבטחה נפוצות ב-JavaScript"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # חיפוש דפוסים מסוכנים
            dangerous_patterns = [
                (r'eval\s*\(', "שימוש ב-eval", "high"),
                (r'(?:setTimeout|setInterval)\s*\(\s*["\'](.*?)["\']', "שימוש במחרוזות עם setTimeout/setInterval", "medium"),
                (r'(?:localStorage|sessionStorage)\.setItem\s*\(', "שימוש בlocal/sessionStorage ללא תיקוף", "low"),
                (r'document\.domain\s*=', "שינוי ה-domain של המסמך", "high"),
                (r'document\.write\s*\(', "שימוש ב-document.write", "medium"),
                (r'document\.execCommand\s*\(', "שימוש ב-execCommand", "medium"),
                (r'(?:\w+)\.innerHTML\s*=', "הגדרת innerHTML ללא תיקוף", "high"),
                (r'location\.href\s*=|location\.replace\s*\(', "שינוי location ללא תיקוף", "medium"),
                (r'new\s+Function\s*\(', "יצירת פונקציה דינמית", "high"),
                (r'Object\.assign\s*\((?:[^,]*,\s*(?:req|request)\.body|(?:req|request)\.body\s*,)', "העתקת פרמטרי בקשה ללא תיקוף", "high"),
                (r'(?:encodeURI|encodeURIComponent)\s*\(', "שימוש בקידוד URL", "low"),
                (r'fetch\s*\(\s*(?:\'|\")?\$\{', "שימוש בטמפלייט סטרינג ב-fetch", "high")
            ]
            
            # בדיקת כל התבניות המסוכנות
            for pattern, description, severity in dangerous_patterns:
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    # מציאת מספר שורה
                    line_number = content[:match.start()].count('\n') + 1
                    
                    # הוספת פגיעות
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": description,
                        "line": line_number,
                        "code": match.group(0),
                        "type": "javascript_security_issue"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת בעיות אבטחה ב-JavaScript {file_path}: {str(e)}")
    
    def _run_bandit_scan(self, file_path: str, results: Dict[str, Any]) -> None:
        """הרצת סריקת bandit על קובץ פייתון"""
        try:
            # הגדרת פקודת הרצה
            cmd = ['bandit', '-f', 'json', '-q', file_path]
            
            # הרצת הפקודה
            process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            if process.returncode == 0 and process.stdout:
                # פענוח תוצאות ה-JSON
                try:
                    bandit_results = json.loads(process.stdout)
                    
                    # הוספת ממצאים
                    if 'results' in bandit_results and bandit_results['results']:
                        for issue in bandit_results['results']:
                            severity = "medium"  # ברירת מחדל
                            
                            # המרת חומרת Bandit לפורמט שלנו
                            if issue.get('issue_severity') == 'HIGH':
                                severity = "high"
                            elif issue.get('issue_severity') == 'LOW':
                                severity = "low"
                            
                            results["vulnerabilities"].append({
                                "severity": severity,
                                "description": issue.get('issue_text', 'בעיית אבטחה שזוהתה על ידי Bandit'),
                                "line": issue.get('line_number', 0),
                                "code": issue.get('code', ''),
                                "type": "bandit_finding",
                                "cwe": issue.get('cwe', None),
                                "confidence": issue.get('issue_confidence', 'MEDIUM')
                            })
                except:
                    self.logger.error(f"שגיאה בפענוח תוצאות Bandit: {process.stdout}")
        
        except Exception as e:
            self.logger.error(f"שגיאה בהרצת Bandit על {file_path}: {str(e)}")
    
    def _run_eslint_scan(self, file_path: str, results: Dict[str, Any]) -> None:
        """הרצת סריקת eslint על קובץ JavaScript"""
        try:
            # הגדרת פקודת הרצה
            cmd = ['eslint', '--format', 'json', '--no-eslintrc', '--rule', 'security/detect-eval-with-expression:2', file_path]
            
            # הרצת הפקודה
            process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            if process.returncode != 0 and process.stdout:
                # פענוח תוצאות ה-JSON
                try:
                    eslint_results = json.loads(process.stdout)
                    
                    # הוספת ממצאים
                    for file_result in eslint_results:
                        if 'messages' in file_result:
                            for issue in file_result['messages']:
                                severity = "low"  # ברירת מחדל
                                
                                # המרת חומרת ESLint לפורמט שלנו
                                if issue.get('severity') == 2:
                                    severity = "medium"
                                if 'security' in issue.get('ruleId', ''):
                                    severity = "high"
                                
                                results["vulnerabilities"].append({
                                    "severity": severity,
                                    "description": issue.get('message', 'בעיית אבטחה שזוהתה על ידי ESLint'),
                                    "line": issue.get('line', 0),
                                    "code": '',  # אין קוד בפלט של ESLint
                                    "type": "eslint_finding",
                                    "rule": issue.get('ruleId', None)
                                })
                except:
                    self.logger.error(f"שגיאה בפענוח תוצאות ESLint: {process.stdout}")
        
        except Exception as e:
            self.logger.error(f"שגיאה בהרצת ESLint על {file_path}: {str(e)}")
    
    def _scan_dependency_files(self, directory_path: str, results: Dict[str, Any]) -> None:
        """סריקת קבצי תלויות"""
        # בדיקת קובץ requirements.txt (פייתון)
        requirements_path = os.path.join(directory_path, "requirements.txt")
        if os.path.exists(requirements_path):
            self._scan_python_dependencies_file(requirements_path, results)
        
        # בדיקת קובץ package.json (JavaScript/Node.js)
        package_json_path = os.path.join(directory_path, "package.json")
        if os.path.exists(package_json_path):
            self._scan_js_dependencies_file(package_json_path, results)
        
        # בדיקת קובץ pom.xml (Java/Maven)
        pom_xml_path = os.path.join(directory_path, "pom.xml")
        if os.path.exists(pom_xml_path):
            self._scan_java_dependencies_file(pom_xml_path, results)
    
    def _scan_python_dependencies_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ requirements.txt"""
        if not self.tools_available['safety']:
            return
            
        try:
            # הרצת פקודת safety
            cmd = ['safety', 'check', '--file', file_path, '--json']
            
            # הרצת הפקודה
            process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            if process.returncode != 0 and process.stdout:
                # פענוח תוצאות ה-JSON
                try:
                    safety_results = json.loads(process.stdout)
                    
                    # הוספת ממצאים
                    for issue in safety_results.get('vulnerabilities', []):
                        severity = "medium"  # ברירת מחדל
                        
                        # המרת רמת חומרה
                        if 'severity' in issue:
                            if issue['severity'] in ['high', 'critical']:
                                severity = issue['severity']
                            elif issue['severity'] == 'low':
                                severity = 'low'
                        
                        results["vulnerabilities"].append({
                            "severity": severity,
                            "description": f"תלות פגועה: {issue.get('package_name')} {issue.get('vulnerable_spec')}",
                            "line": 0,
                            "code": f"{issue.get('package_name')}=={issue.get('installed_version')}",
                            "type": "dependency_vulnerability",
                            "advisory": issue.get('advisory', None),
                            "vulnerability_id": issue.get('vulnerability_id', None)
                        })
                except:
                    self.logger.error(f"שגיאה בפענוח תוצאות Safety: {process.stdout}")
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת תלויות פייתון {file_path}: {str(e)}")
    
    def _scan_js_dependencies_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ package.json"""
        if not self.tools_available['npm_audit']:
            return
            
        try:
            # שינוי הספרייה הנוכחית לספריית הפרויקט
            original_dir = os.getcwd()
            project_dir = os.path.dirname(file_path)
            os.chdir(project_dir)
            
            # הרצת פקודת npm audit
            cmd = ['npm', 'audit', '--json']
            
            # הרצת הפקודה
            process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # חזרה לספרייה המקורית
            os.chdir(original_dir)
            
            if process.stdout:
                # פענוח תוצאות ה-JSON
                try:
                    npm_results = json.loads(process.stdout)
                    
                    # הוספת ממצאים
                    for advisory_id, advisory in npm_results.get('advisories', {}).items():
                        severity = "medium"  # ברירת מחדל
                        
                        # המרת רמת חומרה
                        if 'severity' in advisory:
                            if advisory['severity'] in ['high', 'critical']:
                                severity = advisory['severity']
                            elif advisory['severity'] == 'low':
                                severity = 'low'
                        
                        results["vulnerabilities"].append({
                            "severity": severity,
                            "description": f"תלות JavaScript פגועה: {advisory.get('module_name')} - {advisory.get('title')}",
                            "line": 0,
                            "code": f"{advisory.get('module_name')}@{advisory.get('vulnerable_versions')}",
                            "type": "dependency_vulnerability",
                            "advisory_url": advisory.get('url', None),
                            "cwe": advisory.get('cwe', None),
                            "vulnerability_id": advisory_id
                        })
                except:
                    self.logger.error(f"שגיאה בפענוח תוצאות npm audit: {process.stdout}")
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת תלויות JavaScript {file_path}: {str(e)}")
    
    def _scan_java_dependencies_file(self, file_path: str, results: Dict[str, Any]) -> None:
        """סריקת קובץ pom.xml"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # בדיקה של גרסאות ספריות ידועות כפגיעות
            vulnerable_dependencies = [
                (r'<groupId>org\.apache\.struts</groupId>\s*<artifactId>struts2-core</artifactId>\s*<version>[0-2]\.3\.[0-9]+(?:\.[0-9]+)?</version>', 'Apache Struts 2 < 2.3.x', 'high'),
                (r'<groupId>commons-collections</groupId>\s*<artifactId>commons-collections</artifactId>\s*<version>[1-3]\.2\.1</version>', 'Apache Commons Collections <= 3.2.1', 'high'),
                (r'<groupId>log4j</groupId>\s*<artifactId>log4j</artifactId>\s*<version>1\.', 'Log4j 1.x (EOL, recommend Log4j 2.x)', 'medium'),
                (r'<groupId>org\.apache\.logging\.log4j</groupId>\s*<artifactId>log4j-core</artifactId>\s*<version>2\.[0-9]\.(?:1[0-6]|[0-9])</version>', 'Log4j 2 < 2.17.0 (Log4Shell)', 'critical'),
                (r'<groupId>org\.springframework</groupId>\s*<artifactId>spring-core</artifactId>\s*<version>[0-4]\.', 'Spring Framework < 5.0', 'medium'),
                (r'<groupId>com\.fasterxml\.jackson\.core</groupId>\s*<artifactId>jackson-databind</artifactId>\s*<version>2\.(?:[0-6]|7\.0|7\.1|7\.2|7\.3|7\.4|7\.5|7\.6|7\.7|7\.8|8\.0|8\.1|8\.2|8\.3|8\.4|8\.5|8\.6|8\.7|8\.8|8\.9|9\.0|9\.1|9\.2)</version>', 'Jackson Databind < 2.9.3', 'high')
            ]
            
            # בדיקת כל תלות פגיעה
            for pattern, description, severity in vulnerable_dependencies:
                matches = re.search(pattern, content, re.MULTILINE | re.DOTALL)
                
                if matches:
                    # חילוץ מידע על הגרסה
                    version_match = re.search(r'<version>(.*?)</version>', matches.group(0))
                    version = version_match.group(1) if version_match else "unknown"
                    
                    # חילוץ מידע על הספרייה
                    artifact_match = re.search(r'<artifactId>(.*?)</artifactId>', matches.group(0))
                    artifact = artifact_match.group(1) if artifact_match else "unknown"
                    
                    results["vulnerabilities"].append({
                        "severity": severity,
                        "description": f"תלות Java פגיעה: {description}",
                        "line": 0,
                        "code": f"{artifact}:{version}",
                        "type": "java_dependency_vulnerability"
                    })
        
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת תלויות Java {file_path}: {str(e)}")
    
    def _scan_python_dependencies(self, project_dir: str) -> Dict[str, Any]:
        """סריקת תלויות פייתון"""
        results = {
            "dependencies_scanned": 0,
            "vulnerabilities_found": 0,
            "vulnerable_dependencies": []
        }
        
        requirements_path = os.path.join(project_dir, "requirements.txt")
        if os.path.exists(requirements_path) and self.tools_available['safety']:
            try:
                # הרצת פקודת safety
                cmd = ['safety', 'check', '--file', requirements_path, '--json']
                
                # הרצת הפקודה
                process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                
                if process.stdout:
                    # פענוח תוצאות ה-JSON
                    try:
                        safety_results = json.loads(process.stdout)
                        
                        # עדכון תוצאות
                        results["dependencies_scanned"] = safety_results.get('packages_checked', 0)
                        results["vulnerabilities_found"] = len(safety_results.get('vulnerabilities', []))
                        
                        # הוספת פירוט על תלויות פגיעות
                        for issue in safety_results.get('vulnerabilities', []):
                            results["vulnerable_dependencies"].append({
                                "name": issue.get('package_name'),
                                "installed_version": issue.get('installed_version'),
                                "vulnerable_spec": issue.get('vulnerable_spec'),
                                "description": issue.get('advisory', ''),
                                "severity": issue.get('severity', 'medium'),
                                "vulnerability_id": issue.get('vulnerability_id', None)
                            })
                    except:
                        self.logger.error(f"שגיאה בפענוח תוצאות Safety: {process.stdout}")
            except Exception as e:
                self.logger.error(f"שגיאה בסריקת תלויות פייתון: {str(e)}")
        
        return results
    
    def _scan_js_dependencies(self, project_dir: str) -> Dict[str, Any]:
        """סריקת תלויות JavaScript"""
        results = {
            "dependencies_scanned": 0,
            "vulnerabilities_found": 0,
            "vulnerable_dependencies": []
        }
        
        package_json_path = os.path.join(project_dir, "package.json")
        if os.path.exists(package_json_path) and self.tools_available['npm_audit']:
            try:
                # שינוי הספרייה הנוכחית לספריית הפרויקט
                original_dir = os.getcwd()
                os.chdir(project_dir)
                
                # הרצת פקודת npm audit
                cmd = ['npm', 'audit', '--json']
                
                # הרצת הפקודה
                process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                
                # חזרה לספרייה המקורית
                os.chdir(original_dir)
                
                if process.stdout:
                    # פענוח תוצאות ה-JSON
                    try:
                        npm_results = json.loads(process.stdout)
                        
                        # עדכון תוצאות
                        results["dependencies_scanned"] = npm_results.get('metadata', {}).get('totalDependencies', 0)
                        results["vulnerabilities_found"] = len(npm_results.get('advisories', {}))
                        
                        # הוספת פירוט על תלויות פגיעות
                        for advisory_id, advisory in npm_results.get('advisories', {}).items():
                            results["vulnerable_dependencies"].append({
                                "name": advisory.get('module_name'),
                                "installed_version": advisory.get('findings', [{}])[0].get('version', 'unknown'),
                                "vulnerable_versions": advisory.get('vulnerable_versions'),
                                "description": advisory.get('title', ''),
                                "severity": advisory.get('severity', 'medium'),
                                "advisory_url": advisory.get('url', None),
                                "cwe": advisory.get('cwe', None),
                                "vulnerability_id": advisory_id
                            })
                    except:
                        self.logger.error(f"שגיאה בפענוח תוצאות npm audit: {process.stdout}")
            except Exception as e:
                self.logger.error(f"שגיאה בסריקת תלויות JavaScript: {str(e)}")
        
        return results
    
    def _scan_for_secrets(self, directory_path: str) -> Dict[str, Any]:
        """סריקת סודות בקבצים שונים"""
        results = {
            "files_scanned": 0,
            "secrets_found": 0,
            "secrets": []
        }
        
        # דפוסים לגילוי סודות
        secret_patterns = [
            (r'(?:password|passwd|pwd)\s*=\s*["\'][^"\']{8,}["\']', "סיסמה אפשרית", "high"),
            (r'(?:api[_-]?key|api[_-]?token|access[_-]?token|secret[_-]?key)\s*=\s*["\'][^"\']{16,}["\']', "מפתח API אפשרי", "high"),
            (r'(?:aws|amazon)[_-]?(?:access[_-]?key|secret[_-]?key)[_-]?id\s*=\s*["\'][A-Za-z0-9/\+]{16,}["\']', "מפתח AWS", "high"),
            (r'(?:BEGIN|END)\s+(?:RSA|DSA|EC|OPENSSH|PGP)\s+(?:PRIVATE|PUBLIC)\s+KEY', "מפתח קריפטוגרפי", "high"),
            (r'github_token\s*=\s*["\'](?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,255}["\']', "GitHub Token", "high"),
            (r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*', "Bearer token", "medium"),
            (r'eyJ[A-Za-z0-9\-_]+\.eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+', "JWT אפשרי", "medium")
        ]
        
        # סריקת כל הקבצים בתיקייה
        for root, dirs, files in os.walk(directory_path):
            # פילטור תיקיות מוחרגות
            dirs[:] = [d for d in dirs if not any(re.match(pattern, d) for pattern in self.excluded_patterns)]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                # דילוג על קבצים בינאריים
                if self._is_binary_file(file_path):
                    continue
                
                # דילוג על קבצים מוחרגים
                if any(re.search(pattern, file_path) for pattern in self.excluded_patterns):
                    continue
                
                results["files_scanned"] += 1
                
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    
                    # בדיקת כל הדפוסים
                    for pattern, description, severity in secret_patterns:
                        matches = re.finditer(pattern, content)
                        
                        for match in matches:
                            # מציאת מספר שורה
                            line_number = content[:match.start()].count('\n') + 1
                            
                            # מסתיר את הערך הרגיש בתצוגה
                            matched_text = match.group(0)
                            censored_text = self._censor_sensitive_data(matched_text)
                            
                            # הוספת סוד שנמצא
                            results["secrets"].append({
                                "file_path": file_path,
                                "line": line_number,
                                "type": description,
                                "severity": severity,
                                "value_preview": censored_text
                            })
                            
                            results["secrets_found"] += 1
                
                except Exception as e:
                    self.logger.error(f"שגיאה בסריקת סודות בקובץ {file_path}: {str(e)}")
        
        return results
    
    def _scan_code_quality(self, directory_path: str) -> Dict[str, Any]:
        """סריקת איכות קוד כללית"""
        results = {
            "files_scanned": 0,
            "issues_found": 0,
            "issues_by_category": {
                "complexity": 0,
                "duplication": 0,
                "style": 0,
                "documentation": 0,
                "bugs": 0
            },
            "issues": []
        }
        
        # פילטור קבצי קוד בלבד
        code_extensions = {
            '.py', '.js', '.ts', '.jsx', '.tsx',
            '.java', '.kt', '.c', '.cpp', '.cs',
            '.go', '.rb', '.php', '.swift', '.scala'
        }
        
        # סריקת כל הקבצים בתיקייה
        for root, dirs, files in os.walk(directory_path):
            # פילטור תיקיות מוחרגות
            dirs[:] = [d for d in dirs if not any(re.match(pattern, d) for pattern in self.excluded_patterns)]
            
            for file in files:
                file_path = os.path.join(root, file)
                ext = os.path.splitext(file_path)[1].lower()
                
                # דילוג על קבצים שאינם קוד
                if ext not in code_extensions:
                    continue
                
                # דילוג על קבצים מוחרגים
                if any(re.search(pattern, file_path) for pattern in self.excluded_patterns):
                    continue
                
                results["files_scanned"] += 1
                
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        lines = content.split('\n')
                    
                    # 1. בדיקת אורך שורות מופרז
                    for i, line in enumerate(lines):
                        if len(line.strip()) > 120:
                            results["issues"].append({
                                "file_path": file_path,
                                "line": i + 1,
                                "type": "style",
                                "description": "שורה ארוכה מדי (מעל 120 תווים)",
                                "severity": "low"
                            })
                            results["issues_found"] += 1
                            results["issues_by_category"]["style"] += 1
                    
                    # 2. בדיקת פונקציות ארוכות מדי
                    if ext == '.py':
                        self._check_python_function_length(file_path, content, results)
                    elif ext in ['.js', '.ts', '.jsx', '.tsx']:
                        self._check_js_function_length(file_path, content, results)
                    
                    # 3. בדיקת תיעוד בקוד
                    if len(lines) > 20:  # רק בקבצים גדולים מספיק
                        # ספירת שורות תיעוד
                        comment_lines = 0
                        for line in lines:
                            line = line.strip()
                            if re.match(r'^[\s]*(#|//|/\*|\*|"""|\'\'\').*', line):
                                comment_lines += 1
                        
                        # אם יש פחות מדי תיעוד
                        comment_ratio = comment_lines / len(lines)
                        if comment_ratio < 0.05:  # פחות מ-5% תיעוד
                            results["issues"].append({
                                "file_path": file_path,
                                "line": 0,
                                "type": "documentation",
                                "description": f"מעט מדי תיעוד בקובץ (רק {comment_ratio:.1%} מהשורות)",
                                "severity": "low"
                            })
                            results["issues_found"] += 1
                            results["issues_by_category"]["documentation"] += 1
                
                except Exception as e:
                    self.logger.error(f"שגיאה בסריקת איכות קוד בקובץ {file_path}: {str(e)}")
        
        # בדיקת שכפול קוד (במידה ויש מספיק קבצים)
        if results["files_scanned"] > 5:
            self._check_code_duplication(directory_path, results)
        
        return results
    
    def _check_python_function_length(self, file_path: str, content: str, results: Dict[str, Any]) -> None:
        """בדיקת אורך פונקציות פייתון"""
        # חיפוש פונקציות
        function_matches = re.finditer(r'def\s+(\w+)\s*\([^)]*\):', content)
        
        for match in function_matches:
            # מציאת גוף הפונקציה
            function_name = match.group(1)
            function_start = match.end()
            
            # מיקום תחילת הפונקציה
            line_number = content[:function_start].count('\n') + 1
            
            # חיפוש גוף הפונקציה
            lines = content[function_start:].split('\n')
            
            # ספירת שורות הפונקציה
            function_lines = 0
            indentation = None
            
            for i, line in enumerate(lines):
                if i == 0:
                    # קביעת רמת ההזחה של הפונקציה
                    match_indent = re.match(r'^(\s+)', lines[i + 1] if i + 1 < len(lines) else '')
                    if match_indent:
                        indentation = len(match_indent.group(1))
                    else:
                        break
                    
                    function_lines += 1
                    continue
                
                if not line.strip():
                    # דילוג על שורות ריקות
                    continue
                
                # בדיקה אם השורה היא חלק מהפונקציה
                match_line_indent = re.match(r'^(\s+)', line)
                if not match_line_indent or len(match_line_indent.group(1)) < indentation:
                    # סיום הפונקציה
                    break
                
                function_lines += 1
            
            # אם הפונקציה ארוכה מדי
            if function_lines > 50:
                results["issues"].append({
                    "file_path": file_path,
                    "line": line_number,
                    "type": "complexity",
                    "description": f"פונקציה ארוכה מדי: {function_name} ({function_lines} שורות)",
                    "severity": "medium"
                })
                results["issues_found"] += 1
                results["issues_by_category"]["complexity"] += 1
    
    def _check_js_function_length(self, file_path: str, content: str, results: Dict[str, Any]) -> None:
        """בדיקת אורך פונקציות JavaScript"""
        # חיפוש פונקציות (הגדרות רגילות וחצים)
        function_patterns = [
            r'function\s+(\w+)\s*\([^)]*\)\s*{',
            r'(?:const|let|var)\s+(\w+)\s*=\s*function\s*\([^)]*\)\s*{',
            r'(?:const|let|var)\s+(\w+)\s*=\s*\([^)]*\)\s*=>\s*{'
        ]
        
        for pattern in function_patterns:
            function_matches = re.finditer(pattern, content)
            
            for match in function_matches:
                # מציאת שם הפונקציה
                function_name = match.group(1)
                function_start = match.end()
                
                # מיקום תחילת הפונקציה
                line_number = content[:function_start].count('\n') + 1
                
                # ספירת מאזנים של סוגריים מסולסלים
                braces_balance = 1
                pos = function_start
                function_end = function_start
                
                # חיפוש סוף הפונקציה
                while braces_balance > 0 and pos < len(content):
                    if content[pos] == '{':
                        braces_balance += 1
                    elif content[pos] == '}':
                        braces_balance -= 1
                    
                    pos += 1
                    
                    if braces_balance == 0:
                        function_end = pos
                
                # חישוב מספר שורות
                function_lines = content[function_start:function_end].count('\n')
                
                # אם הפונקציה ארוכה מדי
                if function_lines > 50:
                    results["issues"].append({
                        "file_path": file_path,
                        "line": line_number,
                        "type": "complexity",
                        "description": f"פונקציה ארוכה מדי: {function_name} ({function_lines} שורות)",
                        "severity": "medium"
                    })
                    results["issues_found"] += 1
                    results["issues_by_category"]["complexity"] += 1
    
    def _check_code_duplication(self, directory_path: str, results: Dict[str, Any]) -> None:
        """בדיקת שכפול קוד בפרויקט"""
        # יצירת "טביעות אצבע" של קטעי קוד
        code_fingerprints = {}
        
        # סריקת כל הקבצים בתיקייה
        for root, dirs, files in os.walk(directory_path):
            # פילטור תיקיות מוחרגות
            dirs[:] = [d for d in dirs if not any(re.match(pattern, d) for pattern in self.excluded_patterns)]
            
            for file in files:
                file_path = os.path.join(root, file)
                ext = os.path.splitext(file_path)[1].lower()
                
                # רק קבצי קוד
                if ext not in ['.py', '.js', '.ts', '.java', '.kt', '.c', '.cpp', '.cs']:
                    continue
                
                # דילוג על קבצים מוחרגים
                if any(re.search(pattern, file_path) for pattern in self.excluded_patterns):
                    continue
                
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    
                    # חלוקה לבלוקים באורך 6 שורות
                    lines = content.split('\n')
                    
                    # יצירת חתימות לבלוקים
                    for i in range(len(lines) - 5):
                        # כל בלוק הוא 6 שורות
                        block = '\n'.join(lines[i:i+6])
                        
                        # דילוג על בלוקים קצרים מדי
                        if len(block.strip()) < 100:
                            continue
                        
                        # חישוב חתימה
                        fingerprint = hashlib.md5(block.encode('utf-8')).hexdigest()
                        
                        # שמירת מיקום הבלוק
                        if fingerprint not in code_fingerprints:
                            code_fingerprints[fingerprint] = []
                        
                        code_fingerprints[fingerprint].append((file_path, i + 1))
                    
                except Exception as e:
                    self.logger.error(f"שגיאה בבדיקת שכפול קוד בקובץ {file_path}: {str(e)}")
        
        # בדיקת בלוקים שמופיעים יותר מפעם אחת
        for fingerprint, locations in code_fingerprints.items():
            if len(locations) > 1:
                # נמצא שכפול
                
                # בדיקה שהשכפול אינו באותו קובץ
                unique_files = set(loc[0] for loc in locations)
                if len(unique_files) > 1:
                    # תיאור בסיסי של המיקומים
                    duplicates_desc = ', '.join(f"{os.path.basename(loc[0])}:{loc[1]}" for loc in locations[:3])
                    if len(locations) > 3:
                        duplicates_desc += f" ועוד {len(locations) - 3} מקומות"
                    
                    results["issues"].append({
                        "file_path": locations[0][0],
                        "line": locations[0][1],
                        "type": "duplication",
                        "description": f"נמצא קוד משוכפל ב: {duplicates_desc}",
                        "severity": "medium"
                    })
                    results["issues_found"] += 1
                    results["issues_by_category"]["duplication"] += 1
    
    def _calculate_risk_level(self, vulnerabilities: List[Dict[str, Any]]) -> str:
        """חישוב רמת סיכון כוללת על סמך רשימת פגיעויות"""
        if not vulnerabilities:
            return "low"
        
        # ספירת סוגי הפגיעות לפי חומרה
        severity_counts = {
            "critical": 0,
            "high": 0,
            "medium": 0,
            "low": 0,
            "info": 0
        }
        
        for vuln in vulnerabilities:
            severity = vuln.get("severity", "info").lower()
            if severity in severity_counts:
                severity_counts[severity] += 1
        
        # חישוב רמת הסיכון
        if severity_counts["critical"] > 0:
            return "critical"
        elif severity_counts["high"] > 0:
            return "high"
        elif severity_counts["medium"] > 0:
            return "medium"
        elif severity_counts["low"] > 0:
            return "low"
        else:
            return "info"
    
    def _calculate_overall_risk(self, risk_summary: Dict[str, int]) -> str:
        """חישוב רמת סיכון כוללת לפרויקט"""
        # לוגיקה פשוטה: החומרה הגבוהה ביותר עם נוכחות משמעותית
        if risk_summary.get("critical", 0) > 0:
            return "critical"
        elif risk_summary.get("high", 0) > 2:
            return "high"
        elif risk_summary.get("high", 0) > 0 or risk_summary.get("medium", 0) > 5:
            return "medium"
        elif risk_summary.get("medium", 0) > 0 or risk_summary.get("low", 0) > 10:
            return "low"
        else:
            return "info"
    
    def _calculate_security_score(self, results: Dict[str, Any]) -> int:
        """חישוב ציון אבטחה (0-100) לפרויקט"""
        # נקודת פתיחה
        score = 100
        
        # הורדת נקודות עבור פגיעויות בסריקת תיקייה
        if "directory_scan" in results and results["directory_scan"]:
            dir_scan = results["directory_scan"]
            
            # הורדה לפי רמת סיכון כוללת
            risk_level = dir_scan.get("overall_risk_level", "info")
            if risk_level == "critical":
                score -= 40
            elif risk_level == "high":
                score -= 30
            elif risk_level == "medium":
                score -= 15
            elif risk_level == "low":
                score -= 5
            
            # הורדה נוספת לפי כמות הפגיעויות
            vulnerabilities_count = dir_scan.get("vulnerabilities_found", 0)
            score -= min(20, vulnerabilities_count // 2)  # מקסימום 20 נקודות
        
        # הורדת נקודות עבור פגיעויות בתלויות
        dep_scan_python = results.get("dependencies_scan", {}).get("python", {})
        dep_scan_js = results.get("dependencies_scan", {}).get("javascript", {})
        
        python_vulns = dep_scan_python.get("vulnerabilities_found", 0)
        js_vulns = dep_scan_js.get("vulnerabilities_found", 0)
        
        score -= min(15, (python_vulns + js_vulns) // 2)  # מקסימום 15 נקודות
        
        # הורדת נקודות עבור סודות
        secrets_scan = results.get("secrets_scan", {})
        secrets_count = secrets_scan.get("secrets_found", 0)
        
        if secrets_count > 0:
            score -= min(25, secrets_count * 5)  # מקסימום 25 נקודות
        
        # הורדת נקודות עבור בעיות איכות קוד
        code_quality = results.get("code_quality_scan", {})
        quality_issues = code_quality.get("issues_found", 0)
        
        score -= min(10, quality_issues // 5)  # מקסימום 10 נקודות
        
        # הגבלת הציון לטווח 0-100
        return max(0, min(100, score))
    
    def _save_report(self, results: Dict[str, Any], report_name: Optional[str] = None) -> str:
        """שמירת דוח סריקה לקובץ JSON"""
        if not report_name:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            report_name = f"security_scan_{timestamp}"
        
        report_path = os.path.join(self.reports_dir, f"{report_name}.json")
        
        try:
            with open(report_path, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2, default=str)
            
            self.logger.info(f"דוח סריקה נשמר: {report_path}")
            return report_path
        
        except Exception as e:
            self.logger.error(f"שגיאה בשמירת דוח סריקה: {str(e)}")
            return ""
    
    def _censor_sensitive_data(self, text: str) -> str:
        """הסתרת מידע רגיש"""
        # חיפוש הערך הרגיש במחרוזת
        match = re.search(r'[\'"]([^\'"]+)[\'"]', text)
        
        if match:
            sensitive_value = match.group(1)
            
            # הסתרת חלק מהערך
            if len(sensitive_value) <= 8:
                censored = '*' * len(sensitive_value)
            else:
                # הצגת תווים ראשונים ואחרונים, הסתרת האמצע
                visible_chars = min(3, len(sensitive_value) // 4)
                censored = sensitive_value[:visible_chars] + '*' * (len(sensitive_value) - 2 * visible_chars) + sensitive_value[-visible_chars:]
            
            # החלפת הערך הרגיש בערך המוסתר
            return text.replace(sensitive_value, censored)
        
        return text
    
    def _update_vulnerability_db(self) -> None:
        """עדכון מסד נתוני פגיעויות"""
        # יצירת תיקייה למסד נתונים
        db_dir = os.path.join(self.reports_dir, "vulnerability_db")
        os.makedirs(db_dir, exist_ok=True)
        
        # שמירת המיקום
        self.vulnerability_db_path = os.path.join(db_dir, "vulnerabilities.json")
        
        # עדכון באמצעות Safety אם זמין
        if self.tools_available['safety']:
            try:
                # הרצת הפקודה
                cmd = ['safety', 'check', '--json']
                
                process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                
                if process.returncode != 0 and process.stdout:
                    # פענוח תוצאות ה-JSON
                    safety_data = json.loads(process.stdout)
                    
                    # שמירת נתוני הפגיעויות לקובץ
                    with open(self.vulnerability_db_path, 'w', encoding='utf-8') as f:
                        json.dump(safety_data, f, ensure_ascii=False, indent=2)
                    
                    self.logger.info(f"מסד נתוני פגיעויות עודכן")
            except Exception as e:
                self.logger.error(f"שגיאה בעדכון מסד נתוני פגיעויות: {str(e)}")
    
    def _check_tool_available(self, tool_name: str) -> bool:
        """בדיקה אם כלי מסוים זמין במערכת"""
        tool_commands = {
            'bandit': ['bandit', '--version'],
            'safety': ['safety', '--version'],
            'eslint': ['eslint', '--version'],
            'npm': ['npm', '--version']
        }
        
        if tool_name not in tool_commands:
            return False
            
        try:
            result = subprocess.run(
                tool_commands[tool_name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            return result.returncode == 0
        except:
            return False
    
    def _is_binary_file(self, file_path: str) -> bool:
        """בדיקה אם קובץ הוא בינארי"""
        try:
            with open(file_path, 'tr', encoding='utf-8') as f:
                f.read(1024)
            return False
        except:
            return True