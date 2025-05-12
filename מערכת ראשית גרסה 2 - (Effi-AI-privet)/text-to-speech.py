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
