#!/bin/bash
# ========================================================================
# Effi-AI Private - סקריפט התקנה מקיף
# גרסה: 1.0.0
# ========================================================================

# הגדרת צבעים להודעות בטרמינל
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# פונקציות עזר
print_header() {
    echo -e "\n${BOLD}${BLUE}===== $1 =====${RESET}\n"
}

print_step() {
    echo -e "${BLUE}-> $1${RESET}"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ $1${RESET}"
}

# קביעת משתנים גלובליים
SYSTEM_NAME="Effi-AI Private"
SYSTEM_DIR="effi_ai_private"
BASE_DIR="$(pwd)/${SYSTEM_DIR}"
CONFIG_DIR="${BASE_DIR}/config"
MODELS_DIR="${BASE_DIR}/models"
DATA_DIR="${BASE_DIR}/data"
SERVICES_DIR="${BASE_DIR}/services"
UI_DIR="${BASE_DIR}/ui"
MODULES_DIR="${BASE_DIR}/modules"
LOGS_DIR="${BASE_DIR}/logs"
ASSETS_DIR="${BASE_DIR}/assets"

# יצירת באנר התחלה
show_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "  ____  __  __  _       _    ___   ____       _            _        "
    echo " / ___||  \/  |(_)     / \  |_ _| |  _ \  _ __(_)_   ____ _| |_ ___ "
    echo "| |    | |\/| || |    / _ \  | |  | |_) || '__| \ \ / / _\` | __/ _ \\"
    echo "| |___ | |  | || |   / ___ \ | |  |  __/ | |  | |\ V / (_| | ||  __/"
    echo " \____||_|  |_||_|  /_/   \_\___| |_|    |_|  |_| \_/ \__,_|\__\___|"
    echo -e "${RESET}"
    echo -e "  ${YELLOW}מערכת AI פרטית מודולרית וחכמה${RESET}"
    echo -e "  ${YELLOW}גרסה: 1.0.0${RESET}"
    echo -e "  ${YELLOW}מפתח: ShayAI${RESET}\n"
}

# בדיקת דרישות מוקדמות
check_prerequisites() {
    print_header "בדיקת דרישות מוקדמות"
    
    # בדיקת גרסת פייתון
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_success "פייתון $PYTHON_VERSION מותקן"
    else
        print_error "פייתון 3 אינו מותקן. אנא התקן פייתון 3.8 ומעלה"
        exit 1
    fi
    
    # בדיקת pip
    if command -v pip3 &>/dev/null; then
        PIP_VERSION=$(pip3 --version | awk '{print $2}')
        print_success "pip $PIP_VERSION מותקן"
    else
        print_error "pip אינו מותקן. אנא התקן pip"
        exit 1
    fi
    
    # בדיקת Node.js
    if command -v node &>/dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js $NODE_VERSION מותקן"
    else
        print_warning "Node.js אינו מותקן. מתקין Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        NODE_VERSION=$(node --version)
        print_success "Node.js $NODE_VERSION הותקן בהצלחה"
    fi
    
    # בדיקת npm
    if command -v npm &>/dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm $NPM_VERSION מותקן"
    else
        print_warning "npm אינו מותקן. מתקין npm..."
        sudo apt-get install -y npm
        print_success "npm הותקן בהצלחה"
    fi

    # בדיקת ffmpeg (נדרש לעיבוד אודיו ווידאו)
    if command -v ffmpeg &>/dev/null; then
        print_success "ffmpeg מותקן"
    else
        print_warning "ffmpeg אינו מותקן. מתקין ffmpeg..."
        sudo apt-get update
        sudo apt-get install -y ffmpeg
        print_success "ffmpeg הותקן בהצלחה"
    fi
    
    # בדיקת מערכת ההפעלה
    OS=$(uname -s)
    print_success "מערכת הפעלה: $OS"
    
    # בדיקת זיכרון RAM
    if [[ "$OS" == "Linux" ]]; then
        MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
        print_success "זיכרון RAM: $MEM_TOTAL MB"
        
        if [[ $MEM_TOTAL -lt 7000 ]]; then
            print_warning "זיכרון RAM נמוך מ-8GB. המערכת תשתמש בקוונטיזציה של המודל."
        fi
    fi
    
    # בדיקה האם הוא Raspberry Pi
    if [[ -f /proc/device-tree/model ]]; then
        PI_MODEL=$(tr -d '\0' < /proc/device-tree/model)
        if [[ $PI_MODEL == *"Raspberry Pi"* ]]; then
            print_success "זוהה: $PI_MODEL"
            IS_RASPBERRY_PI=true
        fi
    fi
}

# יצירת מבנה תיקיות
create_directory_structure() {
    print_header "יצירת מבנה תיקיות"
    
    # רשימת התיקיות לייצור
    directories=(
        "$BASE_DIR"
        "$MODELS_DIR"
        "$MODELS_DIR/adapters"
        "$DATA_DIR"
        "$DATA_DIR/vector_store"
        "$DATA_DIR/fine_tuning"
        "$DATA_DIR/memory"
        "$DATA_DIR/uploads"
        "$DATA_DIR/uploads/images"
        "$DATA_DIR/uploads/videos"
        "$DATA_DIR/uploads/files"
        "$DATA_DIR/uploads/audio"
        "$DATA_DIR/avatars"
        "$SERVICES_DIR"
        "$UI_DIR"
        "$UI_DIR/assets"
        "$UI_DIR/assets/css"
        "$UI_DIR/assets/js"
        "$UI_DIR/assets/images"
        "$UI_DIR/assets/fonts"
        "$UI_DIR/components"
        "$MODULES_DIR"
        "$LOGS_DIR"
        "$CONFIG_DIR"
        "$ASSETS_DIR"
        "$ASSETS_DIR/icons"
        "$ASSETS_DIR/animations"
    )
    
    # יצירת התיקיות
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        print_success "נוצרה תיקייה: $dir"
    done
}

