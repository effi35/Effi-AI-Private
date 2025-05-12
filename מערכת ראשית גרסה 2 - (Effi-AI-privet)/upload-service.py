#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
שירות העלאת קבצים - ניהול קבצים, תמונות, סרטונים ואודיו
"""

import os
import json
import logging
import shutil
import uuid
import mimetypes
from typing import Dict, Any, Optional, Union, List

class UploadService:
    """שירות העלאת קבצים - ניהול קבצים, תמונות, סרטונים ואודיו"""
    
    def __init__(self, config_path=None):
        """אתחול שירות העלאת קבצים
        
        Args:
            config_path: נתיב לקובץ תצורה. אם None, נקבע אוטומטית.
        """
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        
        # טעינת הגדרות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.upload_config = config.get("services", {}).get("upload", {})
            
            if not self.upload_config.get("enabled", True):
                logging.info("שירות העלאת קבצים מושבת בהגדרות")
                return
            
            # הגדרת נתיב אחסון
            self.storage_path = os.path.join(
                base_dir, 
                self.upload_config.get("storage_path", "./data/uploads")
            )
            
            # יצירת תיקיות אחסון אם לא קיימות
            self.image_dir = os.path.join(self.storage_path, "images")
            self.video_dir = os.path.join(self.storage_path, "videos")
            self.audio_dir = os.path.join(self.storage_path, "audio")
            self.file_dir = os.path.join(self.storage_path, "files")
            
            os.makedirs(self.image_dir, exist_ok=True)
            os.makedirs(self.video_dir, exist_ok=True)
            os.makedirs(self.audio_dir, exist_ok=True)
            os.makedirs(self.file_dir, exist_ok=True)
            
            # הגדרת סוגי קבצים מותרים
            self.allowed_types = self.upload_config.get("allowed_types", [])
            self.max_size = self.upload_config.get("max_size_mb", 100) * 1024 * 1024  # המרה ל-bytes
            
            logging.info(f"שירות העלאת קבצים אותחל בהצלחה. נתיב אחסון: {self.storage_path}")
            
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות העלאת קבצים: {e}")
    
    def upload_file(self, file_path, file_type=None, custom_filename=None):
        """העלאת קובץ למערכת
        
        Args:
            file_path: נתיב לקובץ המקור
            file_type: סוג הקובץ (אופציונלי)
            custom_filename: שם מותאם אישית לקובץ (אופציונלי)
            
        Returns:
            מילון עם מידע על הקובץ שהועלה
        """
        try:
            # בדיקה שהקובץ קיים
            if not os.path.exists(file_path):
                logging.error(f"הקובץ לא נמצא: {file_path}")
                return None
            
            # בדיקת גודל הקובץ
            file_size = os.path.getsize(file_path)
            if file_size > self.max_size:
                logging.error(f"הקובץ חורג מהגודל המרבי המותר: {file_size} > {self.max_size}")
                return None
            
            # זיהוי סוג הקובץ אם לא צוין
            if not file_type:
                file_type = mimetypes.guess_type(file_path)[0]
            
            # בדיקה אם סוג הקובץ מותר
            if self.allowed_types and file_type not in self.allowed_types:
                logging.error(f"סוג הקובץ אינו מותר: {file_type}")
                return None
            
            # בחירת תיקיית היעד לפי סוג הקובץ
            if file_type.startswith("image/"):
                target_dir = self.image_dir
                file_category = "image"
            elif file_type.startswith("video/"):
                target_dir = self.video_dir
                file_category = "video"
            elif file_type.startswith("audio/"):
                target_dir = self.audio_dir
                file_category = "audio"
            else:
                target_dir = self.file_dir
                file_category = "file"
            
            # יצירת שם קובץ ייחודי
            if custom_filename:
                filename = custom_filename
            else:
                original_filename = os.path.basename(file_path)
                ext = os.path.splitext(original_filename)[1]
                filename = f"{uuid.uuid4()}{ext}"
            
            # נתיב מלא לקובץ היעד
            target_path = os.path.join(target_dir, filename)
            
            # העתקת הקובץ
            shutil.copy2(file_path, target_path)
            
            # החזרת מידע על הקובץ שהועלה
            return {
                "id": str(uuid.uuid4()),
                "filename": filename,
                "original_filename": os.path.basename(file_path),
                "path": target_path,
                "type": file_type,
                "category": file_category,
                "size": file_size,
                "upload_time": os.path.getctime(target_path)
            }
            
        except Exception as e:
            logging.error(f"שגיאה בהעלאת קובץ: {e}")
            return None
    
    def get_file_info(self, file_id=None, filename=None):
        """קבלת מידע על קובץ
        
        Args:
            file_id: מזהה הקובץ (אופציונלי)
            filename: שם הקובץ (אופציונלי)
            
        Returns:
            מידע על הקובץ
        """
        # יש לממש חיפוש בבסיס נתונים (פיתוח עתידי)
        return None
    
    def delete_file(self, file_id=None, filename=None, file_path=None):
        """מחיקת קובץ
        
        Args:
            file_id: מזהה הקובץ (אופציונלי)
            filename: שם הקובץ (אופציונלי)
            file_path: נתיב מלא לקובץ (אופציונלי)
            
        Returns:
            האם המחיקה הצליחה
        """
        try:
            # מחיקה לפי נתיב
            if file_path and os.path.exists(file_path):
                os.remove(file_path)
                logging.info(f"הקובץ נמחק בהצלחה: {file_path}")
                return True
            
            # מחיקה לפי שם קובץ
            elif filename:
                # חיפוש בכל תיקיות האחסון
                for dir_path in [self.image_dir, self.video_dir, self.audio_dir, self.file_dir]:
                    file_path = os.path.join(dir_path, filename)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                        logging.info(f"הקובץ נמחק בהצלחה: {file_path}")
                        return True
            
            # מחיקה לפי מזהה
            elif file_id:
                # יש לממש חיפוש בבסיס נתונים (פיתוח עתידי)
                pass
            
            logging.error("הקובץ לא נמצא")
            return False
            
        except Exception as e:
            logging.error(f"שגיאה במחיקת קובץ: {e}")
            return False
    
    def process_image(self, image_path, operations=None):
        """עיבוד תמונה
        
        Args:
            image_path: נתיב לתמונה
            operations: רשימת פעולות לביצוע (אופציונלי)
            
        Returns:
            נתיב לתמונה המעובדת
        """
        try:
            # בדיקה שהתמונה קיימת
            if not os.path.exists(image_path):
                logging.error(f"התמונה לא נמצאה: {image_path}")
                return None
            
            # אם לא צוינו פעולות, החזרת נתיב התמונה המקורית
            if not operations:
                return image_path
            
            # יצירת נתיב לתמונה המעובדת
            filename = os.path.basename(image_path)
            processed_path = os.path.join(self.image_dir, f"processed_{filename}")
            
            # עיבוד התמונה
            from PIL import Image
            img = Image.open(image_path)
            
            # ביצוע פעולות
            for operation in operations:
                op_type = operation.get("type")
                
                if op_type == "resize":
                    width = operation.get("width")
                    height = operation.get("height")
                    img = img.resize((width, height))
                
                elif op_type == "crop":
                    left = operation.get("left", 0)
                    top = operation.get("top", 0)
                    right = operation.get("right")
                    bottom = operation.get("bottom")
                    img = img.crop((left, top, right, bottom))
                
                elif op_type == "rotate":
                    angle = operation.get("angle", 0)
                    img = img.rotate(angle)
                
                # ניתן להוסיף עוד פעולות כאן
            
            # שמירת התמונה המעובדת
            img.save(processed_path)
            
            return processed_path
            
        except Exception as e:
            logging.error(f"שגיאה בעיבוד תמונה: {e}")
            return None
