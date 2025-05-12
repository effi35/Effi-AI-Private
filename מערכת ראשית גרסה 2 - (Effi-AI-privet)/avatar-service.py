#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
שירות אווטאר - יצירת אווטאר אנושי עם סנכרון שפתיים ומימיקה
"""

import os
import json
import logging
import tempfile
import base64
from typing import Dict, Any, Optional, Union, List

class AvatarService:
    """שירות אווטאר - יצירת אווטאר אנושי מדבר"""
    
    def __init__(self, config_path=None):
        """אתחול שירות אווטאר
        
        Args:
            config_path: נתיב לקובץ תצורה. אם None, נקבע אוטומטית.
        """
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        self.avatar_dir = os.path.join(base_dir, "data", "avatars")
        
        # יצירת תיקיית אווטאר אם לא קיימת
        os.makedirs(self.avatar_dir, exist_ok=True)
        
        # טעינת הגדרות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.avatar_config = config.get("services", {}).get("avatar", {})
            
            if not self.avatar_config.get("enabled", True):
                logging.info("שירות אווטאר מושבת בהגדרות")
                return
            
            # אתחול הגדרות בסיסיות
            self.default_model = self.avatar_config.get("default_model", "live2d")
            self.lip_sync = self.avatar_config.get("lip_sync", True)
            self.facial_expressions = self.avatar_config.get("facial_expressions", True)
            
            # טעינת מודלים
            self.models = {}
            
            # אתחול Live2D אם זמין
            if "live2d" in self.avatar_config.get("models", []):
                try:
                    self._init_live2d()
                    logging.info("מודל Live2D אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מודל Live2D: {e}")
            
            # אתחול מודל תלת-ממדי אם זמין
            if "3d" in self.avatar_config.get("models", []):
                try:
                    self._init_3d()
                    logging.info("מודל תלת-ממדי אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מודל תלת-ממדי: {e}")
            
            # אתחול מודל פוטו-ריאליסטי אם זמין
            if "photo_realistic" in self.avatar_config.get("models", []):
                try:
                    self._init_photo_realistic()
                    logging.info("מודל פוטו-ריאליסטי אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מודל פוטו-ריאליסטי: {e}")
            
            # וידוא שלפחות מודל אחד זמין
            if not self.models:
                logging.warning("אין מודלי אווטאר זמינים")
            else:
                logging.info(f"שירות אווטאר אותחל עם מודל ברירת מחדל: {self.default_model}")
                
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות אווטאר: {e}")
    
    def _init_live2d(self):
        """אתחול מודל Live2D"""
        # בדיקת קיום קבצי ממשק JavaScript ו-CSS
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        js_file = os.path.join(base_dir, "ui", "assets", "js", "live2d.min.js")
        model_dir = os.path.join(self.avatar_dir, "live2d")
        
        # יצירת תיקייה למודלים אם לא קיימת
        os.makedirs(model_dir, exist_ok=True)
        
        # הורדת קבצי מודל לדוגמה אם לא קיימים
        if not os.listdir(model_dir):
            logging.info("מוריד מודל Live2D לדוגמה...")
            self._download_sample_live2d_model(model_dir)
        
        # הוספת המודל לרשימת המודלים הזמינים
        self.models["live2d"] = {
            "model_dir": model_dir
        }
    
    def _download_sample_live2d_model(self, model_dir):
        """הורדת מודל Live2D לדוגמה
        
        Args:
            model_dir: נתיב לתיקיית המודל
        """
        try:
            import requests
            import zipfile
            import io
            
            # כתובת של מודל Live2D לדוגמה
            url = "https://cdn.jsdelivr.net/gh/guansss/pixi-live2d-display/example/models/haru/haru_greeter_t03.model3.json"
            
            # הורדת המודל
            response = requests.get(url)
            
            if response.status_code == 200:
                # שמירת קובץ המודל
                with open(os.path.join(model_dir, "model.json"), "wb") as f:
                    f.write(response.content)
                
                # הורדת קבצי טקסטורה ואנימציה
                # (בפועל צריך לטפל בכל הקבצים הדרושים)
            else:
                logging.error(f"שגיאה בהורדת מודל Live2D: {response.status_code}")
                
        except Exception as e:
            logging.error(f"שגיאה בהורדת מודל Live2D: {e}")
    
    def _init_3d(self):
        """אתחול מודל תלת-ממדי"""
        model_dir = os.path.join(self.avatar_dir, "3d")
        
        # יצירת תיקייה למודלים אם לא קיימת
        os.makedirs(model_dir, exist_ok=True)
        
        # הוספת המודל לרשימת המודלים הזמינים
        self.models["3d"] = {
            "model_dir": model_dir
        }
    
    def _init_photo_realistic(self):
        """אתחול מודל פוטו-ריאליסטי"""
        model_dir = os.path.join(self.avatar_dir, "photo_realistic")
        
        # יצירת תיקייה למודלים אם לא קיימת
        os.makedirs(model_dir, exist_ok=True)
        
        # הוספת המודל לרשימת המודלים הזמינים
        self.models["photo_realistic"] = {
            "model_dir": model_dir
        }
    
    def create_avatar_from_image(self, image_path, output_dir=None):
        """יצירת אווטאר מתמונה
        
        Args:
            image_path: נתיב לתמונה
            output_dir: נתיב לתיקיית פלט (אופציונלי)
            
        Returns:
            נתיב לתיקיית האווטאר
        """
        try:
            if not output_dir:
                output_dir = os.path.join(self.avatar_dir, "custom", os.path.basename(image_path).split('.')[0])
                os.makedirs(output_dir, exist_ok=True)
            
            # בדיקה שהתמונה קיימת
            if not os.path.exists(image_path):
                logging.error(f"התמונה לא נמצאה: {image_path}")
                return None
            
            # עיבוד התמונה (פיתוח עתידי)
            # כאן יהיה קוד לעיבוד התמונה ליצירת אווטאר
            
            # החזרת נתיב האווטאר
            return output_dir
            
        except Exception as e:
            logging.error(f"שגיאה ביצירת אווטאר מתמונה: {e}")
            return None
    
    def generate_talking_video(self, text, avatar_path=None, output_file=None, model=None):
        """יצירת וידאו של אווטאר מדבר
        
        Args:
            text: הטקסט להשמעה
            avatar_path: נתיב לאווטאר (אופציונלי)
            output_file: נתיב לקובץ הווידאו (אופציונלי)
            model: מודל לשימוש (אופציונלי)
            
        Returns:
            נתיב לקובץ הווידאו
        """
        if not model:
            model = self.default_model
        
        if model not in self.models:
            logging.error(f"מודל {model} אינו זמין")
            return None
        
        # אם לא צוין קובץ פלט, יצירת קובץ זמני
        if not output_file:
            output_file = tempfile.mktemp(suffix=".mp4")
        
        try:
            # המרת טקסט לדיבור
            from services.text_to_speech_service import TextToSpeechService
            tts = TextToSpeechService()
            audio_file = tts.text_to_speech(text)
            
            if not audio_file:
                logging.error("שגיאה בהמרת טקסט לדיבור")
                return None
            
            # יצירת וידאו עם סנכרון שפתיים
            if model == "live2d":
                return self._generate_live2d_video(audio_file, avatar_path, output_file)
            elif model == "3d":
                return self._generate_3d_video(audio_file, avatar_path, output_file)
            elif model == "photo_realistic":
                return self._generate_photo_realistic_video(audio_file, avatar_path, output_file)
            else:
                return None
                
        except Exception as e:
            logging.error(f"שגיאה ביצירת וידאו: {e}")
            return None
    
    def _generate_live2d_video(self, audio_file, avatar_path, output_file):
        """יצירת וידאו עם מודל Live2D
        
        Args:
            audio_file: נתיב לקובץ האודיו
            avatar_path: נתיב לאווטאר
            output_file: נתיב לקובץ הווידאו
            
        Returns:
            נתיב לקובץ הווידאו
        """
        # סנכרון שפתיים והנפשה (פיתוח עתידי)
        # כאן יהיה קוד ליצירת וידאו עם מודל Live2D
        
        # יצירת דוגמת וידאו
        self._create_dummy_video(audio_file, output_file)
        
        return output_file
    
    def _generate_3d_video(self, audio_file, avatar_path, output_file):
        """יצירת וידאו עם מודל תלת-ממדי
        
        Args:
            audio_file: נתיב לקובץ האודיו
            avatar_path: נתיב לאווטאר
            output_file: נתיב לקובץ הווידאו
            
        Returns:
            נתיב לקובץ הווידאו
        """
        # סנכרון שפתיים והנפשה (פיתוח עתידי)
        # כאן יהיה קוד ליצירת וידאו עם מודל תלת-ממדי
        
        # יצירת דוגמת וידאו
        self._create_dummy_video(audio_file, output_file)
        
        return output_file
    
    def _generate_photo_realistic_video(self, audio_file, avatar_path, output_file):
        """יצירת וידאו עם מודל פוטו-ריאליסטי
        
        Args:
            audio_file: נתיב לקובץ האודיו
            avatar_path: נתיב לאווטאר
            output_file: נתיב לקובץ הווידאו
            
        Returns:
            נתיב לקובץ הווידאו
        """
        # סנכרון שפתיים והנפשה (פיתוח עתידי)
        # כאן יהיה קוד ליצירת וידאו עם מודל פוטו-ריאליסטי
        
        # יצירת דוגמת וידאו
        self._create_dummy_video(audio_file, output_file)
        
        return output_file
    
    def _create_dummy_video(self, audio_file, output_file):
        """יצירת וידאו לדוגמה
        
        Args:
            audio_file: נתיב לקובץ האודיו
            output_file: נתיב לקובץ הווידאו
        """
        try:
            import moviepy.editor as mp
            
            # טעינת קובץ האודיו
            audio = mp.AudioFileClip(audio_file)
            
            # יצירת קליפ עם רקע שחור בגודל האודיו
            clip = mp.ColorClip(size=(640, 480), color=(0, 0, 0), duration=audio.duration)
            
            # הוספת האודיו לקליפ
            clip = clip.set_audio(audio)
            
            # שמירת הווידאו
            clip.write_videofile(output_file, fps=24)
            
        except ImportError:
            logging.warning("חבילת moviepy אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "moviepy"])
            self._create_dummy_video(audio_file, output_file)
