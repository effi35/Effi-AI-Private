#!/bin/bash
# ========================================================================
# Effi-AI Private - סקריפט התקנה מקיף
# גרסה: 1.0.0
# ========================================================================

# הגדרת קידוד UTF-8 לסקריפט
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

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
curl -fsSL https://raw.githubusercontent.com/effi35/Effi-AI-Private/main/install.sh -o install.sh

# הפיכת הסקריפט להרצה
chmod +x install.sh

# הרצת הסקריפט
./install.sh
```

### התקנה ידנית
```bash
# שיבוט המאגר
git clone https://github.com/effi35/Effi-AI-Private.git

# כניסה לתיקייה
cd Effi-AI-Private

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
```

## שימוש יומיומי

### ממשק גרפי
הממשק הגרפי מציע את האפשרויות הבאות:

- **צ'אט** - שיחה עם המודל
- **מאגר ידע** - הוספת מידע חדש למערכת
- **כיוון מודל** - ביצוע fine-tuning למודל
- **הגדרות** - שינוי הגדרות המערכת
- **העלאה** - העלאת קבצים, תמונות וקטעי אודיו
- **דיבור** - זיהוי דיבור והמרתו לטקסט
- **אווטאר** - יצירת ועריכת אווטארים מדברים

### שורת פקודה
ממשק שורת הפקודה תומך בפקודות הבאות:

- `python app.py --chat` - מצב צ'אט אינטראקטיבי
- `python app.py --query "שאלה"` - שאלה בודדת
- `python app.py --voice` - הפעלת מצב זיהוי דיבור
- `python app.py --add-text "טקסט"` - הוספת טקסט למאגר הידע
- `python app.py --add-file "נתיב קובץ"` - הוספת קובץ למאגר הידע

## ניהול מודולים

המערכת תומכת בהוספת מודולים חדשים באופן פשוט:

1. צור תיקייה חדשה תחת `modules/[שם_המודול]`
2. הוסף קובץ `metadata.json` עם פרטי המודול
3. הוסף את קובץ המודול העיקרי
4. המערכת תזהה את המודול באופן אוטומטי ותשלב אותו בממשק

## ניהול גרסאות

```bash
# יצירת גיבוי
python manage.py backup

# שחזור גיבוי
python manage.py restore backup_20250510_123456.zip

# עדכון המערכת
python manage.py update
```

## פיתוח נוסף

המערכת בנויה להיות מודולרית ונוחה להרחבה. ניתן להוסיף מודולים חדשים, להחליף את המודל הבסיסי ולהתאים את המערכת לצרכים ספציפיים.

## רישוי
- המערכת עצמה מופצת תחת רישיון MIT.
- המודל Lexi Uncensored מבוסס על Llama 3.1 וכפוף לרישיון Llama 3.1 Community License של Meta.
EOF

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
"""
מנהל המודלים - מתאם להחלפת מודלים ושימוש בהם
"""
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
"""
מתאם למודלים מסוג Ollama
"""
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
"""
מתאם דמה למקרה של שגיאה בטעינת מודל
"""
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
"""
שירות אחזור מידע מוגבר (Retrieval Augmented Generation)
"""
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
"""
שירות תמיכה בעברית
"""
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
        """המרת קובץ אודיו לטקסט באמצעות Google Speech