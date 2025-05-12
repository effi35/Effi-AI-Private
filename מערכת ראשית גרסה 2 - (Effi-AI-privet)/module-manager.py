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