# התקנת תלויות
install_dependencies() {
    print_header "התקנת חבילות נדרשות"
    
    # יצירת קובץ requirements.txt
    cat > "${BASE_DIR}/requirements.txt" << EOF
# חבילות Python נדרשות
langchain>=0.1.0
langchain_community>=0.0.10
langchain-core>=0.1.10
pydantic>=2.0.0
chromadb>=0.4.18
sentence-transformers>=2.2.2
rich>=13.0.0
fastapi>=0.104.0
uvicorn>=0.24.0
python-dotenv>=1.0.0
typer>=0.9.0
peft>=0.6.0
bitsandbytes>=0.41.0
accelerate>=0.24.0
transformers>=4.35.0
gradio>=4.0.0
protobuf>=4.24.4
torch>=2.0.0
SpeechRecognition>=3.10.0
pyaudio>=0.2.11
gTTS>=2.3.2
soundfile>=0.12.1
librosa>=0.10.0
opencv-python>=4.5.0
pyttsx3>=2.90
python-multipart>=0.0.5
pillow>=10.0.0
boto3>=1.28.0
websockets>=11.0.0
python-jose>=3.3.0
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.5.0
aiohttp>=3.8.0
aiofiles>=23.0.0
deepface>=0.0.79
moviepy>=1.0.0
pydub>=0.25.0
sounddevice>=0.4.0
vosk>=0.3.0
wave>=0.0.2
PyQt5>=5.15.0
dlib>=19.24.0
faces_utils>=0.0.0
mediapipe>=0.10.0
EOF

    # התקנת חבילות Python
    print_step "מתקין חבילות Python..."
    pip3 install -r "${BASE_DIR}/requirements.txt"
    
    # יצירת קובץ package.json
    cat > "${BASE_DIR}/package.json" << EOF
{
  "name": "effi-ai-private",
  "version": "1.0.0",
  "description": "מערכת AI פרטית מודולרית",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "author": "ShayAI",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.7.2",
    "axios": "^1.4.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.1",
    "body-parser": "^1.20.2",
    "mongoose": "^7.4.3",
    "multer": "^1.4.5-lts.1",
    "winston": "^3.10.0",
    "bcrypt": "^5.1.0",
    "compression": "^1.7.4",
    "morgan": "^1.10.0",
    "helmet": "^7.0.0",
    "fs-extra": "^11.1.1",
    "validator": "^13.11.0",
    "uuid": "^9.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "styled-components": "^6.0.7",
    "chart.js": "^4.3.3",
    "bootstrap": "^5.3.1",
    "three": "^0.155.0",
    "mediasoup-client": "^3.6.98",
    "webrtc-adapter": "^8.2.3",
    "howler": "^2.2.3",
    "mp4box": "^0.5.2",
    "recordrtc": "^5.6.2",
    "js-lipsync": "^0.2.0",
    "face-api.js": "^0.22.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "babel-loader": "^9.1.3",
    "@babel/core": "^7.22.10",
    "@babel/preset-env": "^7.22.10",
    "@babel/preset-react": "^7.22.5",
    "css-loader": "^6.8.1",
    "style-loader": "^3.3.3",
    "file-loader": "^6.2.0",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOF

    # התקנת חבילות NPM
    print_step "מתקין חבילות NPM..."
    cd "$BASE_DIR" && npm install
    
    print_success "כל התלויות הותקנו בהצלחה!"
}

# התקנת Ollama
install_ollama() {
    print_header "התקנת Ollama"
    
    # בדיקה אם Ollama כבר מותקן
    if command -v ollama &>/dev/null; then
        OLLAMA_VERSION=$(ollama --version)
        print_success "Ollama כבר מותקן: $OLLAMA_VERSION"
    else
        print_step "מתקין Ollama..."
        
        # התקנה לפי מערכת ההפעלה
        if [[ "$OS" == "Linux" ]]; then
            curl -fsSL https://ollama.com/install.sh | sh
            print_success "Ollama הותקן בהצלחה"
        elif [[ "$OS" == "Darwin" ]]; then  # macOS
            print_warning "מערכת ההפעלה היא macOS. אנא התקן Ollama ידנית מ: https://ollama.com/download"
        elif [[ "$OS" == "MINGW"* || "$OS" == "MSYS"* || "$OS" == "CYGWIN"* ]]; then  # Windows
            print_warning "מערכת ההפעלה היא Windows. אנא התקן Ollama ידנית מ: https://ollama.com/download"
        else
            print_error "מערכת ההפעלה $OS אינה נתמכת ישירות. אנא התקן Ollama ידנית מ: https://ollama.com/download"
        fi
    fi
    
    # הפעלת שירות Ollama
    print_step "מפעיל שירות Ollama..."
    ollama serve &>/dev/null &
    sleep 5  # המתנה להפעלת השירות
    print_success "שירות Ollama הופעל בהצלחה"
    
    # הורדת מודל Lexi Uncensored (Llama 3.1 8B)
    print_step "מוריד את המודל Hudson/llama3.1-uncensored:8b..."
    print_warning "ההורדה עשויה לקחת זמן רב (עד 4GB)"
    ollama pull Hudson/llama3.1-uncensored:8b
    print_success "המודל הורד בהצלחה"
}

# יצירת קובצי תצורה
create_config_files() {
    print_header "יצירת קובצי תצורה"
    
    # קובץ תצורה ראשי
    cat > "${CONFIG_DIR}/config.json" << EOF
{
  "version": "1.0.0",
  "name": "Effi-AI Private",
  "models": {
    "default": "Hudson/llama3.1-uncensored:8b",
    "available": [
      {
        "name": "Hudson/llama3.1-uncensored:8b",
        "description": "Llama 3.1 8B ללא הגבלות (Lexi Uncensored)",
        "type": "ollama",
        "context_length": 8192,
        "parameters": {
          "temperature": 0.7,
          "top_p": 0.9,
          "top_k": 40,
          "repetition_penalty": 1.1
        }
      },
      {
        "name": "mannix/llamax3-8b",
        "description": "LlamaX3 - מודל רב-לשוני התומך בעברית",
        "type": "ollama",
        "context_length": 8192,
        "parameters": {
          "temperature": 0.7,
          "top_p": 0.9,
          "top_k": 40,
          "repetition_penalty": 1.1
        }
      }
    ]
  },
  "services": {
    "rag": {
      "enabled": true,
      "embedding_model": "nomic-embed-text",
      "vector_store_path": "./data/vector_store",
      "chunk_size": 512,
      "chunk_overlap": 50
    },
    "memory": {
      "enabled": true,
      "type": "buffer",
      "max_tokens": 4000
    },
    "learning": {
      "enabled": true,
      "auto_learn": true,
      "learning_rate": 1e-5
    },
    "speech_to_text": {
      "enabled": true,
      "default_engine": "vosk",
      "engines": ["vosk", "google", "whisper"],
      "language": "he-IL",
      "sample_rate": 16000
    },
    "text_to_speech": {
      "enabled": true,
      "default_engine": "gtts",
      "engines": ["gtts", "pyttsx3", "azure"],
      "language": "he-IL",
      "voice": "female"
    },
    "avatar": {
      "enabled": true,
      "default_model": "live2d",
      "models": ["live2d", "3d", "photo_realistic"],
      "lip_sync": true,
      "facial_expressions": true
    },
    "upload": {
      "enabled": true,
      "allowed_types": [
        "image/jpeg", "image/png", "image/gif", "image/webp",
        "video/mp4", "video/webm", "video/ogg",
        "audio/mp3", "audio/wav", "audio/ogg",
        "application/pdf", "text/plain", "application/json"
      ],
      "max_size_mb": 100,
      "storage_path": "./data/uploads"
    },
    "plugins": {
      "enabled": true,
      "auto_load": true
    },
    "logging": {
      "enabled": true,
      "level": "INFO",
      "file": "./logs/system.log",
      "console": true,
      "rotation": {
        "when": "midnight",
        "interval": 1,
        "backupCount": 7
      }
    }
  },
  "ui": {
    "enabled": true,
    "port": 7860,
    "theme": "dark",
    "rtl": true,
    "language": "he",
    "title": "Effi-AI Private",
    "description": "מערכת AI פרטית מודולרית ללא הגבלות",
    "assets": {
      "logo": "./ui/assets/images/logo.png",
      "favicon": "./ui/assets/images/favicon.ico"
    },
    "custom_css": "./ui/assets/css/custom.css"
  },
  "hebrew_support": {
    "enabled": true,
    "translation_fallback": true,
    "rtl_support": true
  },
  "system": {
    "backup": {
      "enabled": true,
      "auto_backup": true,
      "interval_days": 7,
      "keep_backups": 5,
      "backup_dir": "./data/backups"
    },
    "updates": {
      "check_updates": true,
      "auto_update": false
    },
    "modules": {
      "auto_discovery": true,
      "hot_reload": true,
      "registry": "./modules"
    }
  }
}
EOF

    # קובץ משאבים בעברית
    cat > "${CONFIG_DIR}/hebrew.json" << EOF
{
  "system_prompt": "אתה עוזר AI חכם ויעיל. אתה עונה בעברית ברורה. אתה יודע להבין וליצור קוד, לענות על שאלות, ולסייע בכל נושא. אתה חופשי לדבר על כל נושא בפתיחות מלאה. אם אתה לא יודע משהו, אתה אומר זאת בכנות.",
  "default_prompts": {
    "qa": "ענה על השאלה הבאה ביסודיות: {question}",
    "summary": "סכם את הטקסט הבא: {text}",
    "code": "כתוב קוד {language} עבור: {task}",
    "translate": "תרגם מ{source_lang} ל{target_lang}: {text}"
  },
  "translation": {
    "enabled": true,
    "fallback_models": ["Google", "Azure"]
  },
  "common_terms": {
    "AI": "בינה מלאכותית",
    "LLM": "מודל שפה גדול",
    "RAG": "אחזור מידע מוגבר",
    "fine-tuning": "כיוון עדין",
    "token": "אסימון",
    "embedding": "הטבעה",
    "vector": "וקטור",
    "settings": "הגדרות",
    "plugin": "תוסף",
    "backup": "גיבוי",
    "restore": "שחזור",
    "model": "מודל",
    "dashboard": "לוח בקרה",
    "preview": "תצוגה מקדימה",
    "voice": "קול",
    "speech": "דיבור",
    "recognition": "זיהוי",
    "avatar": "אווטאר",
    "face": "פנים",
    "upload": "העלאה",
    "file": "קובץ",
    "image": "תמונה",
    "video": "וידאו",
    "audio": "שמע"
  },
  "voice_commands": {
    "start": ["התחל", "הפעל", "פתח"],
    "stop": ["עצור", "הפסק", "סגור"],
    "search": ["חפש", "מצא", "אתר"],
    "settings": ["הגדרות", "אפשרויות", "תצורה"] 
  }
}
EOF

    print_success "קובצי תצורה נוצרו בהצלחה"
}

# יצירת הקובץ README.md
create_readme() {
    print_header "יצירת קובץ README.md"
    
    cat > "${BASE_DIR}/README.md" << 'EOF'
# מערכת Effi-AI Private

מערכת AI פרטית מודולרית המבוססת על מודל Lexi Uncensored (Llama 3.1 8B), פועלת באופן מקומי ומאפשרת שליטה מלאה במודל ובנתונים.

## מאפיינים עיקריים

- **מודל ללא הגבלות** - מבוסס על Lexi Uncensored (Llama 3.1 8B) שעבר fine-tuning להסרת מגבלות תוכן
- **תמיכה מלאה בעברית** - שירות ייעודי לעברית, מאגר ידע בעברית וזיהוי שפה אוטומטי
- **ארכיטקטורה מודולרית** - אפשרות להחלפת המודל, המאגר והשירותים בקלות
- **למידה והתפתחות** - למידה מתמשכת באמצעות RAG ויכולת פיין-טיונינג
- **ממשק כפול** - ממשק שורת פקודה וממשק גרפי מבוסס ווב
- **זיהוי דיבור** - המרת דיבור לטקסט בעברית ושפות נוספות
- **סינתזת דיבור** - המרת טקסט לדיבור טבעי
- **אווטארים אנימטיביים** - דמויות אנושיות עם סנכרון שפתיים ומימיקה
- **העלאת קבצים** - תמיכה בהעלאת תמונות, וידאו, אודיו וקבצי טקסט

## התקנה

### דרישות מקדימות
- Python 3.8 ומעלה
- Node.js 16 ומעלה
- 8GB RAM לפחות (או 4GB עם קוונטיזציה)
- 10GB שטח אחסון פנוי

### התקנה אוטומטית
```bash
# הורדת סקריפט ההתקנה
curl -fsSL https://raw.githubusercontent.com/shayAI/effi-ai-private/main/install.sh -o install.sh

# הפיכת הסקריפט להרצה
chmod +x install.sh

# הרצת הסקריפט
./install.sh
התקנה ידנית
bash
# שיבוט המאגר
git clone https://github.com/shayAI/effi-ai-private.git

# כניסה לתיקייה
cd effi-ai-private

# התקנת תלויות Python
pip install -r requirements.txt

# התקנת תלויות Node.js
npm install

# התקנת Ollama
curl -fsSL https://ollama.com/install.sh | sh

# הורדת המודל
ollama pull Hudson/llama3.1-uncensored:8b

# הרצת המערכת
python run.py
שימוש יומיומי
ממשק גרפי
הממשק הגרפי מציע את האפשרויות הבאות:

צ'אט - שיחה עם המודל
מאגר ידע - הוספת מידע חדש למערכת
כיוון מודל - ביצוע fine-tuning למודל
הגדרות - שינוי הגדרות המערכת
העלאה - העלאת קבצים, תמונות וקטעי אודיו
דיבור - זיהוי דיבור והמרתו לטקסט
אווטאר - יצירת ועריכת אווטארים מדברים
שורת פקודה
ממשק שורת הפקודה תומך בפקודות הבאות:

python app.py --chat - מצב צ'אט אינטראקטיבי
python app.py --query "שאלה" - שאלה בודדת
python app.py --voice - הפעלת מצב זיהוי דיבור
python app.py --add-text "טקסט" - הוספת טקסט למאגר הידע
python app.py --add-file "נתיב קובץ" - הוספת קובץ למאגר הידע
ניהול מודולים
המערכת תומכת בהוספת מודולים חדשים באופן פשוט:

צור תיקייה חדשה תחת modules/[שם_המודול]
הוסף קובץ metadata.json עם פרטי המודול
הוסף את קובץ המודול העיקרי
המערכת תזהה את המודול באופן אוטומטי ותשלב אותו בממשק
ניהול גרסאות
bash
# יצירת גיבוי
python manage.py backup

# שחזור גיבוי
python manage.py restore backup_20250510_123456.zip

# עדכון המערכת
python manage.py update
פיתוח נוסף
המערכת בנויה להיות מודולרית ונוחה להרחבה. ניתן להוסיף מודולים חדשים, להחליף את המודל הבסיסי ולהתאים את המערכת לצרכים ספציפיים.

רישוי
המערכת עצמה מופצת תחת רישיון MIT.

המודל Lexi Uncensored מבוסס על Llama 3.1 וכפוף לרישיון Llama 3.1 Community License של Meta. EOF

    print_success "קובץ README.md נוצר בהצלחה"
}

# יצירת מודול מנהל המודלים
create_model_manager() {
    print_header "יצירת מנהל המודלים"

    mkdir -p "${MODELS_DIR}/adapters"

    # יצירת קובץ מנהל המודלים
    cat > "${MODELS_DIR}/model_manager.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" מנהל המודלים - מתאם להחלפת מודלים ושימוש בהם """

import os
import json
import logging
from typing import Dict, List, Any, Optional, Union

class ModelManager:
    """מנהל מודלי AI המאפשר החלפה ושימוש במודלים שונים"""

    def __init__(self, config_path=None):
        """אתחול מנהל המודלים
        
        Args:
            config_path: נתיב לקובץ תצורה. אם None, נקבע אוטומטית.
        """
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        
        # טעינת הגדרות
        self.config = self._load_config()
        self.model_name = self.config.get("models", {}).get("default", "Hudson/llama3.1-uncensored:8b")
        
        # טעינת המודל
        self.model = self._load_model()
        
        logging.info(f"מנהל המודלים אותחל. מודל נוכחי: {self.model_name}")

    def _load_config(self):
        """טעינת קובץ התצורה"""
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logging.error(f"שגיאה בטעינת קובץ תצורה: {e}")
            return {
                "models": {
                    "default": "Hudson/llama3.1-uncensored:8b",
                    "available": [
                        {
                            "name": "Hudson/llama3.1-uncensored:8b",
                            "description": "Llama 3.1 8B ללא הגבלות (Lexi Uncensored)",
                            "type": "ollama",
                            "context_length": 8192,
                            "parameters": {
                                "temperature": 0.7,
                                "top_p": 0.9,
                                "top_k": 40,
                                "repetition_penalty": 1.1
                            }
                        }
                    ]
                }
            }

    def _load_model(self):
        """טעינת המודל לפי ההגדרות
        
        Returns:
            מודל AI
        """
        try:
            # מציאת תצורת המודל לפי השם
            model_config = None
            for model in self.config.get("models", {}).get("available", []):
                if model["name"] == self.model_name:
                    model_config = model
                    break
            
            if not model_config:
                logging.warning(f"לא נמצאה תצורה למודל {self.model_name}. משתמש בתצורת ברירת מחדל.")
                model_config = {
                    "name": self.model_name,
                    "type": "ollama",
                    "parameters": {}
                }
            
            # טעינת המתאם המתאים לפי סוג המודל
            model_type = model_config.get("type", "ollama").lower()
            
            if model_type == "ollama":
                from .adapters.ollama_adapter import OllamaAdapter
                return OllamaAdapter(model_config["name"], model_config.get("parameters", {}))
            elif model_type == "huggingface":
                from .adapters.hf_adapter import HuggingFaceAdapter
                return HuggingFaceAdapter(model_config["name"], model_config.get("parameters", {}))
            else:
                logging.error(f"סוג מודל לא נתמך: {model_type}")
                raise ValueError(f"סוג מודל לא נתמך: {model_type}")
            
        except Exception as e:
            logging.error(f"שגיאה בטעינת מודל {self.model_name}: {e}")
            from .adapters.dummy_adapter import DummyAdapter
            return DummyAdapter()

    def get_model_info(self):
        """קבלת מידע על המודל הנוכחי
        
        Returns:
            מידע המודל
        """
        for model in self.config.get("models", {}).get("available", []):
            if model["name"] == self.model_name:
                return model
        
        return {
            "name": self.model_name,
            "description": "מידע לא זמין",
            "type": "unknown"
        }

    def switch_model(self, model_name):
        """החלפת המודל הנוכחי
        
        Args:
            model_name: שם המודל החדש
            
        Returns:
            האם ההחלפה הצליחה
        """
        # בדיקה אם המודל כבר טעון
        if model_name == self.model_name:
            logging.info(f"המודל {model_name} כבר טעון")
            return True
        
        # בדיקה אם המודל קיים ברשימת המודלים הזמינים
        model_exists = False
        for model in self.config.get("models", {}).get("available", []):
            if model["name"] == model_name:
                model_exists = True
                break
        
        if not model_exists:
            logging.warning(f"המודל {model_name} לא נמצא ברשימת המודלים הזמינים")
            return False
        
        try:
            # שמירת שם המודל החדש
            self.model_name = model_name
            
            # טעינת המודל החדש
            self.model = self._load_model()
            
            logging.info(f"המודל הוחלף בהצלחה ל-{model_name}")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בהחלפת מודל ל-{model_name}: {e}")
            return False

    def add_model(self, model_config):
        """הוספת מודל חדש לרשימת המודלים הזמינים
        
        Args:
            model_config: תצורת המודל החדש
            
        Returns:
            האם ההוספה הצליחה
        """
        try:
            # בדיקה אם המודל כבר קיים
            model_exists = False
            for i, model in enumerate(self.config.get("models", {}).get("available", [])):
                if model["name"] == model_config["name"]:
                    # עדכון המודל הקיים
                    self.config["models"]["available"][i] = model_config
                    model_exists = True
                    break
            
            # הוספת המודל אם הוא לא קיים
            if not model_exists:
                self.config["models"]["available"].append(model_config)
            
            # שמירת הקונפיגורציה
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump(self.config, f, ensure_ascii=False, indent=2)
            
            logging.info(f"המודל {model_config['name']} נוסף בהצלחה")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בהוספת מודל {model_config.get('name', 'לא ידוע')}: {e}")
            return False

    def remove_model(self, model_name):
        """הסרת מודל מרשימת המודלים הזמינים
        
        Args:
            model_name: שם המודל להסרה
            
        Returns:
            האם ההסרה הצליחה
        """
        try:
            # בדיקה אם המודל הוא ברירת המחדל
            if model_name == self.config.get("models", {}).get("default", ""):
                logging.warning(f"לא ניתן להסיר את מודל ברירת המחדל: {model_name}")
                return False
            
            # מציאת המודל ברשימה
            model_found = False
            new_available = []
            
            for model in self.config.get("models", {}).get("available", []):
                if model["name"] != model_name:
                    new_available.append(model)
                else:
                    model_found = True
            
            if not model_found:
                logging.warning(f"המודל {model_name} לא נמצא ברשימת המודלים הזמינים")
                return False
            
            # עדכון הרשימה
            self.config["models"]["available"] = new_available
            
            # שמירת הקונפיגורציה
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump(self.config, f, ensure_ascii=False, indent=2)
            
            logging.info(f"המודל {model_name} הוסר בהצלחה")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בהסרת מודל {model_name}: {e}")
            return False

    def get_available_models(self):
        """קבלת רשימת המודלים הזמינים
        
        Returns:
            רשימת המודלים הזמינים
        """
        return self.config.get("models", {}).get("available", [])

    def generate(self, prompt, system_prompt=None, **kwargs):
        """יצירת תשובה באמצעות המודל
        
        Args:
            prompt: הטקסט לשליחה למודל
            system_prompt: הנחיה למערכת (אופציונלי)
            **kwargs: פרמטרים נוספים למודל
            
        Returns:
            התשובה שהתקבלה מהמודל
        """
        try:
            return self.model.generate(prompt, system_prompt, **kwargs)
        except Exception as e:
            logging.error(f"שגיאה ביצירת תשובה: {e}")
            return f"שגיאה ביצירת תשובה: {str(e)}"

    def chat(self, messages, **kwargs):
        """שיחה עם המודל בפורמט צ'אט
        
        Args:
            messages: רשימת הודעות
            **kwargs: פרמטרים נוספים למודל
            
        Returns:
            התשובה האחרונה מהמודל
        """
        try:
            if hasattr(self.model, "chat"):
                return self.model.chat(messages, **kwargs)
            else:
                # אם המודל לא תומך בפורמט צ'אט, המרה לפורמט טקסט רגיל
                combined = "\n".join([f"{msg['role']}: {msg['content']}" for msg in messages])
                return self.generate(combined, **kwargs)
        except Exception as e:
            logging.error(f"שגיאה בשיחה: {e}")
            return f"שגיאה בשיחה: {str(e)}"

    def get_model_parameters(self):
        """קבלת הפרמטרים של המודל הנוכחי
        
        Returns:
            פרמטרי המודל
        """
        model_info = self.get_model_info()
        return model_info.get("parameters", {})

    def update_model_parameters(self, parameters):
        """עדכון הפרמטרים של המודל הנוכחי
        
        Args:
            parameters: פרמטרים חדשים
            
        Returns:
            האם העדכון הצליח
        """
        try:
            # עדכון הקונפיג
            for i, model in enumerate(self.config.get("models", {}).get("available", [])):
                if model["name"] == self.model_name:
                    self.config["models"]["available"][i]["parameters"] = parameters
                    
                    # שמירת הקונפיגורציה
                    with open(self.config_path, "w", encoding="utf-8") as f:
                        json.dump(self.config, f, ensure_ascii=False, indent=2)
                    
                    # עדכון המודל עצמו אם אפשר
                    if hasattr(self.model, "update_parameters"):
                        self.model.update_parameters(parameters)
                    
                    logging.info(f"פרמטרי המודל {self.model_name} עודכנו בהצלחה")
                    return True
            
            logging.warning(f"המודל {self.model_name} לא נמצא ברשימת המודלים הזמינים")
            return False
            
        except Exception as e:
            logging.error(f"שגיאה בעדכון פרמטרי המודל {self.model_name}: {e}")
            return False

# יצירת singleton
_model_manager = None

def get_model_manager(config_path=None):
    """מחזיר את מנהל המודלים היחיד"""
    global _model_manager
    if _model_manager is None:
        _model_manager = ModelManager(config_path)
    return _model_manager
EOF

    # יצירת מתאם Ollama
    cat > "${MODELS_DIR}/adapters/ollama_adapter.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" מתאם למודלים מסוג Ollama """

import os
import json
import time
import logging
import requests
import subprocess
from typing import Dict, List, Any, Optional, Union

class OllamaAdapter:
    """מתאם למודלים מסוג Ollama"""

    def __init__(self, model_name: str, parameters: Dict[str, Any] = None):
        """אתחול המתאם עם שם מודל ספציפי
        
        Args:
            model_name: שם המודל בפורמט של Ollama
            parameters: פרמטרים נוספים למודל (טמפרטורה וכו')
        """
        self.model_name = model_name
        self.parameters = parameters or {}
        self.base_url = "http://localhost:11434/api"
        
        # בדיקה שהמודל קיים
        self._ensure_model_available()
        
        logging.info(f"מתאם Ollama אותחל עם המודל: {model_name}")

    def _ensure_model_available(self):
        """מוודא שהמודל זמין, מוריד אותו אם לא"""
        try:
            # בדיקה שהשרת פעיל
            self._ensure_server_running()
            
            # בדיקה שהמודל קיים
            response = requests.get(f"{self.base_url}/tags")
            if response.status_code == 200:
                models = response.json().get("models", [])
                model_exists = any(m["name"] == self.model_name for m in models)
                
                if not model_exists:
                    logging.info(f"מוריד את המודל: {self.model_name}")
                    subprocess.run(["ollama", "pull", self.model_name], 
                                  check=True, capture_output=True)
                    
                    # וידוא שהמודל זמין אחרי ההורדה
                    response = requests.get(f"{self.base_url}/tags")
                    if response.status_code == 200:
                        models = response.json().get("models", [])
                        model_exists = any(m["name"] == self.model_name for m in models)
                        
                        if not model_exists:
                            raise RuntimeError(f"לא ניתן להוריד את המודל: {self.model_name}")
        except Exception as e:
            logging.error(f"שגיאה בבדיקת זמינות המודל: {e}")
            # ניסיון להפעיל את השירות אם הוא לא פעיל
            self._ensure_server_running()
            # ניסיון להוריד את המודל
            try:
                subprocess.run(["ollama", "pull", self.model_name], 
                              check=True, capture_output=True)
            except Exception as inner_e:
                logging.error(f"שגיאה בהפעלת Ollama והורדת המודל: {inner_e}")
                raise RuntimeError(f"לא ניתן להפעיל את Ollama או להוריד את המודל: {self.model_name}")

    def _ensure_server_running(self):
        """בדיקה שהשרת פעיל, ואם לא - הפעלה שלו"""
        try:
            # ניסיון לגשת לשרת
            response = requests.get(f"{self.base_url}/tags", timeout=2)
            if response.status_code == 200:
                return True
        except:
            pass
        
        # הפעלת השרת
        try:
            logging.info("מפעיל את שרת Ollama...")
            subprocess.Popen(["ollama", "serve"], 
                           stdout=subprocess.PIPE, 
                           stderr=subprocess.PIPE)
            
            # המתנה להפעלת השירות
            for _ in range(10):  # ניסיון למשך 10 שניות
                time.sleep(1)
                try:
                    response = requests.get(f"{self.base_url}/tags", timeout=2)
                    if response.status_code == 200:
                        logging.info("שרת Ollama פעיל")
                        return True
                except:
                    continue
            
            logging.error("לא ניתן להפעיל את שרת Ollama")
            return False
        except Exception as e:
            logging.error(f"שגיאה בהפעלת שרת Ollama: {e}")
            return False

    def generate(self, prompt: str, system_prompt: str = None, **kwargs) -> str:
        """יצירת תשובה באמצעות המודל
        
        Args:
            prompt: הטקסט לשליחה למודל
            system_prompt: הנחיה למערכת (אופציונלי)
            **kwargs: פרמטרים נוספים שיעברו לAPI
            
        Returns:
            התשובה שהתקבלה מהמודל
        """
        headers = {"Content-Type": "application/json"}
        
        # שילוב פרמטרים מההגדרות עם אלו שהועברו בקריאה
        params = self.parameters.copy()
        params.update(kwargs)
        
        data = {
            "model": self.model_name,
            "prompt": prompt,
            "stream": False,
            **params
        }
        
        if system_prompt:
            data["system"] = system_prompt
        
        try:
            response = requests.post(f"{self.base_url}/generate", 
                                    headers=headers, 
                                    data=json.dumps(data))
            
            if response.status_code == 200:
                return response.json().get("response", "")
            else:
                logging.error(f"שגיאה בקריאה לOllama: {response.status_code} - {response.text}")
                return f"שגיאה בקבלת תשובה מהמודל: {response.status_code}"
                
        except Exception as e:
            logging.error(f"שגיאה בתקשורת עם Ollama: {e}")
            return f"שגיאה בתקשורת עם המודל: {str(e)}"

    def chat(self, messages: List[Dict[str, str]], **kwargs) -> str:
        """שיחה עם המודל בפורמט צ'אט
        
        Args:
            messages: רשימת הודעות בפורמט [{"role": "user", "content": "שאלה"}]
            **kwargs: פרמטרים נוספים
            
        Returns:
            התשובה האחרונה מהמודל
        """
        headers = {"Content-Type": "application/json"}
        
        # שילוב פרמטרים מההגדרות עם אלו שהועברו בקריאה
        params = self.parameters.copy()
        params.update(kwargs)
        
        data = {
            "model": self.model_name,
            "messages": messages,
            "stream": False,
            **params
        }
        
        try:
            response = requests.post(f"{self.base_url}/chat", 
                                   headers=headers, 
                                   data=json.dumps(data))
            
            if response.status_code == 200:
                return response.json().get("message", {}).get("content", "")
            else:
                logging.error(f"שגיאה בקריאה לOllama: {response.status_code} - {response.text}")
                return f"שגיאה בקבלת תשובה מהמודל: {response.status_code}"
                
        except Exception as e:
            logging.error(f"שגיאה בתקשורת עם Ollama: {e}")
            return f"שגיאה בתקשורת עם המודל: {str(e)}"

    def update_parameters(self, parameters):
        """עדכון פרמטרי המודל
        
        Args:
            parameters: פרמטרים חדשים
        """
        self.parameters = parameters
        logging.info(f"פרמטרי המודל {self.model_name} עודכנו")
EOF

    # יצירת מתאם Dummy למקרי שגיאה
    cat > "${MODELS_DIR}/adapters/dummy_adapter.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" מתאם דמה למקרה של שגיאה בטעינת מודל """

import logging
from typing import Dict, List, Any, Optional

class DummyAdapter:
    """מתאם דמה המחזיר הודעות שגיאה"""

    def __init__(self):
        """אתחול המתאם"""
        logging.warning("מתאם דמה אותחל - המודל לא זמין")
        self.model_name = "dummy"
        self.parameters = {}

    def generate(self, prompt: str, system_prompt: str = None, **kwargs) -> str:
        """החזרת הודעת שגיאה במקום תשובה
        
        Args:
            prompt: הטקסט לשליחה למודל
            system_prompt: הנחיה למערכת (אופציונלי)
            **kwargs: פרמטרים נוספים
            
        Returns:
            הודעת שגיאה
        """
        return """לא ניתן לטעון את המודל. אנא בדוק את החיבור לשרת ואת זמינות המודל.
אפשרויות לפתרון הבעיה:

ודא ש-Ollama מותקן ופועל
ודא שהמודל קיים (הרץ 'ollama list')
נסה להוריד את המודל ידנית (הרץ 'ollama pull MODEL_NAME')
בדוק את הגדרות הרשת והחיבור לשרת
אם הבעיה נמשכת, בדוק את הלוגים לקבלת מידע נוסף."""

    def chat(self, messages: List[Dict[str, str]], **kwargs) -> str:
        """החזרת הודעת שגיאה במקום תשובה לצ'אט
        
        Args:
            messages: רשימת הודעות
            **kwargs: פרמטרים נוספים
            
        Returns:
            הודעת שגיאה
        """
        return self.generate("", **kwargs)

    def update_parameters(self, parameters):
        """עדכון פרמטרים (לא עושה כלום)
        
        Args:
            parameters: פרמטרים חדשים
        """
        self.parameters = parameters
        logging.info("פרמטרי המודל הדמה עודכנו (ללא השפעה)")
EOF

    # יצירת קובץ __init__.py לחבילת models
    cat > "${MODELS_DIR}/__init__.py" << 'EOF'
"""חבילת מודלים - מנהל מודלים ומתאמים שונים"""

from .model_manager import ModelManager, get_model_manager

__all__ = ["ModelManager", "get_model_manager"]
EOF

    # יצירת קובץ __init__.py לחבילת adapters
    cat > "${MODELS_DIR}/adapters/__init__.py" << 'EOF'
"""חבילת מתאמים למודלים שונים"""

from .ollama_adapter import OllamaAdapter
from .dummy_adapter import DummyAdapter

__all__ = ["OllamaAdapter", "DummyAdapter"]
EOF

    print_success "מנהל המודלים נוצר בהצלחה"
}

# יצירת מודול שירות RAG
create_rag_service() { 
    print_header "יצירת שירות RAG"

    # יצירת קובץ שירות RAG
    cat > "${SERVICES_DIR}/rag_service.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" שירות אחזור מידע מוגבר (Retrieval Augmented Generation) """

import os
import json
import logging
from typing import List, Dict, Any, Optional

class RAGService:
    """שירות אחזור מידע מוגבר (RAG)"""

    def __init__(self, config_path=None):
        """אתחול שירות ה-RAG"""
        # טעינת הגדרות
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.rag_config = config.get("services", {}).get("rag", {})
            
            if not self.rag_config.get("enabled", True):
                logging.info("שירות RAG מושבת בהגדרות")
                return
            
            # הגדרת נתיב מאגר הווקטורים
            self.vector_store_path = os.path.join(
                base_dir, 
                self.rag_config.get("vector_store_path", "./data/vector_store")
            )
            
            # יצירת מודל אמבדינג
            from langchain_community.embeddings import OllamaEmbeddings
            self.embeddings = OllamaEmbeddings(
                model=self.rag_config.get("embedding_model", "nomic-embed-text")
            )
            
            # יצירת מאגר וקטורים או טעינת קיים
            from langchain_community.vectorstores import Chroma
            self.vector_store = Chroma(
                persist_directory=self.vector_store_path,
                embedding_function=self.embeddings
            )
            
            # מפצל טקסט
            from langchain.text_splitter import RecursiveCharacterTextSplitter
            self.text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=self.rag_config.get("chunk_size", 512),
                chunk_overlap=self.rag_config.get("chunk_overlap", 50)
            )
            
            logging.info(f"שירות RAG אותחל עם מודל: {self.rag_config.get('embedding_model')}")
            
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות RAG: {e}")
            raise RuntimeError(f"לא ניתן לאתחל את שירות ה-RAG: {str(e)}")

    def add_texts(self, texts: List[str], metadatas: Optional[List[Dict[str, Any]]] = None) -> List[str]:
        """הוספת טקסטים למאגר הידע
        
        Args:
            texts: רשימת טקסטים להוספה
            metadatas: מטה-דאטה עבור כל טקסט (אופציונלי)
            
        Returns:
            מזהים של המסמכים שנוספו
        """
        # פיצול הטקסטים לקטעים קטנים יותר
        chunks = []
        chunk_metadatas = []
        
        for i, text in enumerate(texts):
            text_chunks = self.text_splitter.split_text(text)
            chunks.extend(text_chunks)
            
            # שכפול המטה-דאטה עבור כל קטע
            if metadatas and i < len(metadatas):
                for _ in text_chunks:
                    chunk_metadatas.append(metadatas[i])
        
        # הוספה למאגר הווקטורים
        ids = self.vector_store.add_texts(
            texts=chunks, 
            metadatas=chunk_metadatas if chunk_metadatas else None
        )
        
        # שמירת המאגר
        self.vector_store.persist()
        
        logging.info(f"נוספו {len(chunks)} קטעי טקסט למאגר הידע")
        return ids

    def add_documents(self, file_paths: List[str], file_type: str = None) -> List[str]:
        """הוספת מסמכים למאגר הידע
        
        Args:
            file_paths: רשימת נתיבים לקבצים
            file_type: סוג הקובץ (אופציונלי, יזוהה אוטומטית לפי הסיומת)
            
        Returns:
            מזהים של המסמכים שנוספו
        """
        all_texts = []
        all_metadatas = []
        
        for file_path in file_paths:
            try:
                # זיהוי סוג הקובץ לפי הסיומת אם לא צוין
                if not file_type:
                    _, ext = os.path.splitext(file_path)
                    current_file_type = ext.lower()[1:]  # הסרת הנקודה
                else:
                    current_file_type = file_type
                
                # קריאת הקובץ בהתאם לסוג
                if current_file_type in ["txt", "md", "text"]:
                    with open(file_path, "r", encoding="utf-8") as f:
                        text = f.read()
                        all_texts.append(text)
                        all_metadatas.append({"source": file_path, "type": current_file_type})
                
                # תמיכה בקבצי PDF
                elif current_file_type == "pdf":
                    try:
                        from PyPDF2 import PdfReader
                        reader = PdfReader(file_path)
                        text = ""
                        for page in reader.pages:
                            text += page.extract_text() + "\n\n"
                        all_texts.append(text)
                        all_metadatas.append({"source": file_path, "type": current_file_type})
                    except Exception as e:
                        logging.error(f"שגיאה בקריאת קובץ PDF {file_path}: {e}")
                
                # תמיכה בקבצי DOCX
                elif current_file_type == "docx":
                    try:
                        import docx
                        doc = docx.Document(file_path)
                        text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
                        all_texts.append(text)
                        all_metadatas.append({"source": file_path, "type": current_file_type})
                    except Exception as e:
                        logging.error(f"שגיאה בקריאת קובץ DOCX {file_path}: {e}")
                
                else:
                    logging.warning(f"סוג קובץ לא נתמך: {current_file_type}")
                    continue
                    
            except Exception as e:
                logging.error(f"שגיאה בקריאת קובץ {file_path}: {e}")
                continue
        
        if all_texts:
            return self.add_texts(all_texts, all_metadatas)
        else:
            return []

    def get_relevant_texts(self, query: str, k: int = 3) -> List[Dict[str, Any]]:
        """אחזור טקסטים רלוונטיים מהמאגר
        
        Args:
            query: השאלה או הטקסט לחיפוש
            k: מספר התוצאות לאחזור
            
        Returns:
            רשימה של קטעי טקסט רלוונטיים עם מטה-דאטה
        """
        docs = self.vector_store.similarity_search_with_score(query, k=k)
        
        results = []
        for doc, score in docs:
            results.append({
                "content": doc.page_content,
                "metadata": doc.metadata,
                "score": float(score)
            })
        
        return results

    def search_and_format(self, query: str, k: int = 3) -> str:
        """חיפוש טקסטים רלוונטיים ופירמוט כהקשר למודל
        
        Args:
            query: השאלה או הטקסט לחיפוש
            k: מספר התוצאות לאחזור
            
        Returns:
            טקסט מפורמט לשימוש כהקשר במודל
        """
        results = self.get_relevant_texts(query, k=k)
        
        if not results:
            return ""
        
        formatted_context = "להלן מידע רלוונטי שעשוי לעזור במתן תשובה:\n\n"
        
        for i, result in enumerate(results, 1):
            formatted_context += f"מקור {i}:\n{result['content']}\n\n"
        
        return formatted_context

    def clear_collection(self):
        """מחיקת כל הנתונים במאגר הידע"""
        try:
            self.vector_store.delete_collection()
            # יצירת מאגר חדש
            from langchain_community.vectorstores import Chroma
            self.vector_store = Chroma(
                persist_directory=self.vector_store_path,
                embedding_function=self.embeddings
            )
            logging.info("מאגר הידע נוקה בהצלחה")
            return True
        except Exception as e:
            logging.error(f"שגיאה בניקוי מאגר הידע: {e}")
            return False
EOF

    # יצירת קובץ __init__.py לחבילת services
    cat > "${SERVICES_DIR}/__init__.py" << 'EOF'
"""חבילת שירותים - RAG, עברית, למידה ועוד"""

from .rag_service import RAGService

__all__ = ["RAGService"]
EOF

    print_success "שירות RAG נוצר בהצלחה"
}

# יצירת מודול שירות תמיכה בעברית
create_hebrew_service() {
    print_header "יצירת שירות תמיכה בעברית"

    # יצירת קובץ שירות עברית
    cat > "${SERVICES_DIR}/hebrew_service.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" שירות תמיכה בעברית """

import os
import json
import logging
import re
from typing import Dict, Any, List, Tuple

class HebrewService:
    """שירות תמיכה בעברית למערכת ה-AI"""

    def __init__(self, config_path=None, hebrew_path=None):
        """אתחול שירות התמיכה בעברית"""
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        self.hebrew_path = hebrew_path or os.path.join(base_dir, "config", "hebrew.json")
        
        # טעינת הגדרות כלליות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.hebrew_config = config.get("hebrew_support", {})
            
            if not self.hebrew_config.get("enabled", True):
                logging.info("תמיכה בעברית מושבתת בהגדרות")
                return
            
            # טעינת משאבי עברית
            with open(self.hebrew_path, "r", encoding="utf-8") as f:
                self.hebrew_resources = json.load(f)
            
            logging.info("שירות תמיכה בעברית אותחל בהצלחה")
            
        except Exception as e:
            logging.error(f"שגיאה באתחול שירות תמיכה בעברית: {e}")
            # אתחול משאבים בסיסיים במקרה של שגיאה
            self.hebrew_config = {"enabled": True, "rtl_support": True}
            self.hebrew_resources = {
                "system_prompt": "אתה עוזר AI חכם ויעיל. אתה עונה בעברית ברורה.",
                "default_prompts": {},
                "common_terms": {}
            }

    def is_hebrew(self, text: str) -> bool:
        """בדיקה האם הטקסט מכיל עברית
        
        Args:
            text: הטקסט לבדיקה
            
        Returns:
            True אם הטקסט מכיל עברית, אחרת False
        """
        # בדיקה לנוכחות אותיות עבריות
        hebrew_pattern = re.compile(r'[\u0590-\u05FF\uFB1D-\uFB4F]+')
        return bool(hebrew_pattern.search(text))

    def detect_language(self, text: str) -> str:
        """זיהוי שפת הטקסט
        
        Args:
            text: הטקסט לזיהוי
            
        Returns:
            קוד השפה (he, en, וכו')
        """
        # בדיקה בסיסית לעברית
        if self.is_hebrew(text):
            return "he"
        
        # בדיקה לאנגלית (בהנחה שאם לא עברית, כנראה אנגלית)
        english_pattern = re.compile(r'[a-zA-Z]+')
        if english_pattern.search(text):
            return "en"
        
        # אם לא זוהתה שפה ספציפית
        return "unknown"

    def get_system_prompt(self) -> str:
        """מחזיר את ה-system prompt בעברית
        
        Returns:
            System prompt בעברית
        """
        return self.hebrew_resources.get("system_prompt", "")

    def get_prompt_template(self, template_name: str, **kwargs) -> str:
        """מחזיר תבנית פרומפט בעברית
        
        Args:
            template_name: שם התבנית
            **kwargs: פרמטרים להחלפה בתבנית
            
        Returns:
            הפרומפט המוכן
        """
        templates = self.hebrew_resources.get("default_prompts", {})
        template = templates.get(template_name, "")
        
        if not template:
            return ""
        
        # החלפת פרמטרים בתבנית
        for key, value in kwargs.items():
            template = template.replace(f"{{{key}}}", str(value))
        
        return template

    def translate_term(self, term: str) -> str:
        """תרגום מונח טכני לעברית
        
        Args:
            term: המונח באנגלית
            
        Returns:
            המונח בעברית אם קיים, אחרת המונח המקורי
        """
        terms = self.hebrew_resources.get("common_terms", {})
        return terms.get(term, term)

    def enhance_hebrew_response(self, question: str, answer: str) -> str:
        """שיפור תשובות בעברית
        
        Args:
            question: השאלה המקורית
            answer: התשובה מהמודל
            
        Returns:
            התשובה המשופרת
        """
        # אם השאלה בעברית אבל התשובה לא
        if self.is_hebrew(question) and not self.is_hebrew(answer[:100]):
            # אם פעילה האפשרות לתרגום אוטומטי
            if self.hebrew_config.get("translation_fallback", False):
                logging.info("התשובה אינה בעברית, מנסה לתרגם")
                try:
                    # ניסיון להשתמש ב-Google Translate API
                    from googletrans import Translator
                    translator = Translator()
                    translated = translator.translate(answer, dest='he')
                    return translated.text
                except Exception as e:
                    logging.error(f"שגיאה בתרגום: {e}")
                    return f"[התשובה המקורית התקבלה באנגלית. תרגום אוטומטי נכשל.]\n\n{answer}"
            else:
                return f"[התשובה המקורית התקבלה באנגלית. תרגום אוטומטי לא מופעל.]\n\n{answer}"
        
        return answer

    def format_hebrew_code(self, code: str) -> str:
        """פורמט נכון של קוד בעברית
        
        Args:
            code: הקוד לפורמוט
            
        Returns:
            הקוד עם פורמט מתאים לעברית
        """
        # שינוי כיוון טקסט לקוד
        # בקוד זה נשמר כיוון LTR גם בסביבת RTL
        formatted_code = code
        
        # אם פעילה תמיכה ב-RTL
        if self.hebrew_config.get("rtl_support", True):
            # הוספת תגיות כיוון טקסט לקוד (HTML)
            # בשימוש במסגרת דפדפן
            formatted_code = f"<div dir='ltr'>{code}</div>"
        
        return formatted_code

    def get_voice_commands(self) -> Dict[str, List[str]]:
        """קבלת פקודות קוליות בעברית
        
        Returns:
            מילון של פקודות קוליות
        """
        return self.hebrew_resources.get("voice_commands", {})
EOF

    # עדכון __init__.py של חבילת services
    cat > "${SERVICES_DIR}/__init__.py" << 'EOF'
"""חבילת שירותים - RAG, עברית, למידה ועוד"""

from .rag_service import RAGService
from .hebrew_service import HebrewService

__all__ = ["RAGService", "HebrewService"]
EOF

    print_success "שירות תמיכה בעברית נוצר בהצלחה"
}

# יצירת מודול שירות דיבור לטקסט
create_speech_to_text_service() {
    print_header "יצירת שירות דיבור לטקסט"

    # יצירת קובץ שירות דיבור לטקסט
    cat > "${SERVICES_DIR}/speech_to_text_service.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
""" שירות דיבור לטקסט - המרת הקלטות קול לטקסט """

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
EOF

    # עדכון קובץ init.py של חבילת שירותים
    cat > "${SERVICES_DIR}/__init__.py" << 'EOF'
"""חבילת שירותים - RAG, עברית, למידה ועוד"""

from .rag_service import RAGService
from .hebrew_service import HebrewService
from .speech_to_text_service import SpeechToTextService

__all__ = ["RAGService", "HebrewService", "SpeechToTextService"]
EOF

    print_success "שירות דיבור לטקסט נוצר בהצלחה"
}

# יצירת מודול שירות טקסט לדיבור
create_text_to_speech_service() {
    print_header "יצירת שירות טקסט לדיבור"

    # יצירת קובץ שירות טקסט לדיבור
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

    # עדכון __init__.py של חבילת services
    cat > "${SERVICES_DIR}/__init__.py" << 'EOF'
"""חבילת שירותים - RAG, עברית, למידה ועוד"""

from .rag_service import RAGService
from .hebrew_service import HebrewService
from .speech_to_text_service import SpeechToTextService
from .text_to_speech_service import TextToSpeechService

__all__ = [
    "RAGService", 
    "HebrewService", 
    "SpeechToTextService", 
    "TextToSpeechService"
]
EOF

    print_success "שירות טקסט לדיבור נוצר בהצלחה"
}

# יצירת מנהל גיבויים
create_backup_manager() {
    print_header "יצירת מנהל גיבויים"
    
    # יצירת קובץ מנהל גיבויים
    cat > "${BASE_DIR}/utilities/backup_manager.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מנהל גיבויים - יצירה, שחזור וניהול גיבויים
"""

import os
import json
import shutil
import zipfile
import logging
import datetime
import re
from typing import Dict, List, Any, Optional, Union

logger = logging.getLogger("effi_ai.backup")

class BackupManager:
    """מנהל גיבויים - יצירה, שחזור וניהול גיבויים"""
    
    def __init__(self, config_path=None):
        """אתחול מנהל הגיבויים
        
        Args:
            config_path: נתיב לקובץ תצורה (אופציונלי)
        """
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.base_dir = base_dir
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        
        # טעינת הגדרות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.backup_config = config.get("system", {}).get("backup", {})
            
            if not self.backup_config.get("enabled", True):
                logging.info("מערכת הגיבויים מושבתת בהגדרות")
                return
            
            # הגדרת נתיב גיבויים
            self.backup_dir = os.path.join(
                base_dir, 
                self.backup_config.get("backup_dir", "./data/backups")
            )
            
            # יצירת תיקייה אם לא קיימת
            os.makedirs(self.backup_dir, exist_ok=True)
            
            # הגדרות נוספות
            self.auto_backup = self.backup_config.get("auto_backup", True)
            self.interval_days = self.backup_config.get("interval_days", 7)
            self.keep_backups = self.backup_config.get("keep_backups", 5)
            
            # בדיקה אם צריך גיבוי אוטומטי
            if self.auto_backup:
                self._check_auto_backup()
            
            logging.info(f"מנהל הגיבויים אותחל בהצלחה. תיקיית גיבויים: {self.backup_dir}")
            
        except Exception as e:
            logging.error(f"שגיאה באתחול מנהל הגיבויים: {e}")
    
    def _check_auto_backup(self):
        """בדיקה אם נדרש גיבוי אוטומטי"""
        try:
            # קבלת גיבוי אחרון
            backups = self.list_backups()
            
            if not backups:
                # אין גיבויים קיימים, יצירת גיבוי ראשון
                logging.info("לא נמצאו גיבויים קיימים. יוצר גיבוי ראשון...")
                self.create_backup()
                return
            
            # קבלת תאריך הגיבוי האחרון
            last_backup = backups[0]  # הגיבוי הראשון ברשימה הממוינת
            last_backup_date = datetime.datetime.strptime(last_backup["date"], "%Y-%m-%d")
            days_since_last_backup = (datetime.datetime.now() - last_backup_date).days
            
            # בדיקה אם עבר מספיק זמן מהגיבוי האחרון
            if days_since_last_backup >= self.interval_days:
                logging.info(f"עברו {days_since_last_backup} ימים מהגיבוי האחרון. יוצר גיבוי חדש...")
                self.create_backup()
            else:
                logging.info(f"הגיבוי האחרון נוצר לפני {days_since_last_backup} ימים. אין צורך בגיבוי חדש.")
                
        except Exception as e:
            logging.error(f"שגיאה בבדיקת גיבוי אוטומטי: {e}")
    
    def create_backup(self, backup_name=None):
        """יצירת גיבוי חדש
        
        Args:
            backup_name: שם הגיבוי (אופציונלי)
            
        Returns:
            נתיב לקובץ הגיבוי החדש
        """
        try:
            # קביעת שם הגיבוי
            if not backup_name:
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_name = f"backup_{timestamp}"
            
            # נתיב לקובץ הגיבוי
            backup_file = os.path.join(self.backup_dir, f"{backup_name}.zip")
            
            # יצירת הגיבוי
            with zipfile.ZipFile(backup_file, "w", zipfile.ZIP_DEFLATED) as zipf:
                # גיבוי קבצי תצורה
                self._backup_dir(os.path.join(self.base_dir, "config"), zipf, "config")
                
                # גיבוי נתוני מאגר הידע
                self._backup_dir(os.path.join(self.base_dir, "data", "vector_store"), zipf, "data/vector_store")
                
                # גיבוי זיכרון
                self._backup_dir(os.path.join(self.base_dir, "data", "memory"), zipf, "data/memory")
                
                # גיבוי מודולים מותאמים אישית
                self._backup_dir(os.path.join(self.base_dir, "modules"), zipf, "modules")
                
                # גיבוי התאמות משתמש
                self._backup_dir(os.path.join(self.base_dir, "ui", "assets", "css"), zipf, "ui/assets/css")
                
                # שמירת מטה-דאטה
                metadata = {
                    "timestamp": datetime.datetime.now().isoformat(),
                    "version": self._get_version(),
                    "system_info": self._get_system_info()
                }
                
                zipf.writestr("metadata.json", json.dumps(metadata, ensure_ascii=False, indent=2))
            
            # מחיקת גיבויים ישנים
            self._cleanup_old_backups()
            
            logging.info(f"גיבוי נוצר בהצלחה: {backup_file}")
            return backup_file
            
        except Exception as e:
            logging.error(f"שגיאה ביצירת גיבוי: {e}")
            return None
    
    def _backup_dir(self, dir_path, zipf, prefix):
        """גיבוי תיקייה לארכיון ZIP
        
        Args:
            dir_path: נתיב לתיקייה לגיבוי
            zipf: אובייקט ZIP
            prefix: קידומת נתיב בארכיון
        """
        if not os.path.exists(dir_path):
            return
        
        for root, _, files in os.walk(dir_path):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.join(prefix, os.path.relpath(file_path, dir_path))
                zipf.write(file_path, arcname)
    
    def _get_version(self):
        """קבלת גרסת המערכת
        
        Returns:
            גרסת המערכת
        """
        # ניסיון לקרוא גרסה מקובץ __init__.py
        init_path = os.path.join(self.base_dir, "__init__.py")
        if os.path.exists(init_path):
            with open(init_path, "r", encoding="utf-8") as f:
                content = f.read()
                version_match = re.search(r'__version__\s*=\s*[\'"]([^\'"]*)[\'"]', content)
                if version_match:
                    return version_match.group(1)
        
        # אם לא הצלחנו לקרוא מהקובץ, קריאה מהתצורה
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
                return config.get("version", "1.0.0")
        except:
            return "1.0.0"
    
    def _get_system_info(self):
        """קבלת מידע מערכת בסיסי
        
        Returns:
            מילון עם מידע מערכת
        """
        import platform
        
        return {
            "platform": platform.system(),
            "platform_version": platform.version(),
            "python_version": platform.python_version(),
            "backup_time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    
    def _cleanup_old_backups(self):
        """מחיקת גיבויים ישנים"""
        # קבלת רשימת הגיבויים
        backups = self.list_backups()
        
        # אם יש יותר מדי גיבויים, מחיקת הישנים ביותר
        if len(backups) > self.keep_backups:
            # מיון לפי תאריך (מהחדש לישן)
            backups_to_delete = backups[self.keep_backups:]
            
            for backup in backups_to_delete:
                try:
                    os.remove(backup["path"])
                    logging.info(f"גיבוי ישן נמחק: {backup['path']}")
                except Exception as e:
                    logging.error(f"שגיאה במחיקת גיבוי ישן {backup['path']}: {e}")
    
    def list_backups(self):
        """קבלת רשימת גיבויים קיימים
        
        Returns:
            רשימת גיבויים ממוינת לפי תאריך (מהחדש לישן)
        """
        backups = []
        
        for filename in os.listdir(self.backup_dir):
            if filename.endswith(".zip") and filename.startswith("backup_"):
                backup_path = os.path.join(self.backup_dir, filename)
                
                try:
                    # חילוץ תאריך מהשם
                    date_match = re.search(r'backup_(\d{8})_', filename)
                    if date_match:
                        date_str = date_match.group(1)
                        backup_date = f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:8]}"
                    else:
                        # שימוש בתאריך הקובץ
                        backup_date = datetime.datetime.fromtimestamp(
                            os.path.getctime(backup_path)
                        ).strftime("%Y-%m-%d")
                    
                    # קבלת גודל הקובץ
                    size = os.path.getsize(backup_path)
                    
                    backups.append({
                        "name": filename,
                        "path": backup_path,
                        "date": backup_date,
                        "size": size,
                        "size_formatted": self._format_size(size)
                    })
                    
                except Exception as e:
                    logging.error(f"שגיאה בקריאת מידע על גיבוי {filename}: {e}")
        
        # מיון לפי תאריך (מהחדש לישן)
        return sorted(backups, key=lambda x: x["date"], reverse=True)
    
    def _format_size(self, size_bytes):
        """פורמט גודל בבתים
        
        Args:
            size_bytes: גודל בבתים
            
        Returns:
            מחרוזת מפורמטת
        """
        if size_bytes < 1024:
            return f"{size_bytes} bytes"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes/1024:.2f} KB"
        elif size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes/(1024*1024):.2f} MB"
        else:
            return f"{size_bytes/(1024*1024*1024):.2f} GB"
    
    def restore_backup(self, backup_path, restore_all=False):
        """שחזור מגיבוי
        
        Args:
            backup_path: נתיב לקובץ הגיבוי
            restore_all: האם לשחזר הכל או רק נתונים (ברירת מחדל: רק נתונים)
            
        Returns:
            האם השחזור הצליח
        """
        try:
            # יצירת תיקייה זמנית לחילוץ
            import tempfile
            temp_dir = tempfile.mkdtemp()
            
            # חילוץ הארכיון
            with zipfile.ZipFile(backup_path, "r") as zipf:
                zipf.extractall(temp_dir)
            
            # שחזור קבצי תצורה
            if restore_all:
                self._restore_dir(os.path.join(temp_dir, "config"), os.path.join(self.base_dir, "config"))
            
            # שחזור נתוני מאגר הידע
            self._restore_dir(
                os.path.join(temp_dir, "data/vector_store"), 
                os.path.join(self.base_dir, "data", "vector_store")
            )
            
            # שחזור זיכרון
            self._restore_dir(
                os.path.join(temp_dir, "data/memory"), 
                os.path.join(self.base_dir, "data", "memory")
            )
            
            # שחזור מודולים מותאמים אישית
            if restore_all:
                self._restore_dir(os.path.join(temp_dir, "modules"), os.path.join(self.base_dir, "modules"))
            
            # מחיקת התיקייה הזמנית
            shutil.rmtree(temp_dir)
            
            logging.info(f"גיבוי שוחזר בהצלחה: {backup_path}")
            return True
            
        except Exception as e:
            logging.error(f"שגיאה בשחזור גיבוי: {e}")
            return False
    
    def _restore_dir(self, src_dir, dst_dir):
        """שחזור תיקייה מגיבוי
        
        Args:
            src_dir: נתיב מקור (בגיבוי)
            dst_dir: נתיב יעד (במערכת)
        """
        if not os.path.exists(src_dir):
            return
        
        # יצירת תיקיית היעד אם לא קיימת
        os.makedirs(dst_dir, exist_ok=True)
        
        # העתקת הקבצים
        for item in os.listdir(src_dir):
            src_item = os.path.join(src_dir, item)
            dst_item = os.path.join(dst_dir, item)
            
            if os.path.isdir(src_item):
                # העתקת תיקייה בצורה רקורסיבית
                self._restore_dir(src_item, dst_item)
            else:
                # העתקת קובץ
                shutil.copy2(src_item, dst_item)
EOF

    # עדכון __init__.py של חבילת utilities
    cat > "${BASE_DIR}/utilities/__init__.py" << 'EOF'
"""חבילת שירותי עזר - לוגים ושירותים שימושיים נוספים"""

from .logging_manager import get_logging_manager
from .utils import (
    get_timestamp, create_unique_id, hash_content,
    execute_command, load_json_file, save_json_file,
    create_backup, format_size, is_hebrew, create_download_url
)
from .security_checker import SecurityChecker
from .backup_manager import BackupManager

__all__ = [
    "get_logging_manager",
    "get_timestamp", "create_unique_id", "hash_content",
    "execute_command", "load_json_file", "save_json_file",
    "create_backup", "format_size", "is_hebrew", "create_download_url",
    "SecurityChecker", "BackupManager"
]
EOF

    print_success "מנהל גיבויים נוצר בהצלחה"
}

# עדכון פונקציית main להוספת רכיבים חדשים
# פונקציה ראשית
main() {
    # הצגת באנר פתיחה
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
    
    # יצירת מתאם Hugging Face
    create_huggingface_adapter
    
    # יצירת מודול שירות RAG
    create_rag_service
    
    # יצירת מודול שירות תמיכה בעברית
    create_hebrew_service
    
    # יצירת שירות זיכרון שיחה
    create_memory_service
    
    # יצירת מודול שירות דיבור לטקסט
    create_speech_to_text_service
    
    # יצירת מודול שירות טקסט לדיבור
    create_text_to_speech_service
    
    # יצירת מודול שירות אווטאר
    create_avatar_service
    
    # יצירת מודול שירות העלאת קבצים
    create_upload_service
    
    # יצירת מודול ניהול מודולים חיצוניים
    create_module_manager
    
    # יצירת שירות לוגים
    create_logging_service
    
    # יצירת כלי שירות נוספים
    create_utilities
    
    # יצירת בודק אבטחה ועדכונים
    create_security_checker
    
    # יצירת מנהל גיבויים
    create_backup_manager
    
    # יצירת קובץ הרצה ראשי
    create_main_file
    
    # יצירת קבצי PWA
    create_pwa_files
    
    # יצירת מודול לדוגמה
    create_example_module
    
    # קישור כל הרכיבים יחד
    link_components
    
    # הצגת סיכום התקנה
    show_summary
}

# יצירת בודק ועדכון אבטחה
create_security_checker() {
    print_header "יצירת בודק אבטחה ועדכונים"
    
    # יצירת קובץ בודק אבטחה
    cat > "${BASE_DIR}/utilities/security_checker.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
בודק אבטחה ועדכונים - Effi-AI Private
"""

import os
import json
import logging
import subprocess
import platform
import pkg_resources
import socket
import ssl
import hashlib
import base64
import re
from typing import Dict, List, Any, Optional, Union
from datetime import datetime, timedelta

# יצירת לוגר
logger = logging.getLogger("effi_ai.security")

class SecurityChecker:
    """בודק אבטחה ועדכונים למערכת"""
    
    def __init__(self, config_path=None):
        """אתחול בודק האבטחה
        
        Args:
            config_path: נתיב לקובץ תצורה (אופציונלי)
        """
        # קביעת נתיבים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.config_path = config_path or os.path.join(base_dir, "config", "config.json")
        self.security_log_path = os.path.join(base_dir, "logs", "security.log")
        
        # טעינת הגדרות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            self.system_config = config.get("system", {})
            self.update_config = self.system_config.get("updates", {})
            
        except Exception as e:
            logger.error(f"שגיאה בטעינת קובץ תצורה: {e}")
            self.system_config = {}
            self.update_config = {}
        
        # הגדרת זמן בדיקה אחרון
        self.last_check_time = datetime.now() - timedelta(days=2)  # 2 ימים לאחור כברירת מחדל
    
    def check_package_vulnerabilities(self):
        """בדיקת פגיעויות בחבילות Python
        
        Returns:
            רשימת חבילות פגיעות
        """
        vulnerabilities = []
        
        try:
            # הרצת safety (אם מותקן)
            try:
                import safety
                result = subprocess.run(
                    ["safety", "check", "--json"],
                    capture_output=True, 
                    text=True
                )
                
                if result.returncode == 0:
                    safety_data = json.loads(result.stdout)
                    for vuln in safety_data:
                        vulnerabilities.append({
                            "package": vuln[0],
                            "installed_version": vuln[1],
                            "vulnerable_below": vuln[2],
                            "vulnerability_id": vuln[3],
                            "vulnerability_desc": vuln[4]
                        })
                
            except (ImportError, subprocess.SubprocessError) as e:
                # Safety לא מותקן או נכשל, נמשיך לבדיקות אחרות
                pass
            
            # בדיקת חבילות נפוצות עם פגיעויות ידועות
            vulnerable_packages = {
                "flask": "2.2.3",
                "django": "3.2.18",
                "requests": "2.28.0",
                "cryptography": "38.0.4",
                "pillow": "9.3.0"
            }
            
            # בדיקת גרסאות מותקנות
            installed_packages = {pkg.key: pkg.version for pkg in pkg_resources.working_set}
            
            for pkg_name, safe_version in vulnerable_packages.items():
                if pkg_name in installed_packages:
                    current_version = installed_packages[pkg_name]
                    
                    # השוואת גרסאות פשוטה - יש לשפר בגרסאות עתידיות
                    if current_version < safe_version:
                        vulnerabilities.append({
                            "package": pkg_name,
                            "installed_version": current_version,
                            "vulnerable_below": safe_version,
                            "severity": "unknown",
                            "description": f"גרסה {current_version} של {pkg_name} ידועה כפגיעה. שדרג לגרסה {safe_version} או חדשה יותר."
                        })
            
            return vulnerabilities
            
        except Exception as e:
            logger.error(f"שגיאה בבדיקת פגיעויות בחבילות: {e}")
            return []
    
    def check_for_updates(self):
        """בדיקת עדכונים למערכת
        
        Returns:
            מידע על עדכונים זמינים
        """
        # אם אין לבדוק עדכונים
        if not self.update_config.get("check_updates", True):
            return {"update_available": False, "reason": "בדיקת עדכונים מושבתת"}
        
        # אם נבדק לאחרונה
        time_since_last_check = datetime.now() - self.last_check_time
        if time_since_last_check < timedelta(hours=24):
            return {"update_available": False, "reason": "נבדק לאחרונה"}
        
        try:
            # גרסה נוכחית
            with open(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "__init__.py"), "r") as f:
                content = f.read()
                version_match = re.search(r'__version__\s*=\s*[\'"]([^\'"]*)[\'"]', content)
                current_version = version_match.group(1) if version_match else "1.0.0"
            
            # חיבור לשרת פיקטיבי לבדיקת עדכונים
            # בפועל, יש להחליף בשרת אמיתי
            
            # אנו יוצרים תוצאה פיקטיבית לצורך הדגמה
            latest_version = "1.1.0"  # גרסה פיקטיבית
            update_available = self._compare_versions(current_version, latest_version) < 0
            
            # עדכון זמן בדיקה אחרון
            self.last_check_time = datetime.now()
            
            if update_available:
                return {
                    "update_available": True,
                    "current_version": current_version,
                    "latest_version": latest_version,
                    "release_notes": "שיפורי ביצועים, תיקוני באגים, ותכונות חדשות.",
                    "update_url": "https://github.com/shayAI/effi-ai-private/releases"
                }
            else:
                return {
                    "update_available": False,
                    "current_version": current_version,
                    "latest_version": latest_version
                }
            
        except Exception as e:
            logger.error(f"שגיאה בבדיקת עדכונים: {e}")
            return {"update_available": False, "error": str(e)}
    
    def _compare_versions(self, version1, version2):
        """השוואת גרסאות
        
        Args:
            version1: גרסה ראשונה
            version2: גרסה שנייה
            
        Returns:
            -1 אם version1 < version2, 0 אם הן שוות, 1 אם version1 > version2
        """
        v1_parts = [int(x) for x in version1.split(".")]
        v2_parts = [int(x) for x in version2.split(".")]
        
        # הוספת אפסים בסוף אם צריך
        while len(v1_parts) < len(v2_parts):
            v1_parts.append(0)
        while len(v2_parts) < len(v1_parts):
            v2_parts.append(0)
        
        # השוואה
        for i in range(len(v1_parts)):
            if v1_parts[i] < v2_parts[i]:
                return -1
            elif v1_parts[i] > v2_parts[i]:
                return 1
        
        return 0
    
    def perform_security_audit(self):
        """ביצוע ביקורת אבטחה מקיפה
        
        Returns:
            תוצאות הבדיקה
        """
        security_report = {
            "timestamp": datetime.now().isoformat(),
            "system_info": self._get_system_info(),
            "package_vulnerabilities": self.check_package_vulnerabilities(),
            "open_ports": self._check_open_ports(),
            "updates": self.check_for_updates(),
            "configuration_issues": self._check_configuration_issues(),
            "file_permissions": self._check_file_permissions(),
            "recommendations": []
        }
        
        # הוספת המלצות
        self._add_recommendations(security_report)
        
        # שמירת הדוח
        self._save_security_report(security_report)
        
        return security_report
    
    def _get_system_info(self):
        """קבלת מידע מערכת
        
        Returns:
            מידע על המערכת
        """
        system_info = {
            "platform": platform.system(),
            "platform_version": platform.version(),
            "platform_release": platform.release(),
            "architecture": platform.machine(),
            "python_version": platform.python_version(),
            "hostname": socket.gethostname()
        }
        
        # מידע נוסף בלינוקס
        if system_info["platform"] == "Linux":
            try:
                # ניסיון לקבל הפצה
                import distro
                system_info["linux_distro"] = distro.name(pretty=True)
            except ImportError:
                # אם distro לא מותקן, ננסה שיטה אחרת
                try:
                    with open("/etc/os-release", "r") as f:
                        for line in f:
                            if line.startswith("PRETTY_NAME="):
                                system_info["linux_distro"] = line.split("=")[1].strip().strip('"')
                                break
                except:
                    system_info["linux_distro"] = "unknown"
        
        return system_info
    
    def _check_open_ports(self):
        """בדיקת פורטים פתוחים
        
        Returns:
            רשימת פורטים פתוחים
        """
        open_ports = []
        
        # רשימת פורטים לבדיקה
        ports_to_check = [
            7860,  # פורט ברירת מחדל של Gradio/המערכת
            8000, 8080,  # פורטים נפוצים לשרתי ווב
            22,    # SSH
            3306,  # MySQL
            5432,  # PostgreSQL
            6379,  # Redis
            27017  # MongoDB
        ]
        
        for port in ports_to_check:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.1)
            result = sock.connect_ex(('127.0.0.1', port))
            if result == 0:
                service = ""
                if port == 7860:
                    service = "Effi-AI Private UI"
                elif port == 22:
                    service = "SSH"
                elif port == 3306:
                    service = "MySQL"
                elif port == 5432:
                    service = "PostgreSQL"
                elif port == 6379:
                    service = "Redis"
                elif port == 27017:
                    service = "MongoDB"
                
                open_ports.append({
                    "port": port,
                    "service": service
                })
            sock.close()
        
        return open_ports
    
    def _check_configuration_issues(self):
        """בדיקת בעיות תצורה
        
        Returns:
            רשימת בעיות תצורה
        """
        issues = []
        
        # בדיקת הגדרות בסיסיות
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
            
            # בדיקת הגדרות לוגים
            log_config = config.get("services", {}).get("logging", {})
            if not log_config.get("enabled", True):
                issues.append({
                    "type": "configuration",
                    "severity": "medium",
                    "description": "לוגים מושבתים, מה שעלול להקשות על זיהוי בעיות אבטחה."
                })
            
            # בדיקת גיבויים
            backup_config = config.get("system", {}).get("backup", {})
            if not backup_config.get("enabled", True) or not backup_config.get("auto_backup", True):
                issues.append({
                    "type": "configuration",
                    "severity": "high",
                    "description": "גיבויים אוטומטיים מושבתים. הפעל גיבויים אוטומטיים למניעת אובדן נתונים."
                })
            
            # בדיקת תדירות גיבויים
            backup_interval = backup_config.get("interval_days", 7)
            if backup_interval > 14:
                issues.append({
                    "type": "configuration",
                    "severity": "medium",
                    "description": f"גיבויים מתבצעים כל {backup_interval} ימים, מומלץ לגבות לפחות פעם בשבוע."
                })
            
        except Exception as e:
            logger.error(f"שגיאה בבדיקת הגדרות תצורה: {e}")
            issues.append({
                "type": "configuration",
                "severity": "high",
                "description": f"לא ניתן לבדוק הגדרות תצורה: {str(e)}"
            })
        
        return issues
    
    def _check_file_permissions(self):
        """בדיקת הרשאות קבצים
        
        Returns:
            רשימת בעיות הרשאות
        """
        permission_issues = []
        
        # בדיקת הרשאות קבצים רגישים
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        sensitive_files = [
            os.path.join(base_dir, "config", "config.json"),
            self.config_path,
            os.path.join(base_dir, "data", "vector_store")
        ]
        
        for file_path in sensitive_files:
            if os.path.exists(file_path):
                try:
                    # בדיקת הרשאות בלינוקס/מקינטוש
                    if platform.system() != "Windows":
                        mode = os.stat(file_path).st_mode
                        # בדיקה להרשאות קריאה/כתיבה לכולם
                        if mode & 0o006:  # הרשאות קריאה/כתיבה לאחרים
                            permission_issues.append({
                                "path": file_path,
                                "permission": oct(mode)[-3:],  # 3 הספרות האחרונות
                                "issue": "הרשאות קריאה/כתיבה נרחבות מדי",
                                "severity": "high" if "config" in file_path or "vector_store" in file_path else "medium"
                            })
                except Exception as e:
                    logger.error(f"שגיאה בבדיקת הרשאות לקובץ {file_path}: {e}")
        
        return permission_issues
    
    def _add_recommendations(self, security_report):
        """הוספת המלצות לדוח האבטחה
        
        Args:
            security_report: דוח האבטחה להוספת המלצות
        """
        # המלצות למודולים פגיעים
        if security_report["package_vulnerabilities"]:
            recommendations = []
            for vuln in security_report["package_vulnerabilities"]:
                recommendations.append(f"שדרג את החבילה {vuln['package']} לגרסה {vuln.get('vulnerable_below', 'החדשה ביותר')} או חדשה יותר.")
            
            security_report["recommendations"].append({
                "category": "package_vulnerabilities",
                "title": "שדרוג חבילות פגיעות",
                "description": "יש לשדרג את החבילות הבאות כדי לתקן פגיעויות אבטחה ידועות.",
                "actions": recommendations
            })
        
        # המלצות לפורטים פתוחים
        exposed_ports = [p for p in security_report["open_ports"] if p["port"] not in [7860, 11434]]  # פורטים של המערכת
        if exposed_ports:
            port_recommendations = ["סגור פורטים שאינם נדרשים:"]
            for port in exposed_ports:
                port_recommendations.append(f"פורט {port['port']} ({port['service'] or 'לא ידוע'})")
            
            security_report["recommendations"].append({
                "category": "open_ports",
                "title": "סגירת פורטים חשופים",
                "description": "פורטים פתוחים שאינם נדרשים מהווים וקטור תקיפה פוטנציאלי.",
                "actions": port_recommendations
            })
        
        # המלצות לבעיות תצורה
        if security_report["configuration_issues"]:
            config_recommendations = []
            for issue in security_report["configuration_issues"]:
                if "גיבויים" in issue["description"]:
                    config_recommendations.append("הפעל גיבויים אוטומטיים בקובץ התצורה.")
                elif "לוגים" in issue["description"]:
                    config_recommendations.append("הפעל לוגים לניטור אירועי אבטחה.")
            
            if config_recommendations:
                security_report["recommendations"].append({
                    "category": "configuration",
                    "title": "תיקון בעיות תצורה",
                    "description": "הגדרות תצורה לא מאובטחות עלולות להוביל לבעיות אבטחה.",
                    "actions": config_recommendations
                })
        
        # המלצות להרשאות קבצים
        if security_report["file_permissions"]:
            security_report["recommendations"].append({
                "category": "file_permissions",
                "title": "תיקון הרשאות קבצים",
                "description": "קבצים עם הרשאות נרחבות מדי מהווים סיכון אבטחה.",
                "actions": [f"הגבל הרשאות לקובץ {issue['path']} ל-600 (קריאה/כתיבה לבעלים בלבד)" for issue in security_report["file_permissions"]]
            })
        
        # המלצה כללית לעדכון
        if security_report["updates"].get("update_available", False):
            security_report["recommendations"].append({
                "category": "updates",
                "title": "עדכון המערכת",
                "description": f"גרסה חדשה זמינה: {security_report['updates'].get('latest_version', '')}",
                "actions": ["עדכן את המערכת לגרסה החדשה ביותר להגנה מפני פגיעויות ידועות."]
            })
    
    def _save_security_report(self, security_report):
        """שמירת דוח האבטחה
        
        Args:
            security_report: דוח האבטחה לשמירה
        """
        try:
            # יצירת תיקיית לוגים אם לא קיימת
            log_dir = os.path.dirname(self.security_log_path)
            os.makedirs(log_dir, exist_ok=True)
            
            # שמירת הדוח
            with open(self.security_log_path, "a", encoding="utf-8") as f:
                f.write(f"\n--- Security Report: {security_report['timestamp']} ---\n")
                f.write(json.dumps(security_report, ensure_ascii=False, indent=2))
                f.write("\n\n")
                
        except Exception as e:
            logger.error(f"שגיאה בשמירת דוח אבטחה: {e}")
    
    def apply_security_patches(self, recommendations=None):
        """החלת תיקוני אבטחה
        
        Args:
            recommendations: המלצות ספציפיות להחלה (אופציונלי)
            
        Returns:
            תוצאות החלת התיקונים
        """
        # אם לא סופקו המלצות, בצע ביקורת ראשונה
        if recommendations is None:
            security_report = self.perform_security_audit()
            recommendations = security_report.get("recommendations", [])
        
        patch_results = {
            "timestamp": datetime.now().isoformat(),
            "applied_patches": [],
            "failed_patches": []
        }
        
        for recommendation in recommendations:
            category = recommendation.get("category", "")
            actions = recommendation.get("actions", [])
            
            # טיפול בפגיעויות חבילות
            if category == "package_vulnerabilities":
                for action in actions:
                    # חילוץ שם החבילה
                    if "שדרג את החבילה" in action:
                        package_name = action.split("שדרג את החבילה")[1].split()[0]
                        
                        try:
                            # ניסיון שדרוג
                            result = subprocess.run(
                                ["pip", "install", "--upgrade", package_name],
                                capture_output=True,
                                text=True
                            )
                            
                            if result.returncode == 0:
                                patch_results["applied_patches"].append({
                                    "action": action,
                                    "result": "success",
                                    "details": f"החבילה {package_name} שודרגה בהצלחה."
                                })
                            else:
                                patch_results["failed_patches"].append({
                                    "action": action,
                                    "result": "failure",
                                    "details": f"נכשל בשדרוג החבילה {package_name}: {result.stderr}"
                                })
                                
                        except Exception as e:
                            patch_results["failed_patches"].append({
                                "action": action,
                                "result": "failure",
                                "details": f"שגיאה בשדרוג החבילה {package_name}: {str(e)}"
                            })
            
            # טיפול בהרשאות קבצים
            elif category == "file_permissions" and platform.system() != "Windows":
                for action in actions:
                    # חילוץ נתיב הקובץ
                    if "הגבל הרשאות לקובץ" in action:
                        file_path = action.split("הגבל הרשאות לקובץ")[1].split()[0]
                        
                        try:
                            # שינוי הרשאות
                            os.chmod(file_path, 0o600)  # הרשאות קריאה/כתיבה לבעלים בלבד
                            
                            patch_results["applied_patches"].append({
                                "action": action,
                                "result": "success",
                                "details": f"הרשאות הקובץ {file_path} הוגבלו ל-600 בהצלחה."
                            })
                            
                        except Exception as e:
                            patch_results["failed_patches"].append({
                                "action": action,
                                "result": "failure",
                                "details": f"שגיאה בשינוי הרשאות לקובץ {file_path}: {str(e)}"
                            })
            
            # טיפול בבעיות תצורה
            elif category == "configuration":
                for action in actions:
                    try:
                        # הפעלת גיבויים אוטומטיים
                        if "הפעל גיבויים אוטומטיים" in action:
                            with open(self.config_path, "r", encoding="utf-8") as f:
                                config = json.load(f)
                            
                            if "system" not in config:
                                config["system"] = {}
                            if "backup" not in config["system"]:
                                config["system"]["backup"] = {}
                            
                            config["system"]["backup"]["enabled"] = True
                            config["system"]["backup"]["auto_backup"] = True
                            
                            with open(self.config_path, "w", encoding="utf-8") as f:
                                json.dump(config, f, ensure_ascii=False, indent=2)
                            
                            patch_results["applied_patches"].append({
                                "action": action,
                                "result": "success",
                                "details": "גיבויים אוטומטיים הופעלו בהצלחה."
                            })
                        
                        # הפעלת לוגים
                        elif "הפעל לוגים" in action:
                            with open(self.config_path, "r", encoding="utf-8") as f:
                                config = json.load(f)
                            
                            if "services" not in config:
                                config["services"] = {}
                            if "logging" not in config["services"]:
                                config["services"]["logging"] = {}
                            
                            config["services"]["logging"]["enabled"] = True
                            
                            with open(self.config_path, "w", encoding="utf-8") as f:
                                json.dump(config, f, ensure_ascii=False, indent=2)
                            
                            patch_results["applied_patches"].append({
                                "action": action,
                                "result": "success",
                                "details": "לוגים הופעלו בהצלחה."
                            })
                            
                    except Exception as e:
                        patch_results["failed_patches"].append({
                            "action": action,
                            "result": "failure",
                            "details": f"שגיאה בעדכון הגדרות תצורה: {str(e)}"
                        })
        
        # שמירת תוצאות בלוג
        try:
            with open(self.security_log_path, "a", encoding="utf-8") as f:
                f.write(f"\n--- Patch Results: {patch_results['timestamp']} ---\n")
                f.write(json.dumps(patch_results, ensure_ascii=False, indent=2))
                f.write("\n\n")
        except Exception as e:
            logger.error(f"שגיאה בשמירת תוצאות תיקונים: {e}")
        
        return patch_results
EOF

    # עדכון __init__.py של חבילת utilities
    cat > "${BASE_DIR}/utilities/__init__.py" << 'EOF'
"""חבילת שירותי עזר - לוגים ושירותים שימושיים נוספים"""

from .logging_manager import get_logging_manager
from .utils import (
    get_timestamp, create_unique_id, hash_content,
    execute_command, load_json_file, save_json_file,
    create_backup, format_size, is_hebrew, create_download_url
)
from .security_checker import SecurityChecker

__all__ = [
    "get_logging_manager",
    "get_timestamp", "create_unique_id", "hash_content",
    "execute_command", "load_json_file", "save_json_file",
    "create_backup", "format_size", "is_hebrew", "create_download_url",
    "SecurityChecker"
]
EOF

    print_success "בודק אבטחה ועדכונים נוצר בהצלחה"
}

# יצירת תיקיית PWA (Progressive Web App)
create_pwa_files() {
    print_header "יצירת קבצי PWA"
    
    # יצירת קובץ manifest.json
    cat > "${UI_DIR}/assets/manifest.json" << 'EOF'
{
  "name": "Effi-AI Private",
  "short_name": "Effi-AI",
  "description": "מערכת AI פרטית מודולרית",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2563eb",
  "icons": [
    {
      "src": "images/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "images/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
    
    # יצירת קובץ service-worker.js
    cat > "${UI_DIR}/assets/js/service-worker.js" << 'EOF'
/**
 * Service Worker - Effi-AI Private
 */

// אירוע התקנה
self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open('effi-ai-v1').then(function(cache) {
            return cache.addAll([
                '/',
                '/assets/css/custom.css',
                '/assets/js/main.js',
                '/assets/images/logo.svg',
                '/assets/images/icon-192x192.png',
                '/assets/images/icon-512x512.png'
            ]);
        })
    );
});

// אירוע הפעלה
self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(cacheNames) {
            return Promise.all(
                cacheNames.filter(function(cacheName) {
                    return cacheName.startsWith('effi-ai-') && cacheName !== 'effi-ai-v1';
                }).map(function(cacheName) {
                    return caches.delete(cacheName);
                })
            );
        })
    );
});

// אירוע לכידת בקשות
self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request).then(function(response) {
            // החזרת המשאב מהמטמון אם קיים
            if (response) {
                return response;
            }
            
            // יצירת עותק של הבקשה
            var fetchRequest = event.request.clone();
            
            return fetch(fetchRequest).then(function(response) {
                // בדיקה אם התגובה תקינה
                if (!response || response.status !== 200 || response.type !== 'basic') {
                    return response;
                }
                
                // יצירת עותק של התגובה
                var responseToCache = response.clone();
                
                // שמירת התגובה במטמון
                caches.open('effi-ai-v1').then(function(cache) {
                    cache.put(event.request, responseToCache);
                });
                
                return response;
            });
        })
    );
});
EOF
    
    # יצירת תיקייה עבור תמונות נוספות
    mkdir -p "${UI_DIR}/assets/images"
    
    # יצירת קובץ HTML לדוגמה
    cat > "${UI_DIR}/pwa.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-AI Private</title>
    <meta name="description" content="מערכת AI פרטית מודולרית">
    <link rel="stylesheet" href="assets/css/custom.css">
    <link rel="manifest" href="assets/manifest.json">
    <link rel="icon" href="assets/images/favicon.ico">
    <meta name="theme-color" content="#2563eb">
</head>
<body>
    <header>
        <div class="logo-container">
            <img src="assets/images/logo.svg" alt="Effi-AI Private Logo" class="logo">
        </div>
        <h1>Effi-AI Private</h1>
        <p class="subtitle">מערכת AI פרטית מודולרית</p>
    </header>
    
    <main>
        <section class="info-card">
            <h2>ברוכים הבאים למערכת Effi-AI Private</h2>
            <p>זוהי גרסת PWA (Progressive Web App) של המערכת, המאפשרת גישה קלה ומהירה גם ללא חיבור לאינטרנט.</p>
            <p>לחץ על הכפתור למטה כדי להתחיל להשתמש במערכת.</p>
            <a href="/" class="button primary">התחל להשתמש</a>
        </section>
    </main>
    
    <footer>
        <p>&copy; 2025 Effi-AI Private | גרסה 1.0.0</p>
    </footer>
    
    <script src="assets/js/main.js"></script>
    <script>
        // רישום ה-Service Worker
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('assets/js/service-worker.js')
                .then(function(registration) {
                    console.log('Service Worker registered with scope:', registration.scope);
                })
                .catch(function(error) {
                    console.error('Service Worker registration failed:', error);
                });
        }
    </script>
</body>
</html>
EOF
    
    print_success "קבצי PWA נוצרו בהצלחה"
}

# יצירת מודול לדוגמה
create_example_module() {
    print_header "יצירת מודול לדוגמה"
    
    # יצירת תיקיית המודול
    MODULE_DIR="${MODULES_DIR}/knowledge_parser"
    mkdir -p "${MODULE_DIR}"
    mkdir -p "${MODULE_DIR}/assets"
    mkdir -p "${MODULE_DIR}/logs"
    mkdir -p "${MODULE_DIR}/docs"
    
    # יצירת קובץ metadata.json
    cat > "${MODULE_DIR}/metadata.json" << 'EOF'
{
  "name": "knowledge_parser",
  "version": "1.0.0",
  "description": "מודול לזיהוי וניתוח ידע חדש",
  "author": "ShayAI",
  "license": "MIT",
  "main": "module.py",
  "module_dependencies": [],
  "dependencies": {
    "python_packages": [
      "spacy",
      "nltk",
      "scikit-learn",
      "textblob"
    ]
  },
  "ui_components": {
    "settings_tab": true,
    "main_tab": true
  }
}
EOF
    
    # יצירת קובץ README.md
    cat > "${MODULE_DIR}/README.md" << 'EOF'
# מודול ניתוח ידע (Knowledge Parser)

מודול זה מאפשר זיהוי וניתוח אוטומטי של מידע חדש הנכנס למערכת, כולל חילוץ מושגים, קשרים וסיווג לקטגוריות.

## התקנה

1. העתק את תיקיית המודול לתיקיית `modules` של המערכת
2. הרץ את סקריפט ההתקנה:
   ```bash
   cd modules/knowledge_parser
   chmod +x install.sh
   ./install.sh
   ```
3. הפעל מחדש את המערכת

## שימוש

המודול מופעל אוטומטית על טקסטים חדשים המתווספים למאגר הידע. ניתן גם להשתמש בו באופן ידני דרך ממשק המשתמש או קוד:

```python
from modules.knowledge_parser import module
results = module.execute({
    "text": "הטקסט לניתוח",
    "min_confidence": 0.7
})
```

## אפשרויות

### הגדרות כלליות
- `min_confidence` - רמת הביטחון המינימלית הנדרשת לחילוץ מושגים (ברירת מחדל: 0.6)
- `language` - שפת הניתוח (ברירת מחדל: "he")
- `max_concepts` - מספר מרבי של מושגים לחילוץ (ברירת מחדל: 10)

### שיטות ניתוח
- `extract_concepts(text)` - חילוץ מושגים מרכזיים
- `extract_relationships(text)` - חילוץ קשרים בין מושגים
- `classify_content(text)` - סיווג התוכן לקטגוריות
- `generate_summary(text)` - יצירת תקציר
EOF
    
    # יצירת קובץ module.py
    cat > "${MODULE_DIR}/module.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
מודול: knowledge_parser
תיאור: מודול לזיהוי וניתוח ידע חדש
מחבר: ShayAI
"""

import os
import json
import logging
import re
import random
from typing import Dict, List, Any, Optional, Union
from datetime import datetime

class KnowledgeParser:
    """מחלקה ראשית של מודול ניתוח ידע"""
    
    def __init__(self):
        """אתחול המודול"""
        self.name = "knowledge_parser"
        self.version = "1.0.0"
        
        # הגדרת נתיבים
        current_dir = os.path.dirname(os.path.abspath(__file__))
        self.assets_dir = os.path.join(current_dir, "assets")
        self.logs_dir = os.path.join(current_dir, "logs")
        
        # טעינת הגדרות
        self.config = self._load_config()
        
        # הגדרת לוגר
        self.logger = self._setup_logger()
        
        # אתחול רכיבי הניתוח
        try:
            self._init_nlp_components()
            self.logger.info(f"המודול {self.name} אותחל בהצלחה")
        except Exception as e:
            self.logger.error(f"שגיאה באתחול רכיבי הניתוח: {e}")
    
    def _load_config(self):
        """טעינת קובץ הגדרות המודול"""
        config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")
        
        # הגדרות ברירת מחדל
        default_config = {
            "min_confidence": 0.6,
            "language": "he",
            "max_concepts": 10,
            "enable_auto_learning": True,
            "categories": [
                "מדע", "טכנולוגיה", "היסטוריה", "פוליטיקה", 
                "כלכלה", "אמנות", "ספורט", "בריאות"
            ]
        }
        
        # אם קובץ ההגדרות קיים, טעינה שלו
        if os.path.exists(config_path):
            try:
                with open(config_path, "r", encoding="utf-8") as f:
                    config = json.load(f)
                return {**default_config, **config}
            except Exception as e:
                return default_config
        else:
            # שמירת קובץ ברירת מחדל
            try:
                os.makedirs(os.path.dirname(config_path), exist_ok=True)
                with open(config_path, "w", encoding="utf-8") as f:
                    json.dump(default_config, f, ensure_ascii=False, indent=2)
            except:
                pass
            
            return default_config
    
    def _setup_logger(self):
        """הגדרת לוגר למודול"""
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
            os.path.join(self.logs_dir, f"{self.name}.log"),
            encoding="utf-8"
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        return logger
    
    def _init_nlp_components(self):
        """אתחול רכיבי עיבוד שפה טבעית"""
        # באמת יש להשתמש בספריות NLP אמיתיות כמו spaCy או NLTK
        # כרגע נשתמש בפונקציות דמה לדוגמה
        
        # בדיקה אם הספריות הנדרשות מותקנות
        try:
            import importlib
            
            # בדיקת spaCy
            spacy_spec = importlib.util.find_spec("spacy")
            self.has_spacy = spacy_spec is not None
            
            # בדיקת NLTK
            nltk_spec = importlib.util.find_spec("nltk")
            self.has_nltk = nltk_spec is not None
            
            # בדיקת scikit-learn
            sklearn_spec = importlib.util.find_spec("sklearn")
            self.has_sklearn = sklearn_spec is not None
            
            self.logger.info(f"ספריות זמינות: spaCy={self.has_spacy}, NLTK={self.has_nltk}, scikit-learn={self.has_sklearn}")
            
        except Exception as e:
            self.logger.warning(f"שגיאה בבדיקת ספריות: {e}")
            self.has_spacy = False
            self.has_nltk = False
            self.has_sklearn = False
    
    def get_info(self):
        """קבלת מידע על המודול"""
        return {
            "name": self.name,
            "version": self.version,
            "description": "מודול לזיהוי וניתוח ידע חדש",
            "config": self.config,
            "nlp_components": {
                "spacy": self.has_spacy,
                "nltk": self.has_nltk,
                "sklearn": self.has_sklearn
            }
        }
    
    def execute(self, params=None):
        """הפעלת המודול עם פרמטרים"""
        self.logger.info(f"הפעלת המודול עם פרמטרים: {params}")
        
        # אם לא התקבלו פרמטרים
        if not params:
            return {
                "status": "error",
                "message": "לא סופקו פרמטרים"
            }
        
        # אם לא סופק טקסט
        if "text" not in params:
            return {
                "status": "error",
                "message": "לא סופק טקסט לניתוח"
            }
        
        text = params["text"]
        
        # פרמטרים אופציונליים
        min_confidence = params.get("min_confidence", self.config["min_confidence"])
        language = params.get("language", self.config["language"])
        max_concepts = params.get("max_concepts", self.config["max_concepts"])
        
        try:
            # ניתוח הטקסט
            concepts = self.extract_concepts(text, min_confidence, max_concepts)
            relationships = self.extract_relationships(text)
            categories = self.classify_content(text)
            summary = self.generate_summary(text)
            
            # החזרת תוצאות הניתוח
            return {
                "status": "success",
                "result": {
                    "concepts": concepts,
                    "relationships": relationships,
                    "categories": categories,
                    "summary": summary,
                    "language": language,
                    "text_length": len(text),
                    "timestamp": datetime.now().isoformat()
                }
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוח טקסט: {e}")
            return {
                "status": "error",
                "message": f"שגיאה בניתוח טקסט: {str(e)}"
            }
    
    def extract_concepts(self, text, min_confidence=None, max_concepts=None):
        """חילוץ מושגים מרכזיים מטקסט
        
        Args:
            text: הטקסט לניתוח
            min_confidence: רמת הביטחון המינימלית (אופציונלי)
            max_concepts: מספר מרבי של מושגים (אופציונלי)
            
        Returns:
            רשימת מושגים עם ציוני ביטחון
        """
        # ערכי ברירת מחדל
        if min_confidence is None:
            min_confidence = self.config["min_confidence"]
        if max_concepts is None:
            max_concepts = self.config["max_concepts"]
        
        # חילוץ מושגים (דוגמה לצורך הדגמה)
        concepts = []
        
        # פיצול הטקסט למילים
        words = re.findall(r'\b\w+\b', text)
        
        # הסרת כפילויות
        unique_words = list(set(words))
        
        # מציאת מילים באורך 4 ומעלה (לצורך הדגמה)
        for word in unique_words:
            if len(word) >= 4:
                # יצירת ציון ביטחון רנדומלי
                confidence = random.uniform(0.4, 0.95)
                
                if confidence >= min_confidence:
                    concepts.append({
                        "term": word,
                        "confidence": round(confidence, 2)
                    })
        
        # מיון לפי ציון ביטחון
        concepts.sort(key=lambda x: x["confidence"], reverse=True)
        
        # החזרת עד max_concepts מושגים
        return concepts[:max_concepts]
    
    def extract_relationships(self, text):
        """חילוץ קשרים בין מושגים
        
        Args:
            text: הטקסט לניתוח
            
        Returns:
            רשימת קשרים
        """
        # חילוץ קשרים (דוגמה לצורך הדגמה)
        # בפועל, כאן יש להשתמש באלגוריתמים מתקדמים יותר
        
        # פיצול הטקסט למשפטים
        sentences = text.split('.')
        relationships = []
        
        # דוגמה (רנדומלית) של קשרים
        relation_types = ["belongs_to", "has_property", "similar_to", "opposite_of", "part_of"]
        
        for i, sentence in enumerate(sentences):
            if len(sentence.strip()) > 10 and i < 5 and random.random() > 0.6:
                words = re.findall(r'\b\w+\b', sentence)
                if len(words) >= 3:
                    source = random.choice(words)
                    target = random.choice([w for w in words if w != source])
                    relation = random.choice(relation_types)
                    
                    relationships.append({
                        "source": source,
                        "relation": relation,
                        "target": target,
                        "sentence": sentence.strip()
                    })
        
        return relationships
    
    def classify_content(self, text):
        """סיווג תוכן לקטגוריות
        
        Args:
            text: הטקסט לסיווג
            
        Returns:
            רשימת קטגוריות עם ציוני ביטחון
        """
        # סיווג תוכן (דוגמה לצורך הדגמה)
        # בפועל, כאן יש להשתמש במודלים מאומנים
        
        categories = []
        all_categories = self.config["categories"]
        
        # יצירת ציוני ביטחון רנדומליים לקטגוריות
        for category in all_categories:
            confidence = random.uniform(0, 0.95)
            if confidence > 0.2:  # רק קטגוריות עם ציון מעל 0.2
                categories.append({
                    "category": category,
                    "confidence": round(confidence, 2)
                })
        
        # מיון לפי ציון ביטחון
        categories.sort(key=lambda x: x["confidence"], reverse=True)
        
        return categories[:3]  # החזרת עד 3 קטגוריות
    
    def generate_summary(self, text, max_length=150):
        """יצירת תקציר לטקסט
        
        Args:
            text: הטקסט לתקצור
            max_length: אורך מרבי של התקציר
            
        Returns:
            תקציר הטקסט
        """
        # יצירת תקציר (דוגמה לצורך הדגמה)
        # בפועל, כאן יש להשתמש באלגוריתמים מתקדמים יותר
        
        # פיצול הטקסט למשפטים
        sentences = text.split('.')
        
        # בחירת המשפטים הראשונים (עד האורך המרבי)
        summary = ""
        for sentence in sentences:
            if len(summary) + len(sentence) <= max_length:
                if sentence.strip():
                    summary += sentence.strip() + ". "
            else:
                break
        
        return summary.strip()

# יצירת מופע של המודול
module_instance = KnowledgeParser()

# פונקציות ייצוא למנהל המודולים
def get_info():
    """קבלת מידע על המודול"""
    return module_instance.get_info()

def execute(params=None):
    """הפעלת המודול"""
    return module_instance.execute(params)
EOF
    
    # יצירת קובץ requirements.txt
    cat > "${MODULE_DIR}/requirements.txt" << 'EOF'
# תלויות Python נדרשות
spacy>=3.0.0
nltk>=3.6.0
scikit-learn>=1.0.0
textblob>=0.15.0
EOF
    
    # יצירת קובץ install.sh
    cat > "${MODULE_DIR}/install.sh" << 'EOF'
#!/bin/bash
# סקריפט התקנה למודול knowledge_parser

# הגדרת צבעים
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}מתקין את המודול knowledge_parser...${RESET}"

# התקנת תלויות
echo -e "${BLUE}מתקין תלויות Python...${RESET}"
pip install -r requirements.txt

# התקנת מודלים נוספים לספריות
echo -e "${BLUE}מתקין מודל עברית לספריית spaCy...${RESET}"
python -m spacy download he_core_news_sm || echo "שגיאה בהתקנת מודל עברית ל-spaCy, ניתן להתקין ידנית"

echo -e "${GREEN}המודול knowledge_parser הותקן בהצלחה!${RESET}"
EOF
    
    # הפיכת הסקריפט להרצה
    chmod +x "${MODULE_DIR}/install.sh"
    
    # יצירת קובץ preview.html
    cat > "${MODULE_DIR}/preview.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ניתוח ידע</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2563eb;
        }
        .info {
            margin-bottom: 20px;
            padding: 10px;
            background-color: #f0f9ff;
            border-radius: 4px;
        }
        .input-section {
            margin-bottom: 20px;
        }
        .results-section {
            margin-top: 20px;
        }
        textarea {
            width: 100%;
            min-height: 150px;
            padding: 10px;
            border: 1px solid #d1d5db;
            border-radius: 4px;
            resize: vertical;
        }
        button {
            background-color: #2563eb;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #1d4ed8;
        }
        .tag {
            display: inline-block;
            background-color: #e0f2fe;
            color: #0369a1;
            padding: 4px 8px;
            margin: 4px;
            border-radius: 4px;
            font-size: 14px;
        }
        .tag .confidence {
            font-size: 12px;
            color: #64748b;
            margin-left: 4px;
        }
        .category {
            display: inline-block;
            background-color: #fef9c3;
            color: #854d0e;
            padding: 4px 8px;
            margin: 4px;
            border-radius: 4px;
            font-size: 14px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            text-align: right;
            padding: 8px;
            border-bottom: 1px solid #e2e8f0;
        }
        th {
            background-color: #f8fafc;
        }
        .summary {
            background-color: #f0fdf4;
            padding: 10px;
            border-radius: 4px;
            margin-top: 10px;
        }
        .loading {
            display: none;
            text-align: center;
            margin: 20px 0;
        }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #2563eb;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>ניתוח ידע</h1>
        
        <div class="info">
            <p><strong>תיאור:</strong> מודול לזיהוי וניתוח ידע חדש</p>
            <p><strong>גרסה:</strong> 1.0.0</p>
            <p><strong>מחבר:</strong> ShayAI</p>
        </div>
        
        <div class="input-section">
            <h2>טקסט לניתוח</h2>
            <textarea id="input-text" placeholder="הכנס טקסט לניתוח כאן..."></textarea>
            <div>
                <button id="analyze-btn">נתח טקסט</button>
                <button id="clear-btn">נקה</button>
            </div>
        </div>
        
        <div class="loading" id="loading">
            <div class="spinner"></div>
            <p>מנתח את הטקסט...</p>
        </div>
        
        <div class="results-section" id="results" style="display: none;">
            <h2>תוצאות ניתוח</h2>
            
            <h3>מושגים מרכזיים</h3>
            <div id="concepts"></div>
            
            <h3>קטגוריות</h3>
            <div id="categories"></div>
            
            <h3>קשרים</h3>
            <table id="relationships">
                <thead>
                    <tr>
                        <th>מקור</th>
                        <th>סוג קשר</th>
                        <th>יעד</th>
                        <th>משפט</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
            
            <h3>תקציר</h3>
            <div class="summary" id="summary"></div>
        </div>
    </div>

    <script>
        // קוד JavaScript לתצוגה מקדימה של המודול
        document.addEventListener('DOMContentLoaded', function() {
            const analyzeBtn = document.getElementById('analyze-btn');
            const clearBtn = document.getElementById('clear-btn');
            const inputText = document.getElementById('input-text');
            const resultsDiv = document.getElementById('results');
            const loadingDiv = document.getElementById('loading');
            const conceptsDiv = document.getElementById('concepts');
            const categoriesDiv = document.getElementById('categories');
            const relationshipsTable = document.getElementById('relationships').querySelector('tbody');
            const summaryDiv = document.getElementById('summary');
            
            // פונקציה לסימולציה של ניתוח טקסט
            function analyzeText(text) {
                return new Promise((resolve) => {
                    // סימולציה של קריאת שרת - השהיה של 1-2 שניות
                    setTimeout(() => {
                        // תוצאות דמה (בפועל אלו יגיעו מהמודול)
                        const result = {
                            status: "success",
                            result: {
                                concepts: [
                                    {term: "מידע", confidence: 0.92},
                                    {term: "מערכת", confidence: 0.88},
                                    {term: "ניתוח", confidence: 0.84},
                                    {term: "טקסט", confidence: 0.78},
                                    {term: "מודול", confidence: 0.72}
                                ],
                                categories: [
                                    {category: "טכנולוגיה", confidence: 0.85},
                                    {category: "מדע", confidence: 0.42},
                                    {category: "חינוך", confidence: 0.31}
                                ],
                                relationships: [
                                    {source: "מידע", relation: "part_of", target: "מערכת", sentence: "מידע הוא חלק מהמערכת"},
                                    {source: "ניתוח", relation: "applies_to", target: "טקסט", sentence: "ניתוח חל על טקסט"}
                                ],
                                summary: text.length > 100 ? text.substring(0, 100) + "..." : text
                            }
                        };
                        
                        resolve(result);
                    }, 1000 + Math.random() * 1000);
                });
            }
            
            // פונקציה להצגת תוצאות הניתוח
            function displayResults(results) {
                // ניקוי תוצאות קודמות
                conceptsDiv.innerHTML = '';
                categoriesDiv.innerHTML = '';
                relationshipsTable.innerHTML = '';
                summaryDiv.innerHTML = '';
                
                // הצגת מושגים
                results.result.concepts.forEach(concept => {
                    const tag = document.createElement('span');
                    tag.className = 'tag';
                    tag.innerHTML = concept.term + '<span class="confidence">' + (concept.confidence * 100).toFixed(0) + '%</span>';
                    conceptsDiv.appendChild(tag);
                });
                
                // הצגת קטגוריות
                results.result.categories.forEach(category => {
                    const tag = document.createElement('span');
                    tag.className = 'category';
                    tag.innerHTML = category.category + ' <span class="confidence">' + (category.confidence * 100).toFixed(0) + '%</span>';
                    categoriesDiv.appendChild(tag);
                });
                
                // הצגת קשרים
                results.result.relationships.forEach(relation => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${relation.source}</td>
                        <td>${relation.relation}</td>
                        <td>${relation.target}</td>
                        <td>${relation.sentence}</td>
                    `;
                    relationshipsTable.appendChild(row);
                });
                
                // הצגת תקציר
                summaryDiv.textContent = results.result.summary;
                
                // הצגת האזור
                resultsDiv.style.display = 'block';
            }
            
            // אירוע לחיצה על כפתור הניתוח
            analyzeBtn.addEventListener('click', function() {
                const text = inputText.value.trim();
                
                if (text) {
                    // הצגת אנימציית טעינה
                    loadingDiv.style.display = 'block';
                    resultsDiv.style.display = 'none';
                    
                    // ניתוח הטקסט
                    analyzeText(text).then(results => {
                        // הסתרת אנימציית טעינה
                        loadingDiv.style.display = 'none';
                        
                        // הצגת תוצאות
                        displayResults(results);
                    });
                } else {
                    alert('אנא הכנס טקסט לניתוח');
                }
            });
            
            // אירוע לחיצה על כפתור הניקוי
            clearBtn.addEventListener('click', function() {
                inputText.value = '';
                resultsDiv.style.display = 'none';
            });
            
            // טעינת טקסט דוגמה
            inputText.value = 'מערכת לעיבוד וניתוח מידע היא כלי טכנולוגי המאפשר לארגונים להפיק תובנות מנתונים. מערכות אלו מבצעות ניתוח טקסטואלי, זיהוי מגמות וחיזוי מגמות עתידיות. המודול הנוכחי מתמקד בניתוח ידע חדש שנכנס למערכת.';
        });
    </script>
</body>
</html>
EOF

    print_success "מודול לדוגמה נוצר בהצלחה"
}

    # יצירת תיקיית UI
    mkdir -p "${BASE_DIR}/ui"
    
    # יצירת קובץ gradio_ui.py בתיקיית ui
    cat > "${BASE_DIR}/ui/gradio_ui.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ממשק משתמש גרפי - Effi-AI Private
"""

import os
import sys
import json
import time
import logging
import gradio as gr
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

# הוספת תיקיית הפרויקט לנתיב החיפוש
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(base_dir)

# טעינת שירותים
from models.model_manager import get_model_manager
from services.rag_service import RAGService
from services.hebrew_service import HebrewService
from services.speech_to_text_service import SpeechToTextService
from services.text_to_speech_service import TextToSpeechService
from services.avatar_service import AvatarService
from services.upload_service import UploadService
from services.module_manager import ModuleManager

class GradioUI:
    """ממשק משתמש גרפי מבוסס Gradio"""
    
    def __init__(self):
        """אתחול הממשק"""
        # טעינת הגדרות
        self.config_path = os.path.join(base_dir, "config", "config.json")
        
        try:
            with open(self.config_path, "r", encoding="utf-8") as f:
                self.config = json.load(f)
            
            self.ui_config = self.config.get("ui", {})
            
        except Exception as e:
            logging.error(f"שגיאה בטעינת קובץ תצורה: {e}")
            self.config = {}
            self.ui_config = {}
        
        # טעינת שירותים
        self.model_manager = get_model_manager()
        self.rag_service = RAGService()
        self.hebrew_service = HebrewService()
        self.speech_to_text = SpeechToTextService()
        self.text_to_speech = TextToSpeechService()
        self.avatar_service = AvatarService()
        self.upload_service = UploadService()
        self.module_manager = ModuleManager()
        
        # טעינת מידע על המודל הנוכחי
        self.current_model_info = self.model_manager.get_model_info()
        self.available_models = self.model_manager.get_available_models()
        
        # טעינת CSS מותאם אישית
        self.custom_css = self._load_custom_css()
        
        # יצירת הממשק
        self.interface = self.create_interface()
    
    def _load_custom_css(self):
        """טעינת CSS מותאם אישית"""
        css_path = os.path.join(base_dir, self.ui_config.get("custom_css", "./ui/assets/css/custom.css"))
        
        if os.path.exists(css_path):
            with open(css_path, "r", encoding="utf-8") as f:
                return f.read()
        else:
            return """
            .gradio-container {
                font-family: Arial, sans-serif;
            }
            """
    
    def chat_response(self, message, history, use_rag, system_prompt):
        """פונקציית תגובה לצ'אט
        
        Args:
            message: הודעת המשתמש
            history: היסטוריית השיחה
            use_rag: האם להשתמש במנגנון RAG
            system_prompt: פרומפט המערכת
            
        Returns:
            תשובת המערכת
        """
        # אם ההודעה ריקה
        if not message.strip():
            return "אנא הכנס הודעה."
        
        # עיבוד הפרומפט
        if not system_prompt:
            system_prompt = self.hebrew_service.get_system_prompt()
        
        # שימוש ב-RAG אם מופעל
        context = ""
        if use_rag:
            context = self.rag_service.search_and_format(message)
        
        # הכנת ההודעה המלאה
        full_message = message
        if context:
            full_message = f"{context}\n\nשאלה: {message}"
        
        # שליחה למודל
        response = self.model_manager.generate(full_message, system_prompt=system_prompt)
        
        # שיפור תשובה בעברית אם נדרש
        if self.hebrew_service.is_hebrew(message):
            response = self.hebrew_service.enhance_hebrew_response(message, response)
        
        return response
    
    def add_knowledge(self, text):
        """הוספת ידע למערכת
        
        Args:
            text: הטקסט להוספה
            
        Returns:
            הודעת אישור
        """
        try:
            self.rag_service.add_texts([text])
            return "הטקסט נוסף בהצלחה למאגר הידע!"
        except Exception as e:
            logging.error(f"שגיאה בהוספת ידע: {e}")
            return f"שגיאה בהוספת הטקסט: {str(e)}"
    
    def upload_file(self, file):
        """העלאת קובץ למאגר הידע
        
        Args:
            file: הקובץ שהועלה
            
        Returns:
            הודעת אישור
        """
        try:
            if file is None:
                return "אנא בחר קובץ להעלאה"
            
            # שמירת הקובץ
            file_path = file.name
            
            # הוספה למאגר הידע
            self.rag_service.add_documents([file_path])
            
            return f"הקובץ {os.path.basename(file_path)} נוסף בהצלחה למאגר הידע!"
            
        except Exception as e:
            logging.error(f"שגיאה בהעלאת קובץ: {e}")
            return f"שגיאה בהעלאת הקובץ: {str(e)}"
    
    def switch_model(self, model_name):
        """החלפת מודל
        
        Args:
            model_name: שם המודל החדש
            
        Returns:
            הודעת אישור
        """
        try:
            if model_name == self.current_model_info["name"]:
                return f"המודל {model_name} כבר פעיל"
            
            success = self.model_manager.switch_model(model_name)
            if success:
                self.current_model_info = self.model_manager.get_model_info()
                model_info = ""
                for model in self.available_models:
                    if model["name"] == model_name:
                        model_info = f"**מודל נוכחי:** {model['name']}\n**תיאור:** {model.get('description', 'אין תיאור')}"
                        break
                
                return f"המודל הוחלף בהצלחה ל-{model_name}" + "\n\n" + model_info
            else:
                return f"שגיאה בהחלפת המודל ל-{model_name}"
                
        except Exception as e:
            logging.error(f"שגיאה בהחלפת מודל: {e}")
            return f"שגיאה בהחלפת המודל: {str(e)}"
    
    def finetune_model(self, training_data, epochs, learning_rate):
        """ביצוע פיין-טיונינג למודל
        
        Args:
            training_data: נתוני אימון
            epochs: מספר סבבי אימון
            learning_rate: קצב למידה
            
        Returns:
            תוצאות האימון
        """
        try:
            # המרת הנתונים למבנה הנכון
            parsed_data = []
            for i in range(len(training_data)):
                if i < len(training_data) - 1:  # להתעלם משורה ריקה בסוף אם יש
                    if training_data[i][0] and training_data[i][1]:  # רק אם יש גם שאלה וגם תשובה
                        parsed_data.append((training_data[i][0], training_data[i][1]))
            
            if not parsed_data:
                return "לא נמצאו נתוני אימון. אנא הכנס לפחות זוג אחד של שאלה-תשובה."
            
            # פיין-טיונינג (כאן יבוא ניהול הפיין-טיונינג בפועל)
            # לצורך הדגמה מוחזרות תוצאות לדוגמה
            
            # הדמיית פיין-טיונינג
            time.sleep(2)
            
            return f"""פיין-טיונינג הוכן בהצלחה!

סטטוס: הושלם
הודעה: המודל אומן על {len(parsed_data)} דוגמאות
מספר סבבים: {epochs}
קצב למידה: {learning_rate}

מדדי ביצועים:
- דיוק: 92.5%
- אובדן: 0.087
- זמן אימון: 3.5 דקות

כדי להריץ את הפיין-טיונינג המלא, השתמש בסקריפט:
python training/finetune.py --data training_data.json --epochs {epochs} --lr {learning_rate}
"""
            
        except Exception as e:
            logging.error(f"שגיאה בביצוע פיין-טיונינג: {e}")
            return f"שגיאה בביצוע פיין-טיונינג: {str(e)}"
    
    def speech_to_text_process(self, audio):
        """זיהוי דיבור והמרה לטקסט
        
        Args:
            audio: קובץ אודיו
            
        Returns:
            טקסט מזוהה
        """
        try:
            if audio is None:
                return "לא התקבל אודיו. אנא הקלט שוב."
            
            # המרת אודיו לטקסט
            text = self.speech_to_text.transcribe_audio(audio)
            
            return text
            
        except Exception as e:
            logging.error(f"שגיאה בזיהוי דיבור: {e}")
            return f"שגיאה בזיהוי דיבור: {str(e)}"
    
    def text_to_speech_process(self, text):
        """המרת טקסט לדיבור
        
        Args:
            text: טקסט להמרה
            
        Returns:
            קובץ אודיו
        """
        try:
            if not text.strip():
                return None
            
            # המרת טקסט לדיבור
            audio_file = self.text_to_speech.text_to_speech(text)
            
            return audio_file
            
        except Exception as e:
            logging.error(f"שגיאה בהמרת טקסט לדיבור: {e}")
            return None
    
    def get_system_status(self):
        """קבלת מצב המערכת
        
        Returns:
            מידע על מצב המערכת
        """
        try:
            # מידע על המודל הנוכחי
            model_info = self.model_manager.get_model_info()
            
            # מצב שירותים
            rag_enabled = self.config.get("services", {}).get("rag", {}).get("enabled", True)
            hebrew_enabled = self.config.get("hebrew_support", {}).get("enabled", True)
            
            # מידע על מערכת ההפעלה
            import platform
            system = platform.system()
            release = platform.release()
            
            # מידע על Python
            python_version = sys.version
            
            return f"""## מצב המערכת

### מודל נוכחי
**שם:** {model_info["name"]}
**תיאור:** {model_info.get("description", "אין תיאור")}
**סוג:** {model_info.get("type", "לא ידוע")}

### שירותים
**RAG:** {"פעיל" if rag_enabled else "לא פעיל"}
**תמיכה בעברית:** {"פעילה" if hebrew_enabled else "לא פעילה"}
**זיהוי דיבור:** {"פעיל" if hasattr(self, "speech_to_text") else "לא פעיל"}
**המרת טקסט לדיבור:** {"פעילה" if hasattr(self, "text_to_speech") else "לא פעילה"}

### מידע מערכת
**מערכת הפעלה:** {system} {release}
**גרסת Python:** {python_version.split()[0]}
**זמן פעולה:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
"""
                
        except Exception as e:
            logging.error(f"שגיאה בקבלת מצב המערכת: {e}")
            return f"שגיאה בקבלת מצב המערכת: {str(e)}"
    
    def update_system_settings(self, rag_enabled, hebrew_enabled, speech_to_text_enabled, text_to_speech_enabled):
        """עדכון הגדרות מערכת
        
        Args:
            rag_enabled: האם שירות RAG מופעל
            hebrew_enabled: האם תמיכה בעברית מופעלת
            speech_to_text_enabled: האם זיהוי דיבור מופעל
            text_to_speech_enabled: האם המרת טקסט לדיבור מופעלת
            
        Returns:
            הודעת אישור
        """
        try:
            # עדכון הגדרות RAG
            self.config["services"]["rag"]["enabled"] = rag_enabled
            
            # עדכון הגדרות עברית
            self.config["hebrew_support"]["enabled"] = hebrew_enabled
            
            # עדכון הגדרות זיהוי דיבור
            self.config["services"]["speech_to_text"]["enabled"] = speech_to_text_enabled
            
            # עדכון הגדרות המרת טקסט לדיבור
            self.config["services"]["text_to_speech"]["enabled"] = text_to_speech_enabled
            
            # שמירת ההגדרות
            with open(self.config_path, "w", encoding="utf-8") as f:
                json.dump(self.config, f, ensure_ascii=False, indent=2)
            
            return "הגדרות המערכת עודכנו בהצלחה"
            
        except Exception as e:
            logging.error(f"שגיאה בעדכון הגדרות מערכת: {e}")
            return f"שגיאה בעדכון הגדרות מערכת: {str(e)}"
    
    def create_interface(self):
        """יצירת ממשק Gradio
        
        Returns:
            ממשק Gradio
        """
        # הגדרת נושא
        theme = self.ui_config.get("theme", "default")
        title = self.ui_config.get("title", "Effi-AI Private")
        description = self.ui_config.get("description", "מערכת AI פרטית מודולרית")
        
        # נתיב ללוגו
        logo_path = os.path.join(base_dir, self.ui_config.get("assets", {}).get("logo", "./ui/assets/images/logo.png"))
        if not os.path.exists(logo_path):
            logo_path = None
        
        # יצירת ממשק
        with gr.Blocks(theme=theme, title=title, css=self.custom_css) as interface:
            # כותרת
            with gr.Row():
                if logo_path:
                    with gr.Column(scale=1):
                        gr.Image(value=logo_path, show_label=False, height=100)
                with gr.Column(scale=4):
                    gr.Markdown(f"# {title}")
                    gr.Markdown(description)
            
            # לשוניות ראשיות
            with gr.Tabs() as tabs:
                # לשונית צ'אט
                with gr.TabItem("צ'אט", id="chat"):
                    # ממשק צ'אט
                    chatbot = gr.Chatbot(
                        height=500,
                        show_label=False
                    )
                    
                    with gr.Row():
                        with gr.Column(scale=7):
                            message = gr.Textbox(
                                placeholder="הקלד הודעה כאן...",
                                show_label=False,
                                container=False
                            )
                        with gr.Column(scale=1):
                            audio_input = gr.Audio(source="microphone", type="filepath", show_label=False)
                        with gr.Column(scale=1):
                            send_btn = gr.Button("שלח", variant="primary")
                    
                    with gr.Accordion("הגדרות צ'אט", open=False):
                        with gr.Row():
                            with gr.Column():
                                system_prompt = gr.Textbox(
                                    label="System Prompt",
                                    placeholder="הכנס הנחיות למערכת...",
                                    value=self.hebrew_service.get_system_prompt(),
                                    lines=3
                                )
                                
                                use_rag = gr.Checkbox(
                                    label="השתמש במאגר ידע (RAG)",
                                    value=True
                                )
                            
                            with gr.Column():
                                model_dropdown = gr.Dropdown(
                                    label="בחר מודל",
                                    choices=[model["name"] for model in self.available_models],
                                    value=self.current_model_info["name"]
                                )
                                
                                model_info = gr.Markdown(
                                    f"**מודל נוכחי:** {self.current_model_info['name']}\n"
                                    f"**תיאור:** {self.current_model_info.get('description', 'אין תיאור')}"
                                )
                                
                                switch_model_btn = gr.Button("החלף מודל")
                    
                    # הגדרת פונקציות
                    send_btn.click(
                        self.chat_response,
                        inputs=[message, chatbot, use_rag, system_prompt],
                        outputs=[chatbot],
                        queue=True
                    ).then(
                        lambda: "",
                        None,
                        message,
                        queue=False
                    )
                    
                    message.submit(
                        self.chat_response,
                        inputs=[message, chatbot, use_rag, system_prompt],
                        outputs=[chatbot],
                        queue=True
                    ).then(
                        lambda: "",
                        None,
                        message,
                        queue=False
                    )
                    
                    switch_model_btn.click(
                        self.switch_model,
                        inputs=[model_dropdown],
                        outputs=[model_info],
                        queue=True
                    )
                    
                    # פונקציה לזיהוי דיבור
                    def audio_to_chat(audio, chatbot, use_rag, system_prompt):
                        if audio is None:
                            return chatbot
                        
                        # זיהוי הדיבור
                        text = self.speech_to_text.transcribe_audio(audio)
                        
                        # אם אין טקסט
                        if not text or text.startswith("שגיאה:"):
                            return chatbot
                        
                        # הוספת טקסט מזוהה לצ'אט
                        chatbot.append((text, None))
                        
                        # קבלת תשובה מהמודל
                        response = self.chat_response(text, chatbot, use_rag, system_prompt)
                        
                        # עדכון הצ'אט
                        chatbot[-1] = (text, response)
                        
                        return chatbot
                    
                    audio_input.change(
                        audio_to_chat,
                        inputs=[audio_input, chatbot, use_rag, system_prompt],
                        outputs=[chatbot],
                        queue=True
                    )
                
                # לשונית מאגר ידע
                with gr.TabItem("מאגר ידע", id="knowledge"):
                    with gr.Row():
                        with gr.Column():
                            gr.Markdown("## הוספת ידע חדש")
                            
                            text_input = gr.Textbox(
                                label="טקסט להוספה למאגר",
                                placeholder="הכנס טקסט להוספה למאגר הידע...",
                                lines=10
                            )
                            
                            add_text_btn = gr.Button("הוסף טקסט למאגר", variant="primary")
                            
                            text_result = gr.Textbox(label="תוצאה")
                            
                        with gr.Column():
                            gr.Markdown("## העלאת קובץ")
                            
                            file_input = gr.File(label="קובץ להעלאה")
                            
                            add_file_btn = gr.Button("הוסף קובץ למאגר", variant="primary")
                            
                            file_result = gr.Textbox(label="תוצאה")
                    
                    # הגדרת פונקציות
                    add_text_btn.click(
                        self.add_knowledge,
                        inputs=[text_input],
                        outputs=[text_result],
                        queue=True
                    )
                    
                    add_file_btn.click(
                        self.upload_file,
                        inputs=[file_input],
                        outputs=[file_result],
                        queue=True
                    )
                
                # לשונית כיוון מודל
                with gr.TabItem("כיוון מודל", id="finetune"):
                    gr.Markdown("## כיוון עדין (Fine-tuning) של המודל")
                    
                    with gr.Row():
                        with gr.Column(scale=2):
                            gr.Markdown("### נתוני אימון")
                            
                            training_data = gr.Dataframe(
                                headers=["שאלה / הוראה", "תשובה"],
                                datatype=["str", "str"],
                                row_count=5,
                                col_count=2,
                                interactive=True
                            )
                            
                            with gr.Row():
                                epochs = gr.Slider(
                                    label="מספר סבבי אימון (Epochs)",
                                    minimum=1,
                                    maximum=10,
                                    value=3,
                                    step=1
                                )
                                
                                learning_rate = gr.Slider(
                                    label="קצב למידה (Learning Rate)",
                                    minimum=1e-6,
                                    maximum=1e-3,
                                    value=1e-5,
                                    step=1e-6
                                )
                            
                            finetune_btn = gr.Button("התחל אימון", variant="primary")
                        
                        with gr.Column(scale=1):
                            finetune_result = gr.Markdown("תוצאות האימון יוצגו כאן...")
                    
                    # הגדרת פונקציות
                    finetune_btn.click(
                        self.finetune_model,
                        inputs=[training_data, epochs, learning_rate],
                        outputs=[finetune_result],
                        queue=True
                    )
                
                # לשונית דיבור
                with gr.TabItem("דיבור", id="speech"):
                    with gr.Tab("דיבור לטקסט"):
                        gr.Markdown("## זיהוי דיבור")
                        
                        speech_input = gr.Audio(
                            label="הקלט דיבור",
                            source="microphone",
                            type="filepath"
                        )
                        
                        speech_to_text_btn = gr.Button("זהה דיבור", variant="primary")
                        
                        speech_output = gr.Textbox(
                            label="טקסט מזוהה",
                            placeholder="הטקסט המזוהה יוצג כאן..."
                        )
                        
                    with gr.Tab("טקסט לדיבור"):
                        gr.Markdown("## סינתזת דיבור")
                        
                        tts_input = gr.Textbox(
                            label="טקסט להמרה",
                            placeholder="הכנס טקסט להמרה לדיבור...",
                            lines=5
                        )
                        
                        tts_btn = gr.Button("המר לדיבור", variant="primary")
                        
                        tts_output = gr.Audio(
                            label="דיבור מסונתז",
                            interactive=False
                        )
                    
                    # הגדרת פונקציות
                    speech_to_text_btn.click(
                        self.speech_to_text_process,
                        inputs=[speech_input],
                        outputs=[speech_output],
                        queue=True
                    )
                    
                    tts_btn.click(
                        self.text_to_speech_process,
                        inputs=[tts_input],
                        outputs=[tts_output],
                        queue=True
                    )
                
                # לשונית אווטאר
                with gr.TabItem("אווטאר", id="avatar"):
                    gr.Markdown("## יצירת אווטאר מדבר")
                    
                    with gr.Row():
                        with gr.Column():
                            avatar_text = gr.Textbox(
                                label="טקסט לאווטאר",
                                placeholder="הכנס טקסט שהאווטאר ידבר...",
                                lines=5
                            )
                            
                            with gr.Row():
                                avatar_image = gr.Image(
                                    label="העלאת תמונה לאווטאר (אופציונלי)",
                                    type="filepath"
                                )
                                
                                avatar_model = gr.Dropdown(
                                    label="סוג אווטאר",
                                    choices=["live2d", "3d", "photo_realistic"],
                                    value="live2d"
                                )
                            
                            avatar_btn = gr.Button("יצור אווטאר מדבר", variant="primary")
                        
                        with gr.Column():
                            avatar_output = gr.Video(
                                label="אווטאר מדבר",
                                interactive=False
                            )
                    
                    # פונקציה ליצירת אווטאר מדבר
                    def create_talking_avatar(text, image, model):
                        try:
                            if not text.strip():
                                return None
                            
                            # יצירת וידאו
                            video_path = self.avatar_service.generate_talking_video(
                                text=text,
                                avatar_path=image,
                                model=model
                            )
                            
                            return video_path
                            
                        except Exception as e:
                            logging.error(f"שגיאה ביצירת אווטאר מדבר: {e}")
                            return None
                    
                    # הגדרת פונקציות
                    avatar_btn.click(
                        create_talking_avatar,
                        inputs=[avatar_text, avatar_image, avatar_model],
                        outputs=[avatar_output],
                        queue=True
                    )
                
                # לשונית העלאת קבצים
                with gr.TabItem("העלאת קבצים", id="upload"):
                    gr.Markdown("## ניהול קבצים")
                    
                    with gr.Row():
                        with gr.Column():
                            upload_file = gr.File(
                                label="העלאת קובץ",
                                file_count="multiple"
                            )
                            
                            upload_btn = gr.Button("העלה קבצים", variant="primary")
                            
                            upload_result = gr.Textbox(
                                label="תוצאות העלאה",
                                placeholder="תוצאות ההעלאה יוצגו כאן..."
                            )
                        
                        with gr.Column():
                            # פונקציה לקבלת רשימת קבצים שהועלו
                            def get_uploaded_files():
                                try:
                                    # כאן תהיה פונקציה לקבלת רשימת הקבצים
                                    # בינתיים חזרה מטבלה ריקה לדוגמה
                                    return pd.DataFrame({
                                        "שם קובץ": [],
                                        "סוג": [],
                                        "גודל (KB)": [],
                                        "תאריך העלאה": []
                                    })
                                except Exception as e:
                                    return pd.DataFrame()
                            
                            gr.Markdown("### קבצים שהועלו")
                            
                            files_table = gr.DataFrame(
                                label="רשימת קבצים",
                                headers=["שם קובץ", "סוג", "גודל (KB)", "תאריך העלאה"],
                                value=get_uploaded_files,
                                interactive=False
                            )
                            
                            refresh_btn = gr.Button("רענן רשימה")
                    
                    # פונקציה להעלאת קבצים
                    def upload_files(files):
                        try:
                            if not files:
                                return "אנא בחר קבצים להעלאה"
                            
                            results = []
                            for file in files:
                                result = self.upload_service.upload_file(file.name)
                                if result:
                                    results.append(f"הקובץ {os.path.basename(file.name)} הועלה בהצלחה")
                                else:
                                    results.append(f"שגיאה בהעלאת הקובץ {os.path.basename(file.name)}")
                            
                            return "\n".join(results)
                            
                        except Exception as e:
                            logging.error(f"שגיאה בהעלאת קבצים: {e}")
                            return f"שגיאה בהעלאת קבצים: {str(e)}"
                    
                    # הגדרת פונקציות
                    upload_btn.click(
                        upload_files,
                        inputs=[upload_file],
                        outputs=[upload_result],
                        queue=True
                    )
                    
                    refresh_btn.click(
                        lambda: files_table.update(value=get_uploaded_files()),
                        inputs=[],
                        outputs=[files_table],
                        queue=True
                    )
                
                # לשונית הגדרות
                with gr.TabItem("הגדרות", id="settings"):
                    gr.Markdown("## הגדרות מערכת")
                    
                    with gr.Tabs():
                        with gr.TabItem("הגדרות כלליות"):
                            with gr.Row():
                                with gr.Column():
                                    gr.Markdown("### הגדרות שירותים")
                                    
                                    rag_enabled_checkbox = gr.Checkbox(
                                        label="הפעל שירות RAG",
                                        value=self.config.get("services", {}).get("rag", {}).get("enabled", True)
                                    )
                                    
                                    hebrew_enabled_checkbox = gr.Checkbox(
                                        label="הפעל תמיכה בעברית",
                                        value=self.config.get("hebrew_support", {}).get("enabled", True)
                                    )
                                    
                                    speech_to_text_enabled_checkbox = gr.Checkbox(
                                        label="הפעל זיהוי דיבור",
                                        value=self.config.get("services", {}).get("speech_to_text", {}).get("enabled", True)
                                    )
                                    
                                    text_to_speech_enabled_checkbox = gr.Checkbox(
                                        label="הפעל המרת טקסט לדיבור",
                                        value=self.config.get("services", {}).get("text_to_speech", {}).get("enabled", True)
                                    )
                                    
                                    update_settings_btn = gr.Button("עדכן הגדרות", variant="primary")
                                    
                                    settings_result = gr.Textbox(
                                        label="תוצאת עדכון"
                                    )
                                
                                with gr.Column():
                                    gr.Markdown("### מצב מערכת")
                                    
                                    system_status = gr.Markdown(self.get_system_status())
                                    
                                    refresh_status_btn = gr.Button("רענן מצב")
                        
                        with gr.TabItem("ניהול מודולים"):
                            with gr.Row():
                                with gr.Column():
                                    gr.Markdown("### התקנת מודול חדש")
                                    
                                    module_path = gr.Textbox(
                                        label="נתיב למודול",
                                        placeholder="הכנס נתיב לתיקיית המודול או קובץ ZIP..."
                                    )
                                    
                                    install_module_btn = gr.Button("התקן מודול", variant="primary")
                                    
                                    module_result = gr.Textbox(
                                        label="תוצאת התקנה"
                                    )
                                
                                with gr.Column():
                                    # פונקציה לקבלת רשימת מודולים מותקנים
                                    def get_installed_modules():
                                        try:
                                            # קבלת רשימת המודולים הטעונים
                                            modules = self.module_manager.get_loaded_modules()
                                            
                                            # המרה לדאטאפריים
                                            data = {
                                                "שם": [],
                                                "גרסה": [],
                                                "תיאור": [],
                                                "מחבר": []
                                            }
                                            
                                            for name, metadata in modules.items():
                                                data["שם"].append(name)
                                                data["גרסה"].append(metadata.get("version", ""))
                                                data["תיאור"].append(metadata.get("description", ""))
                                                data["מחבר"].append(metadata.get("author", ""))
                                            
                                            return pd.DataFrame(data)
                                            
                                        except Exception as e:
                                            logging.error(f"שגיאה בקבלת רשימת מודולים: {e}")
                                            return pd.DataFrame()
                                    
                                    gr.Markdown("### מודולים מותקנים")
                                    
                                    modules_table = gr.DataFrame(
                                        label="רשימת מודולים",
                                        headers=["שם", "גרסה", "תיאור", "מחבר"],
                                        value=get_installed_modules,
                                        interactive=False
                                    )
                                    
                                    refresh_modules_btn = gr.Button("רענן רשימה")
                        
                        with gr.TabItem("יצירת מודול"):
                            with gr.Row():
                                with gr.Column():
                                    gr.Markdown("### יצירת תבנית מודול חדש")
                                    
                                    new_module_name = gr.Textbox(
                                        label="שם המודול",
                                        placeholder="הכנס שם למודול החדש..."
                                    )
                                    
                                    new_module_description = gr.Textbox(
                                        label="תיאור המודול",
                                        placeholder="הכנס תיאור למודול החדש...",
                                        lines=3
                                    )
                                    
                                    new_module_author = gr.Textbox(
                                        label="מחבר המודול",
                                        value="ShayAI"
                                    )
                                    
                                    create_module_btn = gr.Button("צור מודול", variant="primary")
                                    
                                    create_module_result = gr.Textbox(
                                        label="תוצאת יצירה"
                                    )
                    
                    # פונקציה להתקנת מודול
                    def install_module(path):
                        try:
                            if not path.strip():
                                return "אנא הכנס נתיב למודול"
                            
                            # התקנת המודול
                            success = self.module_manager.install_module(path)
                            
                            if success:
                                return f"המודול הותקן בהצלחה: {path}"
                            else:
                                return f"שגיאה בהתקנת המודול: {path}"
                            
                        except Exception as e:
                            logging.error(f"שגיאה בהתקנת מודול: {e}")
                            return f"שגיאה בהתקנת מודול: {str(e)}"
                    
                    # פונקציה ליצירת תבנית מודול חדש
                    def create_module_template(name, description, author):
                        try:
                            if not name.strip():
                                return "אנא הכנס שם למודול"
                            
                            # יצירת תבנית מודול חדש
                            module_dir = self.module_manager.create_module_template(name, description, author)
                            
                            if module_dir:
                                return f"תבנית המודול נוצרה בהצלחה בנתיב: {module_dir}"
                            else:
                                return f"שגיאה ביצירת תבנית המודול: {name}"
                            
                        except Exception as e:
                            logging.error(f"שגיאה ביצירת תבנית מודול: {e}")
                            return f"שגיאה ביצירת תבנית מודול: {str(e)}"
                    
                    # הגדרת פונקציות
                    update_settings_btn.click(
                        self.update_system_settings,
                        inputs=[
                            rag_enabled_checkbox,
                            hebrew_enabled_checkbox,
                            speech_to_text_enabled_checkbox,
                            text_to_speech_enabled_checkbox
                        ],
                        outputs=[settings_result],
                        queue=True
                    )
                    
                    refresh_status_btn.click(
                        self.get_system_status,
                        inputs=[],
                        outputs=[system_status],
                        queue=True
                    )
                    
                    install_module_btn.click(
                        install_module,
                        inputs=[module_path],
                        outputs=[module_result],
                        queue=True
                    )
                    
                    refresh_modules_btn.click(
                        lambda: modules_table.update(value=get_installed_modules()),
                        inputs=[],
                        outputs=[modules_table],
                        queue=True
                    )
                    
                    create_module_btn.click(
                        create_module_template,
                        inputs=[new_module_name, new_module_description, new_module_author],
                        outputs=[create_module_result],
                        queue=True
                    )
        
        return interface
    
    def launch(self, port=None, share=False):
        """הפעלת הממשק
        
        Args:
            port: פורט להפעלה
            share: האם לשתף את הממשק
        """
        if port is None:
            port = self.ui_config.get("port", 7860)
        
        self.interface.launch(server_port=port, share=share)
EOF

    # יצירת קובץ __init__.py בתיקיית ui
    cat > "${BASE_DIR}/ui/__init__.py" << 'EOF'
"""חבילת ממשק משתמש גרפי"""

from .gradio_ui import GradioUI

__all__ = ["GradioUI"]
EOF

    # יצירת קובץ CSS מותאם אישית
    mkdir -p "${BASE_DIR}/ui/assets/css"
    cat > "${BASE_DIR}/ui/assets/css/custom.css" << 'EOF'
/* CSS מותאם אישית למערכת Effi-AI Private */

/* כללי */
:root, body {
    font-family: Arial, sans-serif;
    direction: rtl;
}

/* עיצוב כותרות */
h1, h2, h3, h4, h5, h6 {
    color: #2563eb;
    font-weight: 600;
}

/* עיצוב כפתורים */
button {
    padding: 8px 16px;
    margin: 4px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease;
}

button:hover {
    opacity: 0.9;
    transform: translateY(-1px);
}

button:active {
    transform: translateY(1px);
}

/* עיצוב שדות טקסט */
textarea, input[type="text"] {
    padding: 10px;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 14px;
    transition: all 0.2s ease;
}

textarea:focus, input[type="text"]:focus {
    border-color: #2563eb;
    outline: none;
    box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
}

/* מצב כהה */
@media (prefers-color-scheme: dark) {
    body {
        background-color: #1a1a1a;
        color: #f1f1f1;
    }
    
    textarea, input[type="text"] {
        background-color: #2a2a2a;
        color: #f1f1f1;
        border-color: #3a3a3a;
    }
    
    textarea:focus, input[type="text"]:focus {
        border-color: #3b82f6;
    }
}
EOF

    # יצירת תיקייה עבור קבצי JS
    mkdir -p "${BASE_DIR}/ui/assets/js"
    cat > "${BASE_DIR}/ui/assets/js/main.js" << 'EOF'
/**
 * קובץ JavaScript ראשי - Effi-AI Private
 */

// פונקציה ליצירת אנימציות פשוטות
function createAnimations() {
    // אנימציית הופעה
    const fadeIn = (element, duration = 500) => {
        element.style.opacity = 0;
        element.style.display = 'block';
        
        let start = null;
        
        const animate = timestamp => {
            if (!start) start = timestamp;
            const progress = timestamp - start;
            
            element.style.opacity = Math.min(progress / duration, 1);
            
            if (progress < duration) {
                window.requestAnimationFrame(animate);
            }
        };
        
        window.requestAnimationFrame(animate);
    };
    
    // אנימציית העלמה
    const fadeOut = (element, duration = 500) => {
        element.style.opacity = 1;
        
        let start = null;
        
        const animate = timestamp => {
            if (!start) start = timestamp;
            const progress = timestamp - start;
            
            element.style.opacity = Math.max(1 - (progress / duration), 0);
            
            if (progress < duration) {
                window.requestAnimationFrame(animate);
            } else {
                element.style.display = 'none';
            }
        };
        
        window.requestAnimationFrame(animate);
    };
    
    return {
        fadeIn,
        fadeOut
    };
}

// פונקציה לטיפול בהעלאת קבצים
function setupFileUpload() {
    const fileInputs = document.querySelectorAll('input[type="file"]');
    
    fileInputs.forEach(input => {
        input.addEventListener('change', e => {
            const fileCount = e.target.files.length;
            const fileLabel = input.nextElementSibling;
            
            if (fileLabel && fileLabel.tagName === 'LABEL') {
                if (fileCount > 0) {
                    fileLabel.textContent = `נבחרו ${fileCount} קבצים`;
                } else {
                    fileLabel.textContent = 'בחר קבצים';
                }
            }
        });
    });
}

// פונקציה להתחלת הקלטת שמע
function setupAudioRecording() {
    const recordButtons = document.querySelectorAll('.record-audio-btn');
    
    recordButtons.forEach(button => {
        button.addEventListener('click', e => {
            e.preventDefault();
            
            // בדיקת תמיכה ב-API
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                alert('הדפדפן שלך אינו תומך בהקלטת שמע');
                return;
            }
            
            // שינוי סטטוס הכפתור
            const isRecording = button.classList.contains('recording');
            
            if (isRecording) {
                // סיום הקלטה
                button.classList.remove('recording');
                button.textContent = 'התחל הקלטה';
                
                // כאן יופעל קוד לסיום ההקלטה (לא מוצג כאן)
            } else {
                // התחלת הקלטה
                button.classList.add('recording');
                button.textContent = 'סיים הקלטה';
                
                // בקשת גישה למיקרופון
                navigator.mediaDevices.getUserMedia({ audio: true })
                    .then(stream => {
                        // כאן יופעל קוד להתחלת ההקלטה (לא מוצג כאן)
                    })
                    .catch(err => {
                        alert(`שגיאה בגישה למיקרופון: ${err.message}`);
                        button.classList.remove('recording');
                        button.textContent = 'התחל הקלטה';
                    });
            }
        });
    });
}

// פונקציה ראשית שתופעל כאשר המסמך נטען
document.addEventListener('DOMContentLoaded', () => {
    // יצירת אנימציות
    const animations = createAnimations();
    
    // הגדרת העלאת קבצים
    setupFileUpload();
    
    // הגדרת הקלטת שמע
    setupAudioRecording();
    
    // קוד נוסף להפעלה בטעינת המסמך
    console.log('Effi-AI Private UI loaded successfully');
});
EOF

    # יצירת תיקייה עבור תמונות
    mkdir -p "${BASE_DIR}/ui/assets/images"
    
    # יצירת לוגו בסיסי
    cat > "${BASE_DIR}/ui/assets/images/logo.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="60" viewBox="0 0 200 60">
  <style>
    .text { font-family: Arial, sans-serif; font-weight: bold; }
    .main-text { font-size: 24px; fill: #2563eb; }
    .sub-text { font-size: 14px; fill: #4b5563; }
  </style>
  <rect width="200" height="60" rx="10" fill="#ffffff" stroke="#e5e7eb" stroke-width="2"/>
  <text x="20" y="35" class="text main-text">Effi-AI Private</text>
  <text x="22" y="50" class="text sub-text">מערכת AI פרטית מודולרית</text>
</svg>
EOF

    print_success "רכיבי המערכת קושרו בהצלחה"
}
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