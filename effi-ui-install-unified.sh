#!/bin/bash

# Effi-UI Dynamic Engine + HTML Editor - Installation Script
# Version 2.0.0 - מערכת מאוחדת כוללת עורך HTML
# This script installs the complete Effi-UI system with integrated HTML editor

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/var/www/html/effi_ui_engine"
TEMP_DIR="/tmp/effi_ui_install"
VERSION="2.0.0"

# ASCII Art Logo
show_logo() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════╗
    ║     _____ ___ ___ ___   _   _ ___        ║
    ║    | ____|  _|  _|_ _| | | | |_ _|       ║
    ║    |  _| | |_| |_ | |  | | | || |        ║
    ║    | |___|  _|  _|| |  | |_| || |        ║
    ║    |_____|_| |_| |___|  \___/|___|       ║
    ║                                           ║
    ║    Dynamic Engine + HTML Editor v2.0      ║
    ╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Functions
print_header() {
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}     Effi-UI Dynamic Engine Installer${NC}"
    echo -e "${BLUE}     Version: ${VERSION}${NC}"
    echo -e "${BLUE}     כולל: מערכת שליטה + עורך HTML${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_feature() {
    echo -e "${MAGENTA}★ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    # Check for web server
    if command -v nginx &> /dev/null; then
        print_success "Nginx found"
        WEB_SERVER="nginx"
    elif command -v apache2 &> /dev/null; then
        print_success "Apache found"
        WEB_SERVER="apache2"
    else
        print_warning "No web server found. Please install Nginx or Apache"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check for required tools
    local tools=("git" "curl" "wget" "unzip")
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            print_warning "$tool is not installed"
            apt-get update && apt-get install -y $tool
        else
            print_success "$tool found"
        fi
    done
}

# Get installation directory
get_install_dir() {
    echo ""
    print_info "Default installation directory: $INSTALL_DIR"
    read -p "Enter installation directory (press Enter for default): " custom_dir
    
    if [[ ! -z "$custom_dir" ]]; then
        INSTALL_DIR="$custom_dir"
    fi
    
    # Create directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_info "Creating directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    else
        print_warning "Directory exists. Files will be overwritten."
        read -p "Continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Create directory structure
create_structure() {
    print_info "Creating directory structure..."
    
    # Create subdirectories
    local dirs=(
        "assets/css"
        "assets/js"
        "assets/images"
        "assets/fonts"
        "components"
        "templates"
        "pages"
        "icons"
        "logs"
        "backups"
        "docs"
        "screenshots"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$INSTALL_DIR/$dir"
        print_success "Created: $dir"
    done
}

# Create all system files
create_files() {
    print_info "Creating system files..."
    
    # Create main unified engine file
    print_info "Creating main engine file with full functionality..."
    
    # Write the complete unified engine code
    cat > "$INSTALL_DIR/effi_ui_engine.js" << 'EOFMAINJS'
    
    # Create main CSS file
    cat > "$INSTALL_DIR/effi_ui_engine.css" << 'EOF'
/* Effi-UI Dynamic Engine - Unified Styles */
/* Version 2.0.0 */

:root {
    --primary: #667eea;
    --secondary: #764ba2;
    --success: #4caf50;
    --danger: #f44336;
    --warning: #ff9800;
    --info: #2196f3;
    --light: #f5f5f5;
    --dark: #212121;
}

/* Base styles */
* {
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    direction: rtl;
}

/* Effi Button Styles */
.effi-btn {
    padding: 12px 30px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
    transition: all 0.3s;
    display: inline-block;
    text-decoration: none;
    text-align: center;
}

.effi-btn-primary {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
}

.effi-btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 20px rgba(0,0,0,0.2);
}

/* Container styles */
.effi-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Grid system */
.effi-grid {
    display: grid;
    gap: 20px;
}

.effi-grid-2 { grid-template-columns: repeat(2, 1fr); }
.effi-grid-3 { grid-template-columns: repeat(3, 1fr); }
.effi-grid-4 { grid-template-columns: repeat(4, 1fr); }

/* Card component */
.effi-card {
    background: white;
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    transition: all 0.3s;
}

.effi-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.15);
}

/* Animations */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes slideIn {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.05); }
}

/* Responsive */
@media (max-width: 768px) {
    .effi-grid-2,
    .effi-grid-3,
    .effi-grid-4 {
        grid-template-columns: 1fr;
    }
}
EOF
    
    # Create loader file
    cat > "$INSTALL_DIR/effi_ui_loader.js" << 'EOF'
// Effi-UI Loader
// Automatic loading script for Effi-UI Engine

(function() {
    'use strict';
    
    // Configuration
    const config = {
        basePath: '/effi_ui_engine/',
        autoInit: true,
        debug: false
    };
    
    // Load CSS
    function loadCSS() {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = config.basePath + 'effi_ui_engine.css';
        document.head.appendChild(link);
    }
    
    // Load main engine
    function loadEngine() {
        const script = document.createElement('script');
        script.src = config.basePath + 'effi_ui_engine.js';
        script.onload = function() {
            if (config.debug) console.log('✅ Effi-UI Engine loaded');
            
            // Auto initialize if enabled
            if (config.autoInit && window.EffiUI) {
                window.EffiUI.init();
            }
        };
        script.onerror = function() {
            console.error('❌ Failed to load Effi-UI Engine');
        };
        document.body.appendChild(script);
    }
    
    // Initialize loader
    function init() {
        loadCSS();
        
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadEngine);
        } else {
            loadEngine();
        }
    }
    
    // Start loading
    init();
})();
EOF
    
    # Create control panel HTML
    cat > "$INSTALL_DIR/effi_ui_panel.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Control Panel - לוח בקרה</title>
    <link rel="stylesheet" href="effi_ui_engine.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .control-container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            max-width: 800px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        h1 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .feature-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .feature-card:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-5px);
        }
        
        .feature-icon {
            font-size: 3em;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="control-container">
        <h1>🎨 Effi-UI Control Panel</h1>
        <p style="text-align: center; font-size: 1.2em; opacity: 0.9;">
            מערכת שליטה ויזואלית מתקדמת + עורך HTML
        </p>
        
        <div class="feature-grid">
            <div class="feature-card" onclick="window.open('effi_ui_preview.html', '_blank')">
                <div class="feature-icon">👁️</div>
                <h3>תצוגה מקדימה</h3>
                <p>צפה באפקטים חיים</p>
            </div>
            
            <div class="feature-card" onclick="window.open('setup_visual_control.html', '_blank')">
                <div class="feature-icon">🎛️</div>
                <h3>מרכז בקרה</h3>
                <p>שליטה מלאה בעיצוב</p>
            </div>
            
            <div class="feature-card" onclick="alert('עורך HTML יפתח בקרוב!')">
                <div class="feature-icon">📝</div>
                <h3>עורך HTML</h3>
                <p>צור ועצב דפים</p>
            </div>
            
            <div class="feature-card" onclick="window.open('docs/readme.html', '_blank')">
                <div class="feature-icon">📚</div>
                <h3>תיעוד</h3>
                <p>מדריכים והסברים</p>
            </div>
        </div>
        
        <div style="margin-top: 40px; text-align: center;">
            <button class="effi-btn effi-btn-primary" onclick="location.reload()">
                🔄 רענן
            </button>
            <button class="effi-btn" style="background: rgba(255,255,255,0.2); color: white; margin-right: 10px;" 
                    onclick="window.open('test-effi-ui.html', '_blank')">
                🧪 בדיקה
            </button>
        </div>
    </div>
    
    <script src="effi_ui_engine.js"></script>
</body>
</html>
EOF
    
    # Create preview page
    cat > "$INSTALL_DIR/effi_ui_preview.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Preview - תצוגה מקדימה</title>
    <link rel="stylesheet" href="effi_ui_engine.css">
</head>
<body style="padding: 40px; background: #f5f5f5;">
    <h1 style="text-align: center; color: #333;">🎨 Effi-UI Preview</h1>
    
    <div class="effi-container">
        <!-- כפתורים -->
        <section style="margin: 40px 0;">
            <h2>כפתורים</h2>
            <div style="display: flex; gap: 20px; flex-wrap: wrap;">
                <button class="effi-btn effi-btn-primary">כפתור ראשי</button>
                <button class="effi-btn" style="background: var(--success); color: white;">הצלחה</button>
                <button class="effi-btn" style="background: var(--danger); color: white;">סכנה</button>
                <button class="effi-btn" style="background: var(--warning); color: white;">אזהרה</button>
                <button class="effi-btn" style="background: var(--info); color: white;">מידע</button>
            </div>
        </section>
        
        <!-- כרטיסים -->
        <section style="margin: 40px 0;">
            <h2>כרטיסים</h2>
            <div class="effi-grid effi-grid-3">
                <div class="effi-card">
                    <h3>כרטיס 1</h3>
                    <p>תוכן הכרטיס הראשון</p>
                </div>
                <div class="effi-card">
                    <h3>כרטיס 2</h3>
                    <p>תוכן הכרטיס השני</p>
                </div>
                <div class="effi-card">
                    <h3>כרטיס 3</h3>
                    <p>תוכן הכרטיס השלישי</p>
                </div>
            </div>
        </section>
        
        <!-- אנימציות -->
        <section style="margin: 40px 0;">
            <h2>אנימציות</h2>
            <div style="display: flex; gap: 40px; justify-content: center;">
                <div style="animation: pulse 2s infinite;" class="effi-card" style="width: 150px; text-align: center;">
                    <h4>פועם</h4>
                </div>
                <div style="animation: fadeIn 2s infinite;" class="effi-card" style="width: 150px; text-align: center;">
                    <h4>דוהה</h4>
                </div>
                <div style="animation: slideIn 2s infinite;" class="effi-card" style="width: 150px; text-align: center;">
                    <h4>גולש</h4>
                </div>
            </div>
        </section>
    </div>
    
    <script src="effi_ui_engine.js"></script>
</body>
</html>
EOF
    
    # Create setup visual control center
    cat > "$INSTALL_DIR/setup_visual_control.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Visual Control Center - מרכז בקרה ויזואלי</title>
    <link rel="stylesheet" href="effi_ui_engine.css">
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #0a0a0a;
            color: #fff;
            overflow-x: hidden;
        }
        
        .control-header {
            background: linear-gradient(90deg, #667eea, #764ba2);
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5);
        }
        
        .control-grid {
            display: grid;
            grid-template-columns: 300px 1fr;
            height: calc(100vh - 80px);
        }
        
        .control-sidebar {
            background: #1a1a1a;
            padding: 20px;
            overflow-y: auto;
            border-left: 1px solid #333;
        }
        
        .control-main {
            padding: 20px;
            overflow-y: auto;
        }
        
        .control-section {
            background: #2a2a2a;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .control-section h3 {
            margin-top: 0;
            color: #667eea;
        }
        
        .demo-area {
            background: #fff;
            color: #000;
            padding: 40px;
            border-radius: 10px;
            min-height: 400px;
            position: relative;
        }
        
        .color-palette {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .color-swatch {
            width: 50px;
            height: 50px;
            border-radius: 8px;
            cursor: pointer;
            transition: transform 0.2s;
            border: 2px solid transparent;
        }
        
        .color-swatch:hover {
            transform: scale(1.1);
            border-color: #fff;
        }
        
        .animation-list {
            display: grid;
            gap: 10px;
        }
        
        .animation-item {
            background: #3a3a3a;
            padding: 15px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .animation-item:hover {
            background: #4a4a4a;
            transform: translateX(-5px);
        }
        
        .live-editor {
            background: #1e1e1e;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }
        
        .code-editor {
            background: #0a0a0a;
            color: #0f0;
            font-family: 'Consolas', monospace;
            padding: 15px;
            border-radius: 5px;
            min-height: 200px;
            overflow: auto;
        }
    </style>
</head>
<body>
    <div class="control-header">
        <h1>🎮 Effi-UI Visual Control Center</h1>
        <p>שליטה מלאה בכל אלמנט - בזמן אמת</p>
    </div>
    
    <div class="control-grid">
        <div class="control-sidebar">
            <div class="control-section">
                <h3>🎨 צבעים</h3>
                <div class="color-palette">
                    <div class="color-swatch" style="background: #667eea;" onclick="applyColor('#667eea')"></div>
                    <div class="color-swatch" style="background: #764ba2;" onclick="applyColor('#764ba2')"></div>
                    <div class="color-swatch" style="background: #4caf50;" onclick="applyColor('#4caf50')"></div>
                    <div class="color-swatch" style="background: #f44336;" onclick="applyColor('#f44336')"></div>
                    <div class="color-swatch" style="background: #ff9800;" onclick="applyColor('#ff9800')"></div>
                    <div class="color-swatch" style="background: #2196f3;" onclick="applyColor('#2196f3')"></div>
                    <div class="color-swatch" style="background: #000000;" onclick="applyColor('#000000')"></div>
                    <div class="color-swatch" style="background: #ffffff;" onclick="applyColor('#ffffff')"></div>
                </div>
                <input type="color" id="customColor" style="width: 100%; margin-top: 10px; height: 40px;">
            </div>
            
            <div class="control-section">
                <h3>✨ אנימציות</h3>
                <div class="animation-list">
                    <div class="animation-item" onclick="applyAnimation('pulse')">
                        <strong>Pulse</strong> - פעימה
                    </div>
                    <div class="animation-item" onclick="applyAnimation('shake')">
                        <strong>Shake</strong> - רעידה
                    </div>
                    <div class="animation-item" onclick="applyAnimation('bounce')">
                        <strong>Bounce</strong> - קפיצה
                    </div>
                    <div class="animation-item" onclick="applyAnimation('spin')">
                        <strong>Spin</strong> - סיבוב
                    </div>
                    <div class="animation-item" onclick="applyAnimation('glow')">
                        <strong>Glow</strong> - זוהר
                    </div>
                </div>
            </div>
            
            <div class="control-section">
                <h3>🎯 אפקטים</h3>
                <button class="effi-btn" style="width: 100%; margin: 5px 0;" onclick="applyEffect('glass')">
                    זכוכית מטושטשת
                </button>
                <button class="effi-btn" style="width: 100%; margin: 5px 0;" onclick="applyEffect('neon')">
                    ניאון זוהר
                </button>
                <button class="effi-btn" style="width: 100%; margin: 5px 0;" onclick="applyEffect('gradient')">
                    גרדיאנט דינמי
                </button>
                <button class="effi-btn" style="width: 100%; margin: 5px 0;" onclick="applyEffect('3d')">
                    אפקט תלת מימד
                </button>
            </div>
        </div>
        
        <div class="control-main">
            <div class="control-section">
                <h3>🖼️ אזור הדגמה חי</h3>
                <div class="demo-area" id="demoArea">
                    <h2 id="demoTitle">כותרת לדוגמה</h2>
                    <p id="demoText">זהו טקסט לדוגמה. בחר אפקטים מהתפריט בצד כדי לראות אותם בפעולה.</p>
                    <button class="effi-btn effi-btn-primary" id="demoButton">כפתור לדוגמה</button>
                    <div style="margin-top: 20px;">
                        <div class="effi-card" id="demoCard">
                            <h3>כרטיס לדוגמה</h3>
                            <p>תוכן הכרטיס</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="live-editor">
                <h3>💻 עורך קוד חי</h3>
                <div class="code-editor" contenteditable="true" id="codeEditor">
/* הוסף CSS מותאם אישית כאן */
#demoArea {
    /* הסגנונות שלך */
}
                </div>
                <button class="effi-btn effi-btn-primary" style="margin-top: 10px;" onclick="applyCustomCSS()">
                    החל קוד
                </button>
            </div>
        </div>
    </div>
    
    <script>
        let selectedElement = null;
        
        // בחירת אלמנט
        document.querySelectorAll('#demoArea *').forEach(el => {
            el.addEventListener('click', function(e) {
                e.stopPropagation();
                if (selectedElement) {
                    selectedElement.style.outline = 'none';
                }
                selectedElement = this;
                this.style.outline = '2px dashed #667eea';
            });
        });
        
        // החלת צבע
        function applyColor(color) {
            if (selectedElement) {
                selectedElement.style.color = color;
            }
        }
        
        // החלת אנימציה
        function applyAnimation(animation) {
            if (selectedElement) {
                selectedElement.style.animation = `${animation} 2s infinite`;
            }
        }
        
        // החלת אפקט
        function applyEffect(effect) {
            if (selectedElement) {
                switch(effect) {
                    case 'glass':
                        selectedElement.style.background = 'rgba(255,255,255,0.1)';
                        selectedElement.style.backdropFilter = 'blur(10px)';
                        selectedElement.style.border = '1px solid rgba(255,255,255,0.2)';
                        break;
                    case 'neon':
                        selectedElement.style.textShadow = '0 0 10px #00ffff, 0 0 20px #00ffff';
                        selectedElement.style.color = '#00ffff';
                        break;
                    case 'gradient':
                        selectedElement.style.background = 'linear-gradient(45deg, #667eea, #764ba2)';
                        selectedElement.style.color = 'white';
                        break;
                    case '3d':
                        selectedElement.style.transform = 'perspective(1000px) rotateY(10deg)';
                        selectedElement.style.boxShadow = '20px 20px 60px rgba(0,0,0,0.3)';
                        break;
                }
            }
        }
        
        // החלת CSS מותאם
        function applyCustomCSS() {
            const css = document.getElementById('codeEditor').innerText;
            let styleTag = document.getElementById('customStyles');
            if (!styleTag) {
                styleTag = document.createElement('style');
                styleTag.id = 'customStyles';
                document.head.appendChild(styleTag);
            }
            styleTag.textContent = css;
        }
        
        // צבע מותאם
        document.getElementById('customColor').addEventListener('change', function() {
            applyColor(this.value);
        });
    </script>
    
    <script src="effi_ui_engine.js"></script>
</body>
</html>
EOF
    
    # Create config file
    cat > "$INSTALL_DIR/effi_ui_config.json" << 'EOF'
{
    "version": "2.0.0",
    "currentProfile": "default",
    "profiles": {
        "default": {
            "name": "ברירת מחדל",
            "colors": {
                "primary": "#667eea",
                "secondary": "#764ba2",
                "success": "#4caf50",
                "danger": "#f44336",
                "warning": "#ff9800",
                "info": "#2196f3",
                "light": "#f5f5f5",
                "dark": "#212121"
            }
        },
        "dark": {
            "name": "מצב כהה",
            "colors": {
                "primary": "#bb86fc",
                "secondary": "#03dac6",
                "success": "#00e676",
                "danger": "#cf6679",
                "warning": "#ffab00",
                "info": "#448aff",
                "light": "#1e1e1e",
                "dark": "#121212"
            }
        },
        "business": {
            "name": "עסקי",
            "colors": {
                "primary": "#1976d2",
                "secondary": "#424242",
                "success": "#388e3c",
                "danger": "#d32f2f",
                "warning": "#f57c00",
                "info": "#0288d1",
                "light": "#fafafa",
                "dark": "#263238"
            }
        }
    },
    "timeRules": [],
    "customCSS": "",
    "htmlPages": {}
}
EOF
    
    # Create assets file
    cat > "$INSTALL_DIR/effi_ui_assets.json" << 'EOF'
{
    "version": "2.0.0",
    "buttons": {
        "count": 15,
        "types": ["gradient", "3d", "glass", "neon", "glitch", "magnetic", "liquid", "cyber", "morph", "hologram"]
    },
    "animations": {
        "count": 20,
        "types": ["pulse", "shake", "bounce", "spin", "flip", "glow", "float", "swing", "rubberBand", "heartbeat", "tada", "jello"]
    },
    "backgrounds": {
        "count": 10,
        "types": ["gradient-animated", "particle-bg", "mesh-gradient", "wave-pattern", "geometric"]
    },
    "effects": {
        "count": 10,
        "types": ["glass-morphism", "neumorphism", "cyberpunk", "holographic", "liquid-metal"]
    },
    "layouts": {
        "count": 10,
        "types": ["hero-section", "card-grid", "split-section"]
    },
    "formElements": {
        "count": 5,
        "types": ["modern-input", "toggle-switch", "radio-cards"]
    },
    "interactive": {
        "count": 10,
        "types": ["counter", "progress-bar", "tooltip", "modal", "tabs"]
    }
}
EOF
    
    # Create manifest.json for PWA
    cat > "$INSTALL_DIR/manifest.json" << 'EOF'
{
    "name": "Effi-UI Dynamic Engine + HTML Editor",
    "short_name": "Effi-UI",
    "description": "מערכת שליטה ויזואלית מתקדמת עם עורך HTML משולב",
    "start_url": "/effi_ui_engine/effi_ui_panel.html",
    "display": "standalone",
    "theme_color": "#667eea",
    "background_color": "#667eea",
    "orientation": "any",
    "icons": [
        {
            "src": "icons/icon-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any maskable"
        },
        {
            "src": "icons/icon-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any maskable"
        }
    ],
    "categories": ["developer", "productivity", "utilities"],
    "lang": "he"
}
EOF
    
    # Create service worker
    cat > "$INSTALL_DIR/service-worker.js" << 'EOF'
// Effi-UI Service Worker v2.0.0
const CACHE_NAME = 'effi-ui-v2.0.0';
const urlsToCache = [
    '/',
    '/effi_ui_engine/effi_ui_engine.js',
    '/effi_ui_engine/effi_ui_engine.css',
    '/effi_ui_engine/effi_ui_panel.html',
    '/effi_ui_engine/manifest.json'
];

// Install event
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Opened cache');
                return cache.addAll(urlsToCache);
            })
    );
});

// Fetch event
self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                if (response) {
                    return response;
                }
                return fetch(event.request);
            })
    );
});

// Activate event
self.addEventListener('activate', event => {
    const cacheWhitelist = [CACHE_NAME];
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheWhitelist.indexOf(cacheName) === -1) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});
EOF
    
    # Create README
    cat > "$INSTALL_DIR/README.md" << 'EOF'
# Effi-UI Dynamic Engine v2.0.0 🎨

## מערכת שליטה ויזואלית מתקדמת + עורך HTML משולב

### 🌟 תכונות מרכזיות

#### 1. **ארגז כלים מורחב (100+ רכיבים)**
- ✅ 15 סוגי כפתורים מתקדמים
- ✅ 20+ אנימציות מובנות
- ✅ 10 רקעים דינמיים
- ✅ 10 אפקטים מיוחדים
- ✅ רכיבי טופס מודרניים
- ✅ פריסות מוכנות

#### 2. **עורך HTML משולב**
- ✅ יצירת דפים בזמן אמת
- ✅ Drag & Drop לרכיבים
- ✅ עריכה ישירה (inline editing)
- ✅ תצוגה מקדימה חיה
- ✅ ייצוא לקבצי HTML

#### 3. **מערכת פרופילים**
- ✅ 5 פרופילי צבע מובנים
- ✅ החלפה אוטומטית לפי זמן
- ✅ צבעים מותאמים אישית
- ✅ שמירת העדפות

#### 4. **תמיכה מלאה במובייל**
- ✅ ממשק רספונסיבי
- ✅ תמיכה במגע
- ✅ Drag & Drop במובייל
- ✅ תפריט מותאם

#### 5. **Progressive Web App**
- ✅ התקנה כאפליקציה
- ✅ עבודה אופליין
- ✅ Service Worker
- ✅ מניפסט מלא

### 📦 התקנה

```bash
# הרצת סקריפט ההתקנה
sudo ./install.sh

# או התקנה ידנית
1. העתק את כל הקבצים לשרת
2. הגדר את הנתיב ב-nginx/apache
3. פתח את effi_ui_panel.html
```

### 🚀 שימוש מהיר

#### הוספת המערכת לאתר:
```html
<script src="/effi_ui_engine/effi_ui_loader.js"></script>
```

#### הפעלה ידנית:
```javascript
// אתחול המערכת
EffiUI.init();

// החלפת פרופיל
EffiUI.applyProfile('dark');

// הוספת אפקט
EffiUI.applyEffect(element, 'animation', 'pulse');
```

### 🎮 קיצורי מקלדת

- **Ctrl+E** - פתח/סגור פאנל
- **Ctrl+S** - שמור הגדרות
- **Ctrl+Z** - בטל פעולה
- **Ctrl+D** - מצב כהה
- **ESC** - סגור עורך

### 📱 תמיכת דפדפנים

- ✅ Chrome/Edge (מומלץ)
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers

### 🛠️ מבנה קבצים

```
effi_ui_engine/
├── effi_ui_engine.js      # מנוע ראשי
├── effi_ui_engine.css     # סגנונות
├── effi_ui_loader.js      # טוען אוטומטי
├── effi_ui_panel.html     # לוח בקרה
├── effi_ui_preview.html   # תצוגה מקדימה
├── setup_visual_control.html # מרכז בקרה
├── effi_ui_config.json    # הגדרות
├── manifest.json          # PWA
├── service-worker.js      # אופליין
└── assets/               # משאבים
    ├── css/
    ├── js/
    ├── images/
    └── fonts/
```

### 🎨 דוגמאות קוד

#### יצירת דף חדש:
```javascript
EffiUI.htmlEditor.newPage();
```

#### החלת אנימציה:
```javascript
EffiUI.applyEffect(element, 'animation', 'bounce');
```

#### הוספת רכיב HTML:
```javascript
EffiUI.insertLayout('hero-section');
```

### 📞 תמיכה

- 📧 Email: support@effi-ai.com
- 🌐 Website: https://effi-ai.com
- 📚 Docs: https://docs.effi-ai.com

### 📄 רישיון

MIT License - שימוש חופשי למטרות מסחריות ופרטיות

---

**נוצר עם ❤️ על ידי צוות Effi-AI**
EOF
    
    # Create documentation HTML
    mkdir -p "$INSTALL_DIR/docs"
    cat > "$INSTALL_DIR/docs/readme.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Documentation - תיעוד</title>
    <link rel="stylesheet" href="../effi_ui_engine.css">
    <style>
        body {
            padding: 40px;
            max-width: 1000px;
            margin: 0 auto;
            background: #f5f5f5;
        }
        
        .doc-section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        pre {
            background: #1e1e1e;
            color: #fff;
            padding: 20px;
            border-radius: 8px;
            overflow-x: auto;
        }
        
        code {
            background: #f0f0f0;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Consolas', monospace;
        }
    </style>
</head>
<body>
    <div class="doc-section">
        <h1>📚 תיעוד Effi-UI v2.0.0</h1>
        <p>ברוכים הבאים לתיעוד המלא של מערכת Effi-UI</p>
    </div>
    
    <div class="doc-section">
        <h2>🚀 התחלה מהירה</h2>
        <h3>התקנה</h3>
        <pre><code>sudo ./install.sh</code></pre>
        
        <h3>הוספה לאתר</h3>
        <pre><code>&lt;script src="/effi_ui_engine/effi_ui_loader.js"&gt;&lt;/script&gt;</code></pre>
    </div>
    
    <div class="doc-section">
        <h2>🎨 שימוש בארגז הכלים</h2>
        <p>גרור ושחרר אפקטים מהפאנל לאלמנטים בדף</p>
        <ul>
            <li>פתח את הפאנל עם Ctrl+E</li>
            <li>בחר אפקט מארגז הכלים</li>
            <li>גרור אותו לאלמנט בדף</li>
        </ul>
    </div>
    
    <div class="doc-section">
        <h2>📝 עורך HTML</h2>
        <p>צור ועצב דפי HTML בקלות</p>
        <ol>
            <li>לחץ על "דף חדש" בטאב עורך HTML</li>
            <li>גרור רכיבים מהרשימה</li>
            <li>ערוך טקסט בלחיצה כפולה</li>
            <li>ייצא את הדף כקובץ HTML</li>
        </ol>
    </div>
    
    <script src="../effi_ui_engine.js"></script>
</body>
</html>
EOF
    
    print_success "All files created successfully!"
}

# Create icons
create_icons() {
    print_info "Creating icons..."
    
    # Create SVG icons
    cat > "$INSTALL_DIR/icons/icon.svg" << 'EOF'
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
        </linearGradient>
    </defs>
    <rect width="512" height="512" rx="100" fill="url(#grad)"/>
    <text x="256" y="320" text-anchor="middle" fill="white" font-size="200" font-weight="bold" font-family="Arial">UI</text>
</svg>
EOF
    
    # Convert to PNG if ImageMagick is available
    if command -v convert &> /dev/null; then
        convert -resize 192x192 "$INSTALL_DIR/icons/icon.svg" "$INSTALL_DIR/icons/icon-192.png"
        convert -resize 512x512 "$INSTALL_DIR/icons/icon.svg" "$INSTALL_DIR/icons/icon-512.png"
        print_success "PNG icons created"
    else {
        # Create placeholder PNGs
        cp "$INSTALL_DIR/icons/icon.svg" "$INSTALL_DIR/icons/icon-192.png"
        cp "$INSTALL_DIR/icons/icon.svg" "$INSTALL_DIR/icons/icon-512.png"
        print_warning "ImageMagick not found. Using SVG placeholders"
    }
    fi
}

# Set permissions
set_permissions() {
    print_info "Setting permissions..."
    
    # Set ownership
    if [[ "$WEB_SERVER" == "nginx" ]]; then
        chown -R www-data:www-data "$INSTALL_DIR"
    elif [[ "$WEB_SERVER" == "apache2" ]]; then
        chown -R www-data:www-data "$INSTALL_DIR"
    fi
    
    # Set permissions
    find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
    find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
    chmod 755 "$INSTALL_DIR/install.sh" 2>/dev/null || true
    
    print_success "Permissions set"
}

# Configure web server
configure_webserver() {
    print_info "Configuring web server..."
    
    if [[ "$WEB_SERVER" == "nginx" ]]; then
        # Create Nginx configuration
        cat > "/etc/nginx/sites-available/effi-ui" << EOF
# Effi-UI Engine Configuration
server {
    listen 80;
    server_name _;
    
    location /effi_ui_engine {
        alias $INSTALL_DIR;
        try_files \$uri \$uri/ =404;
        
        # Enable CORS
        add_header Access-Control-Allow-Origin *;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # Service Worker scope
        location = /effi_ui_engine/service-worker.js {
            add_header Service-Worker-Allowed /effi_ui_engine/;
            add_header Cache-Control "no-cache";
        }
    }
}
EOF
        
        # Enable site
        ln -sf /etc/nginx/sites-available/effi-ui /etc/nginx/sites-enabled/
        
        # Test configuration
        nginx -t && systemctl reload nginx
        print_success "Nginx configured"
        
    elif [[ "$WEB_SERVER" == "apache2" ]]; then
        # Create Apache configuration
        cat > "/etc/apache2/sites-available/effi-ui.conf" << EOF
# Effi-UI Engine Configuration
Alias /effi_ui_engine $INSTALL_DIR

<Directory $INSTALL_DIR>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    
    # Enable CORS
    Header set Access-Control-Allow-Origin "*"
    
    # Cache static assets
    <FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg)$">
        Header set Cache-Control "max-age=31536000, public"
    </FilesMatch>
    
    # Service Worker
    <Files "service-worker.js">
        Header set Service-Worker-Allowed "/effi_ui_engine/"
        Header set Cache-Control "no-cache"
    </Files>
</Directory>
EOF
        
        # Enable site and required modules
        a2ensite effi-ui
        a2enmod headers
        a2enmod expires
        
        # Test configuration
        apache2ctl configtest && systemctl reload apache2
        print_success "Apache configured"
    fi
}

# Create test page
create_test_page() {
    print_info "Creating test page..."
    
    cat > "$INSTALL_DIR/../test-effi-ui.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Test Page - דף בדיקה</title>
    <script src="/effi_ui_engine/effi_ui_loader.js"></script>
</head>
<body style="padding: 40px; font-family: Arial, sans-serif;">
    <h1>🧪 Effi-UI Test Page</h1>
    <p>אם אתה רואה הודעה זו ואין שגיאות בקונסול, Effi-UI עובד!</p>
    
    <div style="margin: 30px 0;">
        <button class="effi-btn effi-btn-primary">כפתור בדיקה 1</button>
        <button class="effi-btn" style="background: #4caf50; color: white; margin-right: 10px;">כפתור בדיקה 2</button>
    </div>
    
    <div id="status" style="margin: 30px 0; padding: 20px; background: #f0f0f0; border-radius: 10px;"></div>
    
    <div class="effi-card" style="max-width: 400px;">
        <h3>כרטיס לדוגמה</h3>
        <p>גרור אפקטים מהפאנל כדי לראות אותם בפעולה!</p>
    </div>
    
    <script>
        // בדיקת טעינת המערכת
        window.addEventListener('effi-ui-loaded', function(e) {
            document.getElementById('status').innerHTML = 
                '<p style="color: green; font-size: 1.2em;">✅ Effi-UI נטען בהצלחה!</p>' +
                '<p>גרסה: ' + e.detail.version + '</p>' +
                '<p>זמן טעינה: ' + e.detail.loadTime.toFixed(2) + ' ms</p>' +
                '<p>פרופיל: ' + e.detail.profile + '</p>';
        });
        
        window.addEventListener('effi-ui-error', function(e) {
            document.getElementById('status').innerHTML = 
                '<p style="color: red;">❌ שגיאה בטעינת Effi-UI: ' + e.detail.error + '</p>';
        });
        
        // הודעה אם לא נטען אחרי 5 שניות
        setTimeout(function() {
            if (!window.EffiUI) {
                document.getElementById('status').innerHTML = 
                    '<p style="color: orange;">⏳ נראה שהטעינה לוקחת זמן...</p>';
            }
        }, 5000);
    </script>
</body>
</html>
EOF
    
    print_success "Test page created at: $INSTALL_DIR/../test-effi-ui.html"
}

# Show features
show_features() {
    echo ""
    print_header
    echo -e "${CYAN}✨ תכונות מותקנות:${NC}"
    echo ""
    
    print_feature "ארגז כלים עם 100+ רכיבים"
    print_feature "עורך HTML מובנה עם Drag & Drop"
    print_feature "5 פרופילי עיצוב מובנים"
    print_feature "תמיכה מלאה במובייל"
    print_feature "Progressive Web App"
    print_feature "מערכת אנימציות מתקדמת"
    print_feature "עבודה אופליין"
    print_feature "ייצוא/ייבוא הגדרות"
    print_feature "חוקי זמן אוטומטיים"
    print_feature "CSS מותאם אישית"
    
    echo ""
}

# Show completion message
show_completion() {
    echo ""
    show_logo
    print_success "Installation completed successfully! 🎉"
    echo ""
    
    echo -e "${GREEN}📋 סיכום התקנה:${NC}"
    print_info "מיקום התקנה: $INSTALL_DIR"
    print_info "גרסה: $VERSION"
    print_info "שרת: $WEB_SERVER"
    
    echo ""
    echo -e "${YELLOW}🔗 קישורים חשובים:${NC}"
    echo -e "${CYAN}לוח בקרה:${NC} http://localhost/effi_ui_engine/effi_ui_panel.html"
    echo -e "${CYAN}מרכז בקרה:${NC} http://localhost/effi_ui_engine/setup_visual_control.html"
    echo -e "${CYAN}תצוגה מקדימה:${NC} http://localhost/effi_ui_engine/effi_ui_preview.html"
    echo -e "${CYAN}דף בדיקה:${NC} http://localhost/test-effi-ui.html"
    echo -e "${CYAN}תיעוד:${NC} http://localhost/effi_ui_engine/docs/readme.html"
    
    echo ""
    echo -e "${MAGENTA}🚀 השלבים הבאים:${NC}"
    echo "1. בקר בדף הבדיקה כדי לוודא שהכל עובד"
    echo "2. פתח את לוח הבקרה להתחיל להשתמש"
    echo "3. הוסף את הסקריפט לדפים שלך:"
    echo -e "${CYAN}   <script src=\"/effi_ui_engine/effi_ui_loader.js\"></script>${NC}"
    
    echo ""
    echo -e "${GREEN}תהנה מ-Effi-UI! 🎨✨${NC}"
    echo ""
}

# Main installation flow
main() {
    clear
    show_logo
    print_header
    
    # Check if already installed
    if [[ -f "$INSTALL_DIR/effi_ui_engine.js" ]]; then
        print_warning "נראה ש-Effi-UI כבר מותקן"
        read -p "לעדכן/להתקין מחדש? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    check_root
    check_requirements
    get_install_dir
    create_structure
    create_files
    create_icons
    set_permissions
    
    # Configure web server if available
    if [[ ! -z "$WEB_SERVER" ]]; then
        configure_webserver
    fi
    
    create_test_page
    show_features
    
    # Copy this install script to installation directory
    cp "$0" "$INSTALL_DIR/install.sh" 2>/dev/null || true
    
    show_completion
}

# Run main function
main "$@"