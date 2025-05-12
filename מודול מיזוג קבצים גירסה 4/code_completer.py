import os
import re
import json
import logging
import tempfile
import traceback
from typing import Dict, List, Any, Optional, Tuple, Union

class CodeCompleter:
    """מודול השלמת קוד למאחד קוד חכם Pro 2.0"""
    
    def __init__(self):
        self.initialized = False
        self.config = {}
        self.logger = logging.getLogger(__name__)
        self.language_handlers = {}
        self.suggestions_limit = 5
    
    def initialize(self, config: Dict[str, Any]) -> bool:
        """אתחול משלים הקוד"""
        self.config = config
        
        # הגדרות כלליות
        self.suggestions_limit = config.get("suggestions_limit", 5)
        self.context_lines = config.get("context_lines", 10)
        self.supported_languages = config.get("supported_languages", ["python", "javascript", "java", "c", "cpp"])
        
        # אתחול מטפלי שפות
        self._initialize_language_handlers()
        
        # דגל אתחול
        self.initialized = True
        self.logger.info("משלים הקוד אותחל בהצלחה")
        
        return True
    
    def shutdown(self) -> bool:
        """כיבוי משלים הקוד"""
        self.initialized = False
        self.logger.info("משלים הקוד כובה בהצלחה")
        
        return True
    
    def complete_file(self, file_path: str, missing_parts: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        השלמת קוד חסר בקובץ
        
        Args:
            file_path: נתיב לקובץ
            missing_parts: רשימת חלקים חסרים (שורות, פונקציות וכו')
            
        Returns:
            Dict[str, Any]: תוצאות ההשלמה
        """
        if not self.initialized:
            self.logger.error("משלים הקוד לא אותחל")
            return {"status": "error", "error": "משלים הקוד לא אותחל"}
        
        try:
            # זיהוי שפת הקובץ
            language = self._detect_language(file_path)
            
            # בדיקת תמיכה בשפה
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "file_path": file_path,
                    "language": language
                }
            
            # קריאת הקובץ
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                original_content = f.read()
            
            # ליטוש החלקים החסרים (עשוי לשנות משהו)
            refined_missing_parts = self._refine_missing_parts(missing_parts, original_content, language)
            
            # השלמת כל חלק חסר
            completions = []
            
            for part in refined_missing_parts:
                completion = self._complete_part(part, original_content, language)
                completions.append(completion)
            
            # יצירת גרסה משולבת
            merged_content = self._apply_completions(original_content, completions)
            
            # שמירת הקובץ המשולב
            completed_file_path = tempfile.mktemp(suffix=f"_completed{os.path.splitext(file_path)[1]}")
            
            with open(completed_file_path, 'w', encoding='utf-8') as f:
                f.write(merged_content)
            
            self.logger.info(f"הושלמו {len(completions)} חלקים בקובץ {file_path}")
            
            return {
                "status": "success",
                "file_path": file_path,
                "language": language,
                "original_file": file_path,
                "completed_file": completed_file_path,
                "completions": completions,
                "completion_count": len(completions)
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בהשלמת קוד בקובץ {file_path}: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "file_path": file_path,
                "traceback": traceback.format_exc()
            }
    
    def complete_code_snippet(self, code: str, language: str, missing_parts: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        השלמת קטע קוד
        
        Args:
            code: קטע הקוד
            language: שפת התכנות
            missing_parts: רשימת חלקים חסרים
            
        Returns:
            Dict[str, Any]: תוצאות ההשלמה
        """
        if not self.initialized:
            self.logger.error("משלים הקוד לא אותחל")
            return {"status": "error", "error": "משלים הקוד לא אותחל"}
        
        try:
            # בדיקת תמיכה בשפה
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "language": language
                }
            
            # ליטוש החלקים החסרים (עשוי לשנות משהו)
            refined_missing_parts = self._refine_missing_parts(missing_parts, code, language)
            
            # השלמת כל חלק חסר
            completions = []
            
            for part in refined_missing_parts:
                completion = self._complete_part(part, code, language)
                completions.append(completion)
            
            # יצירת גרסה משולבת
            merged_content = self._apply_completions(code, completions)
            
            self.logger.info(f"הושלמו {len(completions)} חלקים בקטע קוד בשפה {language}")
            
            return {
                "status": "success",
                "language": language,
                "original_code": code,
                "completed_code": merged_content,
                "completions": completions,
                "completion_count": len(completions)
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בהשלמת קטע קוד: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "language": language,
                "traceback": traceback.format_exc()
            }
    
    def detect_missing_parts(self, file_path: str) -> Dict[str, Any]:
        """
        זיהוי אוטומטי של חלקי קוד חסרים
        
        Args:
            file_path: נתיב לקובץ
            
        Returns:
            Dict[str, Any]: רשימת חלקים חסרים שזוהו
        """
        if not self.initialized:
            self.logger.error("משלים הקוד לא אותחל")
            return {"status": "error", "error": "משלים הקוד לא אותחל"}
        
        try:
            # זיהוי שפת הקובץ
            language = self._detect_language(file_path)
            
            # בדיקת תמיכה בשפה
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "file_path": file_path,
                    "language": language
                }
            
            # קריאת הקובץ
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # זיהוי חלקים חסרים
            missing_parts = self._detect_missing_code(content, language)
            
            self.logger.info(f"זוהו {len(missing_parts)} חלקים חסרים בקובץ {file_path}")
            
            return {
                "status": "success",
                "file_path": file_path,
                "language": language,
                "missing_parts": missing_parts,
                "missing_count": len(missing_parts)
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בזיהוי חלקים חסרים בקובץ {file_path}: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "file_path": file_path,
                "traceback": traceback.format_exc()
            }
    
    def suggest_completions(self, file_path: str, line: int, column: int) -> Dict[str, Any]:
        """
        הצעת השלמות קוד בנקודה מסוימת
        
        Args:
            file_path: נתיב לקובץ
            line: מספר שורה
            column: מספר עמודה
            
        Returns:
            Dict[str, Any]: הצעות השלמה
        """
        if not self.initialized:
            self.logger.error("משלים הקוד לא אותחל")
            return {"status": "error", "error": "משלים הקוד לא אותחל"}
        
        try:
            # זיהוי שפת הקובץ
            language = self._detect_language(file_path)
            
            # בדיקת תמיכה בשפה
            if language not in self.supported_languages:
                self.logger.error(f"שפה לא נתמכת: {language}")
                return {
                    "status": "error",
                    "error": f"שפה לא נתמכת: {language}",
                    "file_path": file_path,
                    "language": language
                }
            
            # קריאת הקובץ
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.readlines()
            
            # בדיקת תקינות השורה והעמודה
            if line < 1 or line > len(content):
                return {
                    "status": "error",
                    "error": f"מספר שורה לא תקין: {line}",
                    "file_path": file_path
                }
            
            # אינדקס מתחיל מ-0
            line_index = line - 1
            
            # חילוץ קונטקסט
            context_start = max(0, line_index - self.context_lines)
            context_end = min(len(content), line_index + self.context_lines + 1)
            
            context_lines = content[context_start:context_end]
            
            # קריאה למטפל השפה
            handler = self.language_handlers.get(language)
            
            if not handler:
                return {
                    "status": "error",
                    "error": f"אין מטפל לשפה: {language}",
                    "file_path": file_path
                }
            
            # הצעת השלמות
            suggestions = handler.suggest_completions(context_lines, line_index - context_start, column)
            
            # הגבלת מספר ההצעות
            if len(suggestions) > self.suggestions_limit:
                suggestions = suggestions[:self.suggestions_limit]
            
            self.logger.info(f"נמצאו {len(suggestions)} הצעות השלמה בקובץ {file_path} בשורה {line}")
            
            return {
                "status": "success",
                "file_path": file_path,
                "language": language,
                "line": line,
                "column": column,
                "suggestions": suggestions,
                "suggestion_count": len(suggestions)
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בהצעת השלמות קוד בקובץ {file_path}: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "file_path": file_path,
                "traceback": traceback.format_exc()
            }
    
    def _initialize_language_handlers(self) -> None:
        """אתחול מטפלי שפות"""
        # יצירת מטפלים לשפות נתמכות
        self.language_handlers = {
            "python": PythonCodeHandler(),
            "javascript": JavaScriptCodeHandler(),
            "java": JavaCodeHandler(),
            "c": CCodeHandler(),
            "cpp": CppCodeHandler()
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
            '.java': 'java',
            '.c': 'c',
            '.cpp': 'cpp',
            '.h': 'c',
            '.hpp': 'cpp',
            '.jsx': 'javascript',
            '.ts': 'javascript',
            '.tsx': 'javascript'
        }
        
        # בדיקה על פי המיפוי
        if ext in ext_to_lang:
            return ext_to_lang[ext]
        
        # בדיקת תוכן הקובץ אם הסיומת לא נמצאה
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(1024)  # קריאת התחלת הקובץ
            
            # חיפוש מאפיינים של שפות שונות
            if '#!/usr/bin/env python' in content or 'import ' in content or 'def ' in content:
                return 'python'
            elif 'function ' in content or 'var ' in content or 'const ' in content or 'let ' in content:
                return 'javascript'
            elif 'public class' in content or 'import java.' in content:
                return 'java'
            elif '#include <iostream>' in content or 'std::' in content:
                return 'cpp'
            elif '#include <stdio.h>' in content:
                return 'c'
            
        except:
            pass
        
        # ברירת מחדל: לא ידוע
        return 'unknown'
    
    def _refine_missing_parts(self, missing_parts: List[Dict[str, Any]], content: str, language: str) -> List[Dict[str, Any]]:
        """
        ליטוש החלקים החסרים
        
        Args:
            missing_parts: רשימת חלקים חסרים
            content: תוכן הקוד
            language: שפת התכנות
            
        Returns:
            List[Dict[str, Any]]: חלקים חסרים מלוטשים
        """
        # בדיקת תקינות
        if not missing_parts:
            return []
        
        # קריאה למטפל השפה
        handler = self.language_handlers.get(language)
        
        if not handler:
            return missing_parts
        
        # ליטוש באמצעות המטפל
        return handler.refine_missing_parts(missing_parts, content)
    
    def _complete_part(self, part: Dict[str, Any], content: str, language: str) -> Dict[str, Any]:
        """
        השלמת חלק חסר
        
        Args:
            part: חלק חסר
            content: תוכן הקוד
            language: שפת התכנות
            
        Returns:
            Dict[str, Any]: תוצאות ההשלמה
        """
        # קריאה למטפל השפה
        handler = self.language_handlers.get(language)
        
        if not handler:
            # אם אין מטפל ספציפי, ניסיון להשלמה בסיסית
            return self._basic_completion(part, content, language)
        
        # השלמה באמצעות המטפל
        completion = handler.complete_part(part, content)
        
        # הוספת מידע למעקב
        completion["part_type"] = part.get("type", "unknown")
        completion["language"] = language
        
        return completion
    
    def _basic_completion(self, part: Dict[str, Any], content: str, language: str) -> Dict[str, Any]:
        """
        השלמה בסיסית של חלק חסר
        
        Args:
            part: חלק חסר
            content: תוכן הקוד
            language: שפת התכנות
            
        Returns:
            Dict[str, Any]: תוצאות ההשלמה
        """
        # חילוץ מיקום
        start_line = part.get("start_line", 0)
        end_line = part.get("end_line", start_line)
        
        # הכנת קונטקסט
        lines = content.split('\n')
        
        context_start = max(0, start_line - self.context_lines)
        context_end = min(len(lines), end_line + self.context_lines)
        
        before_context = '\n'.join(lines[context_start:start_line])
        after_context = '\n'.join(lines[end_line:context_end])
        
        # ברירת מחדל להשלמה - תגובה ריקה
        completion_text = ""
        
        # התאמה לסוג החלק החסר
        part_type = part.get("type", "")
        part_name = part.get("name", "")
        
        if part_type == "function" and part_name:
            # תבנית בסיסית לפונקציה לפי השפה
            if language == "python":
                completion_text = f"def {part_name}():\n    # TODO: Implement function\n    pass"
            elif language in ["javascript", "java", "c", "cpp"]:
                completion_text = f"function {part_name}() {{\n    // TODO: Implement function\n}}"
        elif part_type == "class" and part_name:
            # תבנית בסיסית למחלקה לפי השפה
            if language == "python":
                completion_text = f"class {part_name}:\n    def __init__(self):\n        pass"
            elif language == "javascript":
                completion_text = f"class {part_name} {{\n    constructor() {{\n    }}\n}}"
            elif language == "java":
                completion_text = f"public class {part_name} {{\n}}"
            elif language in ["c", "cpp"]:
                completion_text = f"class {part_name} {{\npublic:\n    {part_name}();\n}};"
        
        # חזרה עם תוצאות ההשלמה
        return {
            "part_id": part.get("id", ""),
            "start_line": start_line,
            "end_line": end_line,
            "completion": completion_text,
            "confidence": 0.5  # ברירת מחדל - ביטחון בינוני
        }
    
    def _detect_missing_code(self, content: str, language: str) -> List[Dict[str, Any]]:
        """
        זיהוי חלקי קוד חסרים
        
        Args:
            content: תוכן הקוד
            language: שפת התכנות
            
        Returns:
            List[Dict[str, Any]]: רשימת חלקים חסרים
        """
        # קריאה למטפל השפה
        handler = self.language_handlers.get(language)
        
        if not handler:
            # אם אין מטפל ספציפי, זיהוי בסיסי
            return self._basic_missing_detection(content, language)
        
        # זיהוי באמצעות המטפל
        return handler.detect_missing_parts(content)
    
    def _basic_missing_detection(self, content: str, language: str) -> List[Dict[str, Any]]:
        """
        זיהוי בסיסי של חלקי קוד חסרים
        
        Args:
            content: תוכן הקוד
            language: שפת התכנות
            
        Returns:
            List[Dict[str, Any]]: רשימת חלקים חסרים
        """
        missing_parts = []
        lines = content.split('\n')
        
        # חיפוש פשוט של תגובות TODO, FIXME או חלקים לא שלמים
        for i, line in enumerate(lines):
            line = line.strip()
            
            # חיפוש תגובות TODO או FIXME
            if ('TODO' in line or 'FIXME' in line) and ('#' in line or '//' in line or '/*' in line):
                description = line.split('#')[-1] if '#' in line else line.split('//')[-1]
                description = description.split('TODO:')[-1] if 'TODO:' in line else description
                description = description.split('FIXME:')[-1] if 'FIXME:' in line else description
                
                missing_parts.append({
                    "id": f"todo_{i}",
                    "type": "todo",
                    "start_line": i,
                    "end_line": i,
                    "description": description.strip()
                })
            
            # חיפוש פונקציות או מחלקות חסרות
            if language == "python":
                if line.startswith('def ') and 'pass' in line:
                    # פונקציה ריקה
                    name = line.split('def ')[1].split('(')[0].strip()
                    missing_parts.append({
                        "id": f"empty_func_{i}",
                        "type": "function",
                        "name": name,
                        "start_line": i,
                        "end_line": i + 1
                    })
                elif line.startswith('class ') and i + 1 < len(lines) and 'pass' in lines[i + 1]:
                    # מחלקה ריקה
                    name = line.split('class ')[1].split('(')[0].split(':')[0].strip()
                    missing_parts.append({
                        "id": f"empty_class_{i}",
                        "type": "class",
                        "name": name,
                        "start_line": i,
                        "end_line": i + 1
                    })
            elif language in ["javascript", "java", "c", "cpp"]:
                if (line.startswith('function ') or 'function(' in line) and i + 1 < len(lines) and '{' in line and '}' in lines[i + 1]:
                    # פונקציה ריקה
                    name = line.split('function ')[1].split('(')[0].strip() if 'function ' in line else ""
                    missing_parts.append({
                        "id": f"empty_func_{i}",
                        "type": "function",
                        "name": name,
                        "start_line": i,
                        "end_line": i + 1
                    })
        
        return missing_parts
    
    def _apply_completions(self, content: str, completions: List[Dict[str, Any]]) -> str:
        """
        החלת השלמות על הקוד
        
        Args:
            content: תוכן הקוד המקורי
            completions: רשימת השלמות
            
        Returns:
            str: קוד משולב
        """
        lines = content.split('\n')
        
        # מיון השלמות לפי שורה (מהסוף להתחלה)
        sorted_completions = sorted(completions, key=lambda x: x.get("start_line", 0), reverse=True)
        
        # החלת כל השלמה
        for completion in sorted_completions:
            start_line = completion.get("start_line", 0)
            end_line = completion.get("end_line", start_line)
            completion_text = completion.get("completion", "")
            
            # החלפת השורות
            if start_line <= end_line and start_line < len(lines):
                # חיתוך השורות הישנות
                lines = lines[:start_line] + completion_text.split('\n') + lines[end_line + 1:]
        
        # איחוד מחדש
        return '\n'.join(lines)


# מטפלי שפות ספציפיים

class LanguageHandler:
    """מטפל שפה בסיסי"""
    
    def refine_missing_parts(self, missing_parts: List[Dict[str, Any]], content: str) -> List[Dict[str, Any]]:
        """ליטוש חלקים חסרים"""
        return missing_parts
    
    def complete_part(self, part: Dict[str, Any], content: str) -> Dict[str, Any]:
        """השלמת חלק חסר"""
        return {
            "part_id": part.get("id", ""),
            "start_line": part.get("start_line", 0),
            "end_line": part.get("end_line", 0),
            "completion": "",
            "confidence": 0.0
        }
    
    def detect_missing_parts(self, content: str) -> List[Dict[str, Any]]:
        """זיהוי חלקים חסרים"""
        return []
    
    def suggest_completions(self, context_lines: List[str], line_index: int, column: int) -> List[Dict[str, Any]]:
        """הצעת השלמות קוד"""
        return []


class PythonCodeHandler(LanguageHandler):
    """מטפל קוד פייתון"""
    
    def refine_missing_parts(self, missing_parts: List[Dict[str, Any]], content: str) -> List[Dict[str, Any]]:
        # חיפוש הקשר רחב יותר עבור פונקציות ומחלקות
        for part in missing_parts:
            if part.get("type") == "function" and "name" in part:
                # בדיקה אם יש סימני מסוגלים (decorators) לפני הפונקציה
                start_line = part.get("start_line", 0)
                lines = content.split('\n')
                
                # קידום התחלת הקטע אם יש סימני מסוגלים
                while start_line > 0 and lines[start_line - 1].strip().startswith('@'):
                    start_line -= 1
                
                part["start_line"] = start_line
        
        return missing_parts
    
    def complete_part(self, part: Dict[str, Any], content: str) -> Dict[str, Any]:
        part_type = part.get("type", "")
        part_name = part.get("name", "")
        start_line = part.get("start_line", 0)
        end_line = part.get("end_line", start_line)
        
        # חילוץ קונטקסט
        lines = content.split('\n')
        
        if part_type == "function":
            # בדיקה אם זו מתודה במחלקה
            is_method = False
            method_indent = ""
            
            if start_line > 0:
                for i in range(start_line - 1, -1, -1):
                    line = lines[i].rstrip()
                    if line.startswith('class '):
                        is_method = True
                        # חישוב רמת הזחה
                        class_indent = re.match(r'^(\s*)', line).group(1)
                        method_indent = class_indent + "    "
                        break
            
            # בדיקה אם יש סימני מסוגלים
            decorators = []
            for i in range(start_line, end_line + 1):
                if i < len(lines) and lines[i].strip().startswith('@'):
                    decorators.append(lines[i])
            
            # בניית הפונקציה
            if is_method:
                completion = f"{method_indent}def {part_name}(self):\n{method_indent}    \"\"\"TODO: Add docstring\"\"\"\n{method_indent}    # TODO: Implement method\n{method_indent}    pass"
            else:
                completion = f"def {part_name}():\n    \"\"\"TODO: Add docstring\"\"\"\n    # TODO: Implement function\n    pass"
            
            # הוספת סימני מסוגלים
            if decorators:
                completion = '\n'.join(decorators) + '\n' + completion
            
            return {
                "part_id": part.get("id", ""),
                "start_line": start_line,
                "end_line": end_line,
                "completion": completion,
                "confidence": 0.7
            }
            
        elif part_type == "class":
            completion = f"class {part_name}:\n    \"\"\"TODO: Add class docstring\"\"\"\n    \n    def __init__(self):\n        \"\"\"Initialize the {part_name} class\"\"\"\n        pass"
            
            return {
                "part_id": part.get("id", ""),
                "start_line": start_line,
                "end_line": end_line,
                "completion": completion,
                "confidence": 0.7
            }
            
        elif part_type == "todo":
            # השלמה לפי תיאור ה-TODO
            description = part.get("description", "")
            
            if "function" in description.lower():
                # זה כנראה תיאור פונקציה שחסרה
                func_name = re.search(r'function\s+(\w+)', description.lower())
                if func_name:
                    name = func_name.group(1)
                    completion = f"def {name}():\n    \"\"\"TODO: {description}\"\"\"\n    # Implementation\n    pass"
                    
                    return {
                        "part_id": part.get("id", ""),
                        "start_line": start_line,
                        "end_line": end_line,
                        "completion": completion,
                        "confidence": 0.6
                    }
            
            # ברירת מחדל - השאר את ה-TODO כפי שהוא
            line = lines[start_line] if start_line < len(lines) else ""
            
            return {
                "part_id": part.get("id", ""),
                "start_line": start_line,
                "end_line": end_line,
                "completion": line,
                "confidence": 0.5
            }
            
        # ברירת מחדל - החזר את הקוד המקורי
        original_lines = lines[start_line:end_line+1]
        
        return {
            "part_id": part.get("id", ""),
            "start_line": start_line,
            "end_line": end_line,
            "completion": '\n'.join(original_lines),
            "confidence": 0.5
        }
    
    def detect_missing_parts(self, content: str) -> List[Dict[str, Any]]:
        missing_parts = []
        lines = content.split('\n')
        
        # חיפוש פונקציות ומחלקות ריקות
        for i, line in enumerate(lines):
            line = line.strip()
            
            # פונקציות ריקות (עם pass)
            if line.startswith('def ') and ':' in line:
                name = line.split('def ')[1].split('(')[0].strip()
                
                # בדיקה אם הפונקציה ריקה
                j = i + 1
                while j < len(lines) and (not lines[j].strip() or lines[j].strip().startswith('#')):
                    j += 1
                
                if j < len(lines) and lines[j].strip() == 'pass':
                    missing_parts.append({
                        "id": f"empty_func_{i}",
                        "type": "function",
                        "name": name,
                        "start_line": i,
                        "end_line": j
                    })
            
            # מחלקות ריקות
            elif line.startswith('class ') and ':' in line:
                name = line.split('class ')[1].split('(')[0].split(':')[0].strip()
                
                # בדיקה אם המחלקה כמעט ריקה
                is_empty = True
                has_methods = False
                
                j = i + 1
                while j < len(lines) and j < i + 10:  # נבדוק עד 10 שורות קדימה
                    if lines[j].strip() and not lines[j].strip().startswith('#'):
                        # אם יש פונקציה אמיתית, המחלקה לא ריקה
                        if 'def ' in lines[j] and not 'pass' in lines[j+1:j+3]:
                            is_empty = False
                            has_methods = True
                            break
                    j += 1
                
                if is_empty and not has_methods:
                    missing_parts.append({
                        "id": f"empty_class_{i}",
                        "type": "class",
                        "name": name,
                        "start_line": i,
                        "end_line": i
                    })
            
            # תגובות TODO
            elif '#' in line and ('TODO' in line or 'FIXME' in line):
                description = line.split('#', 1)[1].strip()
                if 'TODO:' in description:
                    description = description.split('TODO:', 1)[1].strip()
                elif 'FIXME:' in description:
                    description = description.split('FIXME:', 1)[1].strip()
                
                missing_parts.append({
                    "id": f"todo_{i}",
                    "type": "todo",
                    "start_line": i,
                    "end_line": i,
                    "description": description
                })
            
            # חיפוש שגיאות תחביר פוטנציאליות
            elif line.endswith('(') or line.endswith('{') or line.endswith('['):
                # בדיקה אם ישנה סגירה בהמשך
                closing_found = False
                closing_char = ')' if line.endswith('(') else ('}' if line.endswith('{') else ']')
                
                j = i + 1
                while j < len(lines) and j < i + 10:  # נבדוק עד 10 שורות קדימה
                    if closing_char in lines[j]:
                        closing_found = True
                        break
                    j += 1
                
                if not closing_found:
                    missing_parts.append({
                        "id": f"unclosed_{i}",
                        "type": "syntax_error",
                        "start_line": i,
                        "end_line": i,
                        "description": f"חסר סימן סגירה: {closing_char}"
                    })
        
        return missing_parts


class JavaScriptCodeHandler(LanguageHandler):
    """מטפל קוד JavaScript"""
    
    # כאן נמשיך להוסיף את המימוש של ה-JS Handler
    # (דומה לפייתון אבל עם התאמות לשפה)
    pass


class JavaCodeHandler(LanguageHandler):
    """מטפל קוד Java"""
    pass


class CCodeHandler(LanguageHandler):
    """מטפל קוד C"""
    pass


class CppCodeHandler(LanguageHandler):
    """מטפל קוד C++"""
    pass