#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
שירות דיבור לטקסט - המרת הקלטות קול לטקסט
"""
import os
import json
import logging
import tempfile
import wave
import numpy as np
from typing import Dict, Any, Optional, Union, List

class SpeechToTextService:
    """שירות דיבור לטקסט - המרת הקלטות קול לטקסט"""
    def __init__(self, config_path=None):
        """אתחול שירות דיבור לטקסט
        
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
            
            self.stt_config = config.get("services", {}).get("speech_to_text", {})
            
            if not self.stt_config.get("enabled", True):
                logging.info("שירות דיבור לטקסט מושבת בהגדרות")
                return
            
            # אתחול הגדרות בסיסיות
            self.default_engine = self.stt_config.get("default_engine", "vosk")
            self.language = self.stt_config.get("language", "he-IL")
            self.sample_rate = self.stt_config.get("sample_rate", 16000)
            
            # טעינת מנועי זיהוי דיבור
            self.engines = {}
            
            # אתחול Vosk אם זמין
            if "vosk" in self.stt_config.get("engines", []):
                try:
                    self._init_vosk()
                    logging.info("מנוע Vosk אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מנוע Vosk: {e}")
            
            # אתחול Google Speech Recognition אם זמין
            if "google" in self.stt_config.get("engines", []):
                try:
                    self._init_google()
                    logging.info("מנוע Google Speech Recognition אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מנוע Google Speech Recognition: {e}")
            
            # אתחול Whisper אם זמין
            if "whisper" in self.stt_config.get("engines", []):
                try:
                    self._init_whisper()
                    logging.info("מנוע Whisper אותחל בהצלחה")
                except Exception as e:
                    logging.error(f"שגיאה באתחול מנוע Whisper: {e}")
            
            # וידוא שלפחות מנוע אחד זמין
            if not self.engines:
                logging.warning("אין מנועי זיהוי דיבור זמינים")
            else:
                logging.info(f"שירות דיבור לטקסט אותחל עם מנוע ברירת מחדל: {self.default_engine}")
                
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות דיבור לטקסט: {e}")

    def _init_vosk(self):
        """אתחול מנוע Vosk"""
        try:
            from vosk import Model, KaldiRecognizer
            
            # הכנת נתיב למודל
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            model_dir = os.path.join(base_dir, "data", "models", "vosk")
            
            # אם המודל לא קיים, מוריד אותו
            if not os.path.exists(model_dir):
                os.makedirs(model_dir, exist_ok=True)
                
                # בדיקה אם יש מודל עברית זמין
                if self.language == "he-IL":
                    logging.info("מוריד מודל עברית עבור Vosk")
                    import requests
                    import zipfile
                    url = "https://alphacephei.com/vosk/models/vosk-model-he-0.22.zip"
                    zip_path = os.path.join(model_dir, "vosk-model-he.zip")
                    
                    # הורדת המודל
                    response = requests.get(url, stream=True)
                    with open(zip_path, "wb") as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            f.write(chunk)
                    
                    # חילוץ המודל
                    with zipfile.ZipFile(zip_path, "r") as zip_ref:
                        zip_ref.extractall(model_dir)
                    
                    # מחיקת קובץ ה-ZIP
                    os.remove(zip_path)
                    
                    # עדכון נתיב המודל
                    model_dir = os.path.join(model_dir, "vosk-model-he-0.22")
            
            # טעינת המודל
            model = Model(model_dir)
            recognizer = KaldiRecognizer(model, self.sample_rate)
            
            # הוספת המנוע לרשימת המנועים הזמינים
            self.engines["vosk"] = {
                "model": model,
                "recognizer": recognizer
            }
            
        except ImportError:
            logging.warning("חבילת Vosk אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "vosk"])
            self._init_vosk()  # ניסיון שני לאתחול

    def _init_google(self):
        """אתחול מנוע Google Speech Recognition"""
        try:
            import speech_recognition as sr
            
            # יצירת מזהה דיבור
            recognizer = sr.Recognizer()
            
            # הוספת המנוע לרשימת המנועים הזמינים
            self.engines["google"] = {
                "recognizer": recognizer
            }
            
        except ImportError:
            logging.warning("חבילת SpeechRecognition אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "SpeechRecognition"])
            self._init_google()  # ניסיון שני לאתחול

    def _init_whisper(self):
        """אתחול מנוע Whisper"""
        try:
            import whisper
            
            # טעינת המודל הקטן ביותר לחיסכון במשאבים
            model = whisper.load_model("tiny")
            
            # הוספת המנוע לרשימת המנועים הזמינים
            self.engines["whisper"] = {
                "model": model
            }
            
        except ImportError:
            logging.warning("חבילת Whisper אינה מותקנת. מתקין...")
            import subprocess
            subprocess.run(["pip", "install", "openai-whisper"])
            self._init_whisper()  # ניסיון שני לאתחול

    def transcribe_audio(self, audio_file, engine=None):
        """המרת קובץ אודיו לטקסט
        
        Args:
            audio_file: נתיב לקובץ אודיו
            engine: מנוע לשימוש (אופציונלי, ברירת מחדל: מנוע ברירת המחדל)
            
        Returns:
            טקסט מזוהה (או רשימת אפשרויות עם רמות ביטחון)
        """
        if not engine:
            engine = self.default_engine
        
        if engine not in self.engines:
            logging.error(f"מנוע {engine} אינו זמין")
            return "שגיאה: מנוע זיהוי הדיבור אינו זמין"
        
        try:
            if engine == "vosk":
                return self._transcribe_with_vosk(audio_file)
            elif engine == "google":
                return self._transcribe_with_google(audio_file)
            elif engine == "whisper":
                return self._transcribe_with_whisper(audio_file)
            else:
                return "שגיאה: מנוע לא מוכר"
                
        except Exception as e:
            logging.error(f"שגיאה בזיהוי דיבור: {e}")
            return f"שגיאה בזיהוי דיבור: {str(e)}"

    def _transcribe_with_vosk(self, audio_file):
        """המרת קובץ אודיו לטקסט באמצעות Vosk
        
        Args:
            audio_file: נתיב לקובץ אודיו
            
        Returns:
            טקסט מזוהה
        """
        recognizer = self.engines["vosk"]["recognizer"]
        
        # קריאת קובץ האודיו
        with wave.open(audio_file, "rb") as wf:
            # וידוא שהאודיו תואם לפרמטרים הצפויים
            if wf.getnchannels() != 1 or wf.getsampwidth() != 2 or wf.getcomptype() != "NONE":
                logging.warning(f"קובץ האודיו לא תואם לפורמט הצפוי. המרה אוטומטית תתבצע.")
                return "שגיאה: פורמט אודיו לא נתמך"
            
            # זיהוי הדיבור
            while True:
                data = wf.readframes(4000)
                if len(data) == 0:
                    break
                if recognizer.AcceptWaveform(data):
                    pass
            
            # קבלת התוצאה הסופית
            result_json = json.loads(recognizer.FinalResult())
            return result_json.get("text", "")

    def _transcribe_with_google(self, audio_file):
        """המרת קובץ אודיו לטקסט באמצעות Google Speech Recognition
        
        Args:
            audio_file: נתיב לקובץ אודיו
            
        Returns:
            טקסט מזוהה
        """
        import speech_recognition as sr
        recognizer = self.engines["google"]["recognizer"]
        
        # טעינת האודיו
        with sr.AudioFile(audio_file) as source:
            audio_data = recognizer.record(source)
            
            # זיהוי הדיבור
            try:
                text = recognizer.recognize_google(audio_data, language=self.language)
                return text
            except sr.UnknownValueError:
                return "לא זוהה דיבור"
            except sr.RequestError as e:
                return f"שגיאה בבקשה לשירות Google: {e}"

    def _transcribe_with_whisper(self, audio_file):
        """המרת קובץ אודיו לטקסט באמצעות Whisper
        
        Args:
            audio_file: נתיב לקובץ אודיו
            
        Returns:
            טקסט מזוהה
        """
        model = self.engines["whisper"]["model"]
        
        # זיהוי הדיבור
        result = model.transcribe(audio_file)
        return result["text"]

    def start_recording(self, duration=5, output_file=None):
        """הקלטת אודיו מהמיקרופון
        
        Args:
            duration: משך ההקלטה בשניות (ברירת מחדל: 5)
            output_file: נתיב לשמירת קובץ האודיו (אופציונלי)
            
        Returns:
            נתיב לקובץ האודיו
        """
        try:
            import pyaudio
            import wave
            
            # אם לא צוין קובץ פלט, יצירת קובץ זמני
            if not output_file:
                output_file = tempfile.mktemp(suffix=".wav")
            
            # הגדרת פרמטרים להקלטה
            CHUNK = 1024
            FORMAT = pyaudio.paInt16
            CHANNELS = 1
            RATE = self.sample_rate
            
            # אתחול PyAudio
            p = pyaudio.PyAudio()
            
            # פתיחת זרם הקלטה
            stream = p.open(format=FORMAT,
                           channels=CHANNELS,
                           rate=RATE,
                           input=True,
                           frames_per_buffer=CHUNK)
            
            logging.info(f"מתחיל הקלטה למשך {duration} שניות...")
            
            # שמירת מסגרות האודיו
            frames = []
            for i in range(0, int(RATE / CHUNK * duration)):
                data = stream.read(CHUNK)
                frames.append(data)
                
            logging.info("הקלטה הסתיימה")
            
            # סגירת הזרם
            stream.stop_stream()
            stream.close()
            p.terminate()
            
            # שמירת הקובץ
            wf = wave.open(output_file, 'wb')
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(p.get_sample_size(FORMAT))
            wf.setframerate(RATE)
            wf.writeframes(b''.join(frames))
            wf.close()
            
            logging.info(f"קובץ אודיו נשמר ב: {output_file}")
            
            return output_file
            
        except Exception as e:
            logging.error(f"שגיאה בהקלטה: {e}")
            return None
    
    def listen_and_transcribe(self, duration=5, engine=None):
        """הקלטה וזיהוי דיבור בפעולה אחת
        
        Args:
            duration: משך ההקלטה בשניות (ברירת מחדל: 5)
            engine: מנוע זיהוי דיבור לשימוש (אופציונלי)
            
        Returns:
            טקסט מזוהה
        """
        # הקלטה
        audio_file = self.start_recording(duration)
        
        if not audio_file:
            return "שגיאה בהקלטה"
        
        # זיהוי דיבור
        text = self.transcribe_audio(audio_file, engine)
        
        # מחיקת קובץ האודיו הזמני
        try:
            os.remove(audio_file)
        except:
            pass
        
        return text
