# יצירת שירות לוגים
create_logging_service() {
    print_header "יצירת שירות לוגים"
    
    # יצירת תיקיית utilities
    mkdir -p "${BASE_DIR}/utilities"
    
    # יצירת קובץ מנהל לוגים
    cat > "${BASE_DIR}/utilities/logging_manager.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מנהל לוגים - שירות לוגים מרכזי למערכת
"""

import os
import logging
import sys
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler
from datetime import datetime

class LoggingManager:
    """מנהל לוגים - שירות לוגים מרכזי למערכת"""
    
    def __init__(self, config=None):
        """אתחול מנהל הלוגים
        
        Args:
            config: תצורת הלוגים (אופציונלי)
        """
        # הגדרת תצורה
        self.config = config or self._get_default_config()
        
        # יצירת תיקיית לוגים אם לא קיימת
        logs_dir = self.config.get("logs_dir", "logs")
        os.makedirs(logs_dir, exist_ok=True)
        
        # אתחול מערכת הלוגים
        self._setup_logging()
    
    def _get_default_config(self):
        """קבלת תצורת ברירת מחדל ללוגים
        
        Returns:
            תצורת ברירת מחדל
        """
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
        return {
            "enabled": True,
            "level": "INFO",
            "logs_dir": os.path.join(base_dir, "logs"),
            "file": "system.log",
            "console": True,
            "rotation": {
                "when": "midnight",
                "interval": 1,
                "backupCount": 7
            }
        }
    
    def _setup_logging(self):
        """הגדרת מערכת הלוגים"""
        # אם הלוגים מושבתים
        if not self.config.get("enabled", True):
            return
        
        # הגדרת רמת הלוג
        level_str = self.config.get("level", "INFO")
        level = getattr(logging, level_str.upper(), logging.INFO)
        
        # יצירת פורמטר
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        
        # יצירת לוגר ראשי
        self.logger = logging.getLogger("effi_ai")
        self.logger.setLevel(level)
        
        # איפוס הנדלרים הקיימים
        for handler in self.logger.handlers[:]:
            self.logger.removeHandler(handler)
        
        # הגדרת הנדלר לקובץ
        if self.config.get("file"):
            log_file = os.path.join(self.config.get("logs_dir", "logs"), self.config.get("file"))
            
            # בדיקה אם להשתמש ברוטציה
            rotation = self.config.get("rotation", {})
            if rotation:
                # רוטציה לפי זמן
                if "when" in rotation:
                    file_handler = TimedRotatingFileHandler(
                        log_file,
                        when=rotation.get("when", "midnight"),
                        interval=rotation.get("interval", 1),
                        backupCount=rotation.get("backupCount", 7),
                        encoding="utf-8"
                    )
                # רוטציה לפי גודל
                else:
                    file_handler = RotatingFileHandler(
                        log_file,
                        maxBytes=rotation.get("maxBytes", 10*1024*1024),  # 10MB
                        backupCount=rotation.get("backupCount", 5),
                        encoding="utf-8"
                    )
            else:
                file_handler = logging.FileHandler(log_file, encoding="utf-8")
            
            file_handler.setFormatter(formatter)
            self.logger.addHandler(file_handler)
        
        # הגדרת הנדלר לקונסול
        if self.config.get("console", True):
            console_handler = logging.StreamHandler(sys.stdout)
            console_handler.setFormatter(formatter)
            self.logger.addHandler(console_handler)
    
    def get_logger(self, name=None):
        """קבלת לוגר
        
        Args:
            name: שם הלוגר (אופציונלי)
            
        Returns:
            אובייקט הלוגר
        """
        if name:
            return logging.getLogger(f"effi_ai.{name}")
        return self.logger
    
    def set_level(self, level):
        """שינוי רמת הלוג
        
        Args:
            level: רמת הלוג החדשה
        """
        level_num = getattr(logging, level.upper(), None)
        if level_num is None:
            self.logger.warning(f"רמת לוג לא חוקית: {level}")
            return
        
        self.logger.setLevel(level_num)
        for handler in self.logger.handlers:
            handler.setLevel(level_num)
        
        self.logger.info(f"רמת הלוג שונתה ל-{level}")

# Singleton
_instance = None

def get_logging_manager(config=None):
    """קבלת מופע יחיד של מנהל הלוגים
    
    Args:
        config: תצורת הלוגים (אופציונלי)
        
    Returns:
        מופע מנהל הלוגים
    """
    global _instance
    if _instance is None:
        _instance = LoggingManager(config)
    return _instance
EOF

    # יצירת קובץ __init__.py בתיקיית utilities
    cat > "${BASE_DIR}/utilities/__init__.py" << 'EOF'
"""חבילת שירותי עזר - לוגים ושירותים שימושיים נוספים"""

from .logging_manager import get_logging_manager

__all__ = ["get_logging_manager"]
EOF

    print_success "שירות לוגים נוצר בהצלחה"
}

# קישור כל הרכיבים יחד
link_components() {
    print_header "קישור רכיבי המערכת"
    
    # יצירת קובץ __init__.py בתיקיית הבסיס
    cat > "${BASE_DIR}/__init__.py" << 'EOF'
"""חבילת Effi-AI Private - מערכת AI פרטית מודולרית"""

__version__ = "1.0.0"
EOF

    # יצירת תיקיית ממשק שורת פקודה
    mkdir -p "${BASE_DIR}/cli"
    
    # יצירת קובץ app.py בתיקיית cli
    cat > "${BASE_DIR}/cli/app.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ממשק שורת פקודה - Effi-AI Private
"""

import os
import sys
import logging
import readline
import json
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.syntax import Syntax

# הוספת תיקיית הפרויקט לנתיב החיפוש
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(base_dir)

# טעינת שירות לוגים
from utilities.logging_manager import get_logging_manager
logger = get_logging_manager().get_logger("cli")

# טעינת שירותים
from models.model_manager import get_model_manager
from services.rag_service import RAGService
from services.hebrew_service import HebrewService

def show_banner():
    """הצגת באנר פתיחה"""
    console = Console()
    
    console.print("\n[bold blue]Effi-AI Private[/] - [yellow]מערכת AI פרטית מודולרית[/]")
    console.print("[dim]גרסה: 1.0.0 | הקלד 'help' או 'עזרה' לקבלת עזרה | הקלד 'exit' או 'יציאה' ליציאה[/]\n")

def get_help():
    """קבלת טקסט עזרה"""
    return """
## עזרה - ממשק שורת פקודה

### פקודות:
- **עזרה** / **help** - הצגת עזרה זו
- **יציאה** / **exit** - יציאה מהמערכת
- **נקה** / **clear** - ניקוי המסך
- **מודל** / **model** - הצגת מידע על המודל הנוכחי
- **שירותים** / **services** - הצגת מידע על השירותים הפעילים
- **שפה** / **language** - החלפת שפה (לא זמין כרגע)

### תכונות:
- תמיכה מלאה בעברית
- שימוש אוטומטי ב-RAG (אחזור מידע מוגבר)
- זיהוי שפה אוטומטי
- היסטוריית שיחה
"""

def interactive_mode():
    """מצב אינטראקטיבי - צ'אט עם המודל"""
    console = Console()
    
    # אתחול שירותים
    model_manager = get_model_manager()
    rag_service = RAGService()
    hebrew_service = HebrewService()
    
    # לקיחת פרומפט ראשוני
    system_prompt = hebrew_service.get_system_prompt()
    
    # היסטוריית שיחה
    history = []
    
    show_banner()
    
    console.print("[bold green]מצב צ'אט מופעל. אנא הקלד את שאלתך או הוראה.[/]")
    
    # לולאת צ'אט
    while True:
        try:
            # קבלת קלט מהמשתמש
            user_input = input("\n[אתה]: ")
            
            # בדיקת פקודות מיוחדות
            if user_input.lower() in ["exit", "quit", "יציאה"]:
                console.print("[bold yellow]יוצא ממצב צ'אט...[/]")
                break
            elif user_input.lower() in ["help", "עזרה"]:
                console.print(Markdown(get_help()))
                continue
            elif user_input.lower() in ["clear", "נקה"]:
                os.system("cls" if os.name == "nt" else "clear")
                show_banner()
                continue
            elif user_input.lower() in ["model", "מודל"]:
                model_info = model_manager.get_model_info()
                console.print(Panel.fit(
                    f"[bold]מודל נוכחי:[/] {model_info['name']}\n"
                    f"[bold]תיאור:[/] {model_info.get('description', 'אין תיאור')}\n"
                    f"[bold]סוג:[/] {model_info.get('type', 'לא ידוע')}",
                    title="מידע על המודל"
                ))
                continue
            elif user_input.strip() == "":
                continue
            
            # עדכון היסטוריה
            history.append({"role": "user", "content": user_input})
            
            # שימוש ב-RAG אם זמין
            context = ""
            try:
                context = rag_service.search_and_format(user_input)
            except:
                pass
            
            # הכנת ההודעה המלאה
            if context:
                full_message = f"{context}\n\nשאלה: {user_input}"
            else:
                full_message = user_input
            
            console.print("[dim]מעבד את השאלה...[/]")
            
            # שליחה למודל
            if len(history) > 1:
                response = model_manager.chat(history)
            else:
                response = model_manager.generate(full_message, system_prompt=system_prompt)
            
            # שיפור תשובה בעברית אם נדרש
            if hebrew_service.is_hebrew(user_input):
                response = hebrew_service.enhance_hebrew_response(user_input, response)
            
            # עדכון היסטוריה
            history.append({"role": "assistant", "content": response})
            
            # הצגת התשובה
            console.print("\n[bold blue][מערכת]:[/]")
            
            # עיבוד קטעי קוד בתשובה
            code_blocks = []
            in_code_block = False
            code_block = ""
            code_lang = ""
            non_code_text = ""
            
            for line in response.split("\n"):
                if line.startswith("```") and not in_code_block:
                    # התחלת בלוק קוד
                    in_code_block = True
                    code_lang = line[3:].strip()
                    if non_code_text:
                        console.print(Markdown(non_code_text))
                        non_code_text = ""
                elif line.startswith("```") and in_code_block:
                    # סיום בלוק קוד
                    in_code_block = False
                    if code_block:
                        console.print(Syntax(code_block, code_lang or "python", theme="monokai", line_numbers=True))
                        code_block = ""
                        code_lang = ""
                elif in_code_block:
                    # שורת קוד
                    code_block += line + "\n"
                else:
                    # טקסט רגיל
                    non_code_text += line + "\n"
            
            # הצגת טקסט אחרון שאינו קוד
            if non_code_text:
                console.print(Markdown(non_code_text))
                
        except KeyboardInterrupt:
            console.print("\n[bold yellow]יוצא ממצב צ'אט...[/]")
            break
        except Exception as e:
            logger.error(f"שגיאה במצב צ'אט: {e}")
            console.print(f"\n[bold red]שגיאה:[/] {str(e)}")

def main():
    """פונקציה ראשית"""
    try:
        # הפעלת מצב אינטראקטיבי
        interactive_mode()
    except KeyboardInterrupt:
        print("\nהתוכנית הופסקה על ידי המשתמש.")
    except Exception as e:
        logger.error(f"שגיאה לא צפויה: {e}")
        print(f"\nשגיאה לא צפויה: {str(e)}")

if __name__ == "__main__":
    main()
EOF

    # יצירת קובץ __init__.py בתיקיית cli
    cat > "${BASE_DIR}/cli/__init__.py" << 'EOF'
"""חבילת ממשק שורת פקודה"""

from .app import main

__all__ = ["main"]
EOF

    print_success "רכיבי המערכת קושרו בהצלחה"
}

# יצירת קובץ הרצה ראשי
create_main_file() {
    print_header "יצירת קובץ הרצה ראשי"
    
    cat > "${BASE_DIR}/run.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
קובץ הרצה ראשי - Effi-AI Private
"""

import os
import sys
import json
import logging
import argparse
import webbrowser
from pathlib import Path

# הוספת תיקיית הפרויקט לנתיב החיפוש
base_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(base_dir)

# טעינת שירות לוגים
from utilities.logging_manager import get_logging_manager
logger = get_logging_manager().get_logger()

def parse_args():
    """פירוש ארגומנטים מהמשתמש"""
    parser = argparse.ArgumentParser(description='Effi-AI Private - מערכת AI פרטית מודולרית')
    parser.add_argument('--cli', action='store_true', help='הפעלת ממשק שורת פקודה')
    parser.add_argument('--server', action='store_true', help='הפעלת שרת בלבד (ללא פתיחת דפדפן)')
    parser.add_argument('--port', type=int, default=7860, help='פורט עבור הממשק הגרפי')
    parser.add_argument('--debug', action='store_true', help='הפעלה במצב דיבאג')
    parser.add_argument('--version', action='store_true', help='הצגת גרסת המערכת')
    
    return parser.parse_args()

def show_banner():
    """הצגת באנר פתיחה"""
    print("\033[1;34m")
    print("  ____  __  __  _       _    ___   ____       _            _        ")
    print(" / ___||  \/  |(_)     / \  |_ _| |  _ \  _ __(_)_   ____ _| |_ ___ ")
    print("| |    | |\/| || |    / _ \  | |  | |_) || '__| \ \ / / _` | __/ _ \\")
    print("| |___ | |  | || |   / ___ \ | |  |  __/ | |  | |\ V / (_| | ||  __/")
    print(" \____||_|  |_||_|  /_/   \_\___| |_|    |_|  |_| \_/ \__,_|\__\___|")
    print("\033[0m")
    print("  \033[1;33mמערכת AI פרטית מודולרית וחכמה\033[0m")
    
    # קריאת גרסה מקובץ התצורה
    try:
        with open(os.path.join(base_dir, "config", "config.json"), "r", encoding="utf-8") as f:
            config = json.load(f)
            version = config.get("version", "1.0.0")
            print(f"  \033[1;33mגרסה: {version}\033[0m\n")
    except:
        print("  \033[1;33mגרסה: 1.0.0\033[0m\n")

def start_cli_mode():
    """הפעלת ממשק שורת פקודה"""
    from cli.app import main as cli_main
    return cli_main()

def start_web_server(port=7860, open_browser=True):
    """הפעלת שרת ווב ופתיחת דפדפן"""
    from ui.gradio_ui import GradioUI
    
    ui = GradioUI()
    
    if open_browser:
        # פתיחת דפדפן
        webbrowser.open(f"http://localhost:{port}")
    
    # הפעלת הממשק
    ui.launch(port=port)

def main():
    """פונקציה ראשית"""
    # פירוש ארגומנטים
    args = parse_args()
    
    # הצגת באנר
    show_banner()
    
    # הצגת גרסה
    if args.version:
        return
    
    # הגדרת רמת לוג
    if args.debug:
        get_logging_manager().set_level("DEBUG")
        logger.debug("מצב דיבאג מופעל")
    
    # הפעלת המערכת
    if args.cli:
        # הפעלת ממשק שורת פקודה
        start_cli_mode()
    else:
        # הפעלת שרת ווב
        start_web_server(args.port, not args.server)

if __name__ == "__main__":
    main()
EOF

    # הפיכת קובץ ההרצה לבר-הרצה
    chmod +x "${BASE_DIR}/run.py"
    
    print_success "קובץ הרצה ראשי נוצר בהצלחה"
}
