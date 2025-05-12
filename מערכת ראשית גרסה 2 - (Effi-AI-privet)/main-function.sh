# הוספת פונקציות ראשיות לסקריפט ההתקנה המקיף
main() {
    # הצגת באנר התחלה
    show_banner
    
    # בדיקת דרישות מוקדמות
    check_prerequisites
    
    # יצירת מבנה תיקיות
    create_directory_structure
    
    # התקנת תלויות
    install_dependencies
    
    # התקנת Ollama
    install_ollama
    
    # יצירת קובצי תצורה
    create_config_files
    
    # יצירת קובץ README.md
    create_readme
    
    # יצירת מודול מנהל המודלים
    create_model_manager
    
    # יצירת שירות RAG
    create_rag_service
    
    # יצירת שירות תמיכה בעברית
    create_hebrew_service
    
    # יצירת שירות דיבור לטקסט
    create_speech_to_text_service
    
    # יצירת שירותי המערכת הנוספים
    create_utility_services
    
    # יצירת קובץ הרצה ראשי
    create_main_file
    
    # יצירת תיקיית שירותי לוגים
    create_logging_service
    
    # קישור כל הרכיבים
    link_components
    
    echo -e "\n${GREEN}${BOLD}התקנת Effi-AI Private הושלמה בהצלחה!${RESET}"
    echo -e "\n${BLUE}להפעלת המערכת, הרץ:${RESET}"
    echo -e "${YELLOW}cd ${SYSTEM_DIR} && python run.py${RESET}"
}

# יצירת שירותי המערכת הנוספים
create_utility_services() {
    print_header "יצירת שירותי מערכת נוספים"
    
    # יצירת שירות טקסט לדיבור
    cat > "${SERVICES_DIR}/text_to_speech_service.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
שירות טקסט לדיבור - המרת טקסט להקלטות קול
"""

import os
import json
import logging
import tempfile
from typing import Dict, Any, Optional, Union, List

class TextToSpeechService:
    """שירות טקסט לדיבור - המרת טקסט להקלטות קול"""
    
    def __init__(self, config_path=None):
        """אתחול שירות טקסט לדיבור
        
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
            
            self.tts_config = config.get("services", {}).get("text_to_speech", {})
            
            if not self.tts_config.get("enabled", True):
                logging.info("שירות טקסט לדיבור מושבת בהגדרות")
                return
            
            # אתחול הגדרות בסיסיות
            self.default_engine = self.tts_config.get("default_engine", "gtts")
            self.language = self.tts_config.get("language", "he-IL")
            self.voice = self.tts_config.get("voice", "female")
            
            # טעינת מנועי סינתזת דיבור
            self.engines = {}
            
            # אתחול gTTS אם זמין
            if "gtts" in self.tts_config.get("engines", []):
                try:
                    self._init_gtts()
                    logging.info("מנוע gTTS אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מנוע gTTS: {e}")
            
            # אתחול pyttsx3 אם זמין
            if "pyttsx3" in self.tts_config.get("engines", []):
                try:
                    self._init_pyttsx3()
                    logging.info("מנוע pyttsx3 אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מנוע pyttsx3: {e}")
            
            # וידוא שלפחות מנוע אחד זמין
            if not self.engines:
                logging.warning("אין מנועי סינתזת דיבור זמינים")
            else:
                logging.info(f"שירות טקסט לדיבור אותחל עם מנוע ברירת מחדל: {self.default_engine}")
                
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות טקסט לדיבור: {e}")
    
    def _init_gtts(self):
        """אתחול מנוע gTTS"""
        try:
            from gtts import gTTS
            
            # הוספת המנוע לרשימת המנועים הזמינים
            self.engines["gtts"] = {}
            
        except ImportError:
            logging.warning("חבילת gTTS אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "gTTS"])
            self._init_gtts()  # ניסיון שני לאתחול
    
    def _init_pyttsx3(self):
        """אתחול מנוע pyttsx3"""
        try:
            import pyttsx3
            
            # אתחול מנוע
            engine = pyttsx3.init()
            
            # הגדרת המהירות וקצב הדיבור
            engine.setProperty('rate', 150)
            
            # בחירת קול (אם זמין)
            voices = engine.getProperty('voices')
            if voices:
                if self.voice == "female":
                    # ניסיון למצוא קול נשי
                    female_voices = [v for v in voices if 'female' in v.name.lower()]
                    if female_voices:
                        engine.setProperty('voice', female_voices[0].id)
                elif self.voice == "male":
                    # ניסיון למצוא קול גברי
                    male_voices = [v for v in voices if 'male' in v.name.lower()]
                    if male_voices:
                        engine.setProperty('voice', male_voices[0].id)
            
            # הוספת המנוע לרשימת המנועים הזמינים
            self.engines["pyttsx3"] = {
                "engine": engine
            }
            
        except ImportError:
            logging.warning("חבילת pyttsx3 אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "pyttsx3"])
            self._init_pyttsx3()  # ניסיון שני לאתחול
    
    def text_to_speech(self, text, output_file=None, engine=None):
        """המרת טקסט לקובץ אודיו
        
        Args:
            text: הטקסט להמרה
            output_file: נתיב לקובץ האודיו (אופציונלי)
            engine: מנוע סינתזת דיבור לשימוש (אופציונלי)
            
        Returns:
            נתיב לקובץ האודיו
        """
        if not engine:
            engine = self.default_engine
        
        if engine not in self.engines:
            logging.error(f"מנוע {engine} אינו זמין")
            return None
        
        # אם לא צוין קובץ פלט, יצירת קובץ זמני
        if not output_file:
            output_file = tempfile.mktemp(suffix=".mp3")
        
        try:
            if engine == "gtts":
                return self._tts_with_gtts(text, output_file)
            elif engine == "pyttsx3":
                return self._tts_with_pyttsx3(text, output_file)
            else:
                return None
                
        except Exception as e:
            logging.error(f"שגיאה בהמרת טקסט לדיבור: {e}")
            return None
    
    def _tts_with_gtts(self, text, output_file):
        """המרת טקסט לקובץ אודיו באמצעות gTTS
        
        Args:
            text: הטקסט להמרה
            output_file: נתיב לקובץ האודיו
            
        Returns:
            נתיב לקובץ האודיו
        """
        from gtts import gTTS
        
        # המרת קוד שפה מ-he-IL ל-he
        lang = self.language.split('-')[0]
        
        # יצירת אובייקט gTTS
        tts = gTTS(text=text, lang=lang, slow=False)
        
        # שמירת האודיו לקובץ
        tts.save(output_file)
        
        return output_file
    
    def _tts_with_pyttsx3(self, text, output_file):
        """המרת טקסט לקובץ אודיו באמצעות pyttsx3
        
        Args:
            text: הטקסט להמרה
            output_file: נתיב לקובץ האודיו
            
        Returns:
            נתיב לקובץ האודיו
        """
        engine = self.engines["pyttsx3"]["engine"]
        
        # המרת סיומת mp3 ל-wav אם צריך
        output_wav = output_file
        if output_file.endswith(".mp3"):
            output_wav = output_file.replace(".mp3", ".wav")
        
        # שמירת האודיו לקובץ
        engine.save_to_file(text, output_wav)
        engine.runAndWait()
        
        # המרה ל-mp3 אם צריך
        if output_file.endswith(".mp3") and output_wav != output_file:
            try:
                import pydub
                sound = pydub.AudioSegment.from_wav(output_wav)
                sound.export(output_file, format="mp3")
                os.remove(output_wav)  # מחיקת קובץ ה-wav
            except ImportError:
                # אם pydub אינו מותקן, להשתמש בקובץ ה-wav
                output_file = output_wav
        
        return output_file
    
    def speak(self, text, engine=None):
        """השמעת טקסט באמצעות הרמקולים
        
        Args:
            text: הטקסט להשמעה
            engine: מנוע סינתזת דיבור לשימוש (אופציונלי)
            
        Returns:
            True אם ההשמעה הצליחה, אחרת False
        """
        if not engine:
            engine = self.default_engine
        
        if engine not in self.engines:
            logging.error(f"מנוע {engine} אינו זמין")
            return False
        
        try:
            if engine == "gtts":
                # יצירת קובץ זמני
                output_file = self._tts_with_gtts(text, tempfile.mktemp(suffix=".mp3"))
                
                # השמעת הקובץ
                self._play_audio(output_file)
                
                # מחיקת הקובץ הזמני
                try:
                    os.remove(output_file)
                except:
                    pass
                
                return True
                
            elif engine == "pyttsx3":
                # השמעה ישירה
                engine_obj = self.engines["pyttsx3"]["engine"]
                engine_obj.say(text)
                engine_obj.runAndWait()
                return True
                
            else:
                return False
                
        except Exception as e:
            logging.error(f"שגיאה בהשמעת טקסט: {e}")
            return False
    
    def _play_audio(self, audio_file):
        """השמעת קובץ אודיו
        
        Args:
            audio_file: נתיב לקובץ האודיו
        """
        try:
            import pygame
            
            pygame.mixer.init()
            pygame.mixer.music.load(audio_file)
            pygame.mixer.music.play()
            
            # המתנה לסיום ההשמעה
            while pygame.mixer.music.get_busy():
                pygame.time.Clock().tick(10)
                
        except ImportError:
            logging.warning("חבילת pygame אינה מותקנת. מנסה להשתמש בחלופה...")
            
            try:
                import playsound
                playsound.playsound(audio_file)
            except ImportError:
                logging.warning("חבילת playsound אינה מותקנת. מתקין...")
                import subprocess
                subprocess.run(["pip", "install", "playsound"])
                
                import playsound
                playsound.playsound(audio_file)
EOF

    # יצירת שירות אווטאר
    cat > "${SERVICES_DIR}/avatar_service.py" << 'EOF'
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
EOF

    # יצירת שירות העלאת קבצים
    cat > "${SERVICES_DIR}/upload_service.py" << 'EOF'
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
EOF

    # יצירת מנהל המודולים
    cat > "${SERVICES_DIR}/module_manager.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מנהל מודולים - יבוא, רישום ושילוב מודולים למערכת
"""

import os
import sys
import json
import logging
import importlib.util
import shutil
import zipfile
from pathlib import Path
from typing import Dict, List, Any, Optional

class ModuleManager:
    """מנהל מודולים - מאפשר הוספת מודולים חיצוניים למערכת"""
    
    def __init__(self, config_path=None):
        """אתחול מנהל המודולים
        
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
            
            self.module_config = config.get("system", {}).get("modules", {})
            
            # הגדרת נתיב לתיקיית המודולים
            self.modules_dir = os.path.join(
                base_dir, 
                self.module_config.get("registry", "./modules")
            )
            
            # יצירת תיקיית המודולים אם לא קיימת
            os.makedirs(self.modules_dir, exist_ok=True)
            
            # מילון המודולים הטעונים
            self.loaded_modules = {}
            
            # טעינה אוטומטית של מודולים
            if self.module_config.get("auto_discovery", True):
                self._discover_modules()
            
            logging.info(f"מנהל המודולים אותחל בהצלחה. {len(self.loaded_modules)} מודולים נטענו.")
            
        except Exception as e:
            logging.error(f"שגיאה באתחול מנהל המודולים: {e}")
    
    def _discover_modules(self):
        """גילוי אוטומטי של מודולים בתיקיית המודולים"""
        # קריאת כל התיקיות בתיקיית המודולים
        for module_name in os.listdir(self.modules_dir):
            module_path = os.path.join(self.modules_dir, module_name)
            
            # בדיקה שמדובר בתיקייה
            if not os.path.isdir(module_path):
                continue
            
            # בדיקה שקיים קובץ metadata.json
            metadata_path = os.path.join(module_path, "metadata.json")
            if not os.path.exists(metadata_path):
                continue
            
            # טעינת המודול
            try:
                self.load_module(module_name)
            except Exception as e:
                logging.error(f"שגיאה בטעינת מודול {module_name}: {e}")
    
    def load_module(self, module_name):
        """טעינת מודול למערכת
        
        Args:
            module_name: שם המודול
            
        Returns:
            האם הטעינה הצליחה
        """
        module_path = os.path.join(self.modules_dir, module_name)
        
        # בדיקה שהמודול קיים
        if not os.path.exists(module_path):
            logging.error(f"המודול {module_name} לא נמצא")
            return False
        
        # בדיקה שקיים קובץ metadata.json
        metadata_path = os.path.join(module_path, "metadata.json")
        if not os.path.exists(metadata_path):
            logging.error(f"קובץ metadata.json לא נמצא במודול {module_name}")
            return False
        
        try:
            # טעינת מטאדאטה
            with open(metadata_path, "r", encoding="utf-8") as f:
                metadata = json.load(f)
            
            # בדיקת קובץ ראשי
            main_file = metadata.get("main", "module.py")
            main_path = os.path.join(module_path, main_file)
            
            if not os.path.exists(main_path):
                logging.error(f"הקובץ הראשי {main_file} לא נמצא במודול {module_name}")
                return False
            
            # טעינת המודול באמצעות importlib
            spec = importlib.util.spec_from_file_location(f"modules.{module_name}", main_path)
            module = importlib.util.module_from_spec(spec)
            sys.modules[f"modules.{module_name}"] = module
            spec.loader.exec_module(module)
            
            # הוספת המודול לרשימת המודולים הטעונים
            self.loaded_modules[module_name] = {
                "metadata": metadata,
                "module": module
            }
            
            logging.info(f"המודול {module_name} נטען בהצלחה")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בטעינת מודול {module_name}: {e}")
            return False
    
    def unload_module(self, module_name):
        """הסרת מודול מהמערכת
        
        Args:
            module_name: שם המודול
            
        Returns:
            האם ההסרה הצליחה
        """
        if module_name not in self.loaded_modules:
            logging.error(f"המודול {module_name} אינו טעון")
            return False
        
        try:
            # הסרת המודול ממילון המודולים הטעונים
            module_obj = self.loaded_modules[module_name]
            del self.loaded_modules[module_name]
            
            # הסרת המודול מ-sys.modules
            if f"modules.{module_name}" in sys.modules:
                del sys.modules[f"modules.{module_name}"]
            
            logging.info(f"המודול {module_name} הוסר בהצלחה")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בהסרת מודול {module_name}: {e}")
            return False
    
    def get_module_info(self, module_name):
        """קבלת מידע על מודול
        
        Args:
            module_name: שם המודול
            
        Returns:
            מידע על המודול
        """
        if module_name not in self.loaded_modules:
            logging.error(f"המודול {module_name} אינו טעון")
            return None
        
        return self.loaded_modules[module_name]["metadata"]
    
    def get_loaded_modules(self):
        """קבלת רשימת המודולים הטעונים
        
        Returns:
            רשימת המודולים הטעונים
        """
        return {name: info["metadata"] for name, info in self.loaded_modules.items()}
    
    def install_module(self, module_path):
        """התקנת מודול חדש למערכת
        
        Args:
            module_path: נתיב לתיקיית/קובץ zip המודול
            
        Returns:
            האם ההתקנה הצליחה
        """
        try:
            # בדיקה שהנתיב קיים
            if not os.path.exists(module_path):
                logging.error(f"הנתיב {module_path} לא נמצא")
                return False
            
            # אם מדובר בקובץ ZIP, חילוץ המודול
            if os.path.isfile(module_path) and module_path.endswith(".zip"):
                return self._install_from_zip(module_path)
            
            # אם מדובר בתיקייה, העתקת המודול
            elif os.path.isdir(module_path):
                return self._install_from_dir(module_path)
            
            else:
                logging.error(f"סוג קובץ לא נתמך: {module_path}")
                return False
                
        except Exception as e:
            logging.error(f"שגיאה בהתקנת מודול: {e}")
            return False
    
    def _install_from_zip(self, zip_path):
        """התקנת מודול מקובץ ZIP
        
        Args:
            zip_path: נתיב לקובץ ZIP
            
        Returns:
            האם ההתקנה הצליחה
        """
        try:
            # חילוץ שם המודול מהשם של קובץ ה-ZIP
            module_name = os.path.basename(zip_path).replace(".zip", "")
            
            # נתיב להתקנת המודול
            module_dir = os.path.join(self.modules_dir, module_name)
            
            # מחיקת המודול אם הוא כבר קיים
            if os.path.exists(module_dir):
                shutil.rmtree(module_dir)
            
            # חילוץ ה-ZIP
            with zipfile.ZipFile(zip_path, "r") as zip_ref:
                zip_ref.extractall(self.modules_dir)
            
            # בדיקה שקיים קובץ metadata.json
            metadata_path = os.path.join(module_dir, "metadata.json")
            if not os.path.exists(metadata_path):
                logging.error(f"קובץ metadata.json לא נמצא במודול {module_name}")
                return False
            
            # טעינת המודול
            return self.load_module(module_name)
            
        except Exception as e:
            logging.error(f"שגיאה בהתקנת מודול מקובץ ZIP: {e}")
            return False
    
    def _install_from_dir(self, dir_path):
        """התקנת מודול מתיקייה
        
        Args:
            dir_path: נתיב לתיקייה
            
        Returns:
            האם ההתקנה הצליחה
        """
        try:
            # שם המודול הוא שם התיקייה
            module_name = os.path.basename(dir_path)
            
            # נתיב להתקנת המודול
            module_dir = os.path.join(self.modules_dir, module_name)
            
            # מחיקת המודול אם הוא כבר קיים
            if os.path.exists(module_dir) and os.path.abspath(dir_path) != os.path.abspath(module_dir):
                shutil.rmtree(module_dir)
            
            # בדיקה שקיים קובץ metadata.json בתיקיית המקור
            metadata_path = os.path.join(dir_path, "metadata.json")
            if not os.path.exists(metadata_path):
                logging.error(f"קובץ metadata.json לא נמצא בתיקייה {dir_path}")
                return False
            
            # העתקת התיקייה (אם מדובר בתיקייה אחרת)
            if os.path.abspath(dir_path) != os.path.abspath(module_dir):
                shutil.copytree(dir_path, module_dir)
            
            # טעינת המודול
            return self.load_module(module_name)
            
        except Exception as e:
            logging.error(f"שגיאה בהתקנת מודול מתיקייה: {e}")
            return False
    
    def create_module_template(self, module_name, description="", author="ShayAI"):
        """יצירת תבנית למודול חדש
        
        Args:
            module_name: שם המודול
            description: תיאור המודול
            author: מחבר המודול
            
        Returns:
            נתיב למודול החדש
        """
        try:
            # נתיב למודול החדש
            module_dir = os.path.join(self.modules_dir, module_name)
            
            # בדיקה אם המודול כבר קיים
            if os.path.exists(module_dir):
                logging.error(f"המודול {module_name} כבר קיים")
                return None
            
            # יצירת תיקיות
            os.makedirs(module_dir, exist_ok=True)
            os.makedirs(os.path.join(module_dir, "assets"), exist_ok=True)
            os.makedirs(os.path.join(module_dir, "logs"), exist_ok=True)
            os.makedirs(os.path.join(module_dir, "docs"), exist_ok=True)
            
            # יצירת קובץ metadata.json
            metadata = {
                "name": module_name,
                "version": "1.0.0",
                "description": description,
                "author": author,
                "license": "MIT",
                "main": "module.py",
                "module_dependencies": [],
                "dependencies": {
                    "python_packages": []
                },
                "ui_components": {
                    "settings_tab": True,
                    "main_tab": False
                }
            }
            
            with open(os.path.join(module_dir, "metadata.json"), "w", encoding="utf-8") as f:
                json.dump(metadata, f, ensure_ascii=False, indent=2)
            
            # יצירת קובץ README.md
            with open(os.path.join(module_dir, "README.md"), "w", encoding="utf-8") as f:
                f.write(f"# {module_name}\n\n{description}\n\n## התקנה\n\n## שימוש\n\n## אפשרויות\n")
            
            # יצירת קובץ module.py
            with open(os.path.join(module_dir, "module.py"), "w", encoding="utf-8") as f:
                f.write(f"""#!/usr/bin/env python3
# -*- coding: utf-8 -*-
\"\"\"
מודול: {module_name}
תיאור: {description}
מחבר: {author}
\"\"\"

import os
import json
import logging
from typing import Dict, Any, Optional

class {module_name.title().replace('_', '')}:
    \"\"\"מחלקה ראשית של המודול {module_name}\"\"\"
    
    def __init__(self):
        \"\"\"אתחול המודול\"\"\"
        self.name = "{module_name}"
        self.version = "1.0.0"
        
        # הגדרת נתיבים
        current_dir = os.path.dirname(os.path.abspath(__file__))
        self.assets_dir = os.path.join(current_dir, "assets")
        self.logs_dir = os.path.join(current_dir, "logs")
        
        # הגדרת לוגר
        self.logger = self._setup_logger()
        
        self.logger.info(f"המודול {{self.name}} אותחל בהצלחה")
    
    def _setup_logger(self):
        \"\"\"הגדרת לוגר למודול\"\"\"
        logger = logging.getLogger(self.name)
        logger.setLevel(logging.INFO)
        
        # הגדרת פורמט
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        
        # הגדרת הנדלר לקובץ
        os.makedirs(self.logs_dir, exist_ok=True)
        file_handler = logging.FileHandler(
            os.path.join(self.logs_dir, f"{{self.name}}.log"),
            encoding="utf-8"
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        return logger
    
    def get_info(self):
        \"\"\"קבלת מידע על המודול\"\"\"
        return {{
            "name": self.name,
            "version": self.version,
            "description": "{description}"
        }}
    
    def execute(self, params=None):
        \"\"\"הפעלת המודול עם פרמטרים\"\"\"
        self.logger.info(f"הפעלת המודול עם פרמטרים: {{params}}")
        
        # כאן יבוא הקוד של הפעולה העיקרית של המודול
        
        return {{
            "status": "success",
            "result": "פעולה הושלמה בהצלחה"
        }}

# יצירת מופע של המודול
module_instance = {module_name.title().replace('_', '')}()

# פונקציות ייצוא למנהל המודולים
def get_info():
    \"\"\"קבלת מידע על המודול\"\"\"
    return module_instance.get_info()

def execute(params=None):
    \"\"\"הפעלת המודול\"\"\"
    return module_instance.execute(params)
""")
            
            # יצירת קובץ requirements.txt
            with open(os.path.join(module_dir, "requirements.txt"), "w", encoding="utf-8") as f:
                f.write("# תלויות Python נדרשות\n")
            
            # יצירת קובץ install.sh
            with open(os.path.join(module_dir, "install.sh"), "w", encoding="utf-8") as f:
                f.write(f"""#!/bin/bash
# סקריפט התקנה למודול {module_name}

# הגדרת צבעים
GREEN='\\033[0;32m'
BLUE='\\033[0;34m'
RESET='\\033[0m'

echo -e "${{BLUE}}מתקין את המודול {module_name}...${{RESET}}"

# התקנת תלויות
echo -e "${{BLUE}}מתקין תלויות Python...${{RESET}}"
pip install -r requirements.txt

echo -e "${{GREEN}}המודול {module_name} הותקן בהצלחה!${{RESET}}"
""")
            
            # הפיכת הסקריפט להרצה
            os.chmod(os.path.join(module_dir, "install.sh"), 0o755)
            
            # יצירת קובץ preview.html
            with open(os.path.join(module_dir, "preview.html"), "w", encoding="utf-8") as f:
                f.write(f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{module_name}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #2563eb;
        }}
        .info {{
            margin-bottom: 20px;
            padding: 10px;
            background-color: #f0f9ff;
            border-radius: 4px;
        }}
        .controls {{
            margin-top: 20px;
        }}
        button {{
            background-color: #2563eb;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }}
        button:hover {{
            background-color: #1d4ed8;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{module_name}</h1>
        
        <div class="info">
            <p><strong>תיאור:</strong> {description}</p>
            <p><strong>גרסה:</strong> 1.0.0</p>
            <p><strong>מחבר:</strong> {author}</p>
        </div>
        
        <div id="module-content">
            <!-- תוכן המודול יוצג כאן -->
            <p>טוען את המודול...</p>
        </div>
        
        <div class="controls">
            <button id="execute-btn">הפעל מודול</button>
        </div>
    </div>

    <script>
        // קוד JavaScript לתצוגה מקדימה של המודול
        document.addEventListener('DOMContentLoaded', function() {{
            const moduleContent = document.getElementById('module-content');
            const executeBtn = document.getElementById('execute-btn');
            
            // עדכון תוכן המודול
            moduleContent.innerHTML = '<p>המודול נטען בהצלחה</p>';
            
            // טיפול בלחיצה על כפתור ההפעלה
            executeBtn.addEventListener('click', function() {{
                moduleContent.innerHTML = '<p>מפעיל את המודול...</p>';
                
                // הדמיית פעולת המודול
                setTimeout(() => {{
                    moduleContent.innerHTML = '<p>המודול פעל בהצלחה!</p>';
                }}, 1000);
            }});
        }});
    </script>
</body>
</html>
""")
            
            logging.info(f"נוצרה תבנית למודול {module_name}")
            return module_dir
            
        except Exception as e:
            logging.error(f"שגיאה ביצירת תבנית למודול {module_name}: {e}")
            return None
EOF

    # עדכון __init__.py של חבילת services
    cat > "${SERVICES_DIR}/__init__.py" << 'EOF'
"""חבילת שירותים - RAG, עברית, למידה ועוד"""

from .rag_service import RAGService
from .hebrew_service import HebrewService
from .speech_to_text_service import SpeechToTextService
from .text_to_speech_service import TextToSpeechService
from .avatar_service import AvatarService
from .upload_service import UploadService
from .module_manager import ModuleManager

__all__ = [
    "RAGService", 
    "HebrewService", 
    "SpeechToTextService", 
    "TextToSpeechService", 
    "AvatarService", 
    "UploadService", 
    "ModuleManager"
]
EOF

    print_success "שירותי המערכת הנוספים נוצרו בהצלחה"
}

# הפעלת פונקציית main
main
