#!/bin/bash

# סקריפט התקנה למאחד קוד חכם Pro 2.0
# ===================================

echo "🚀 התקנת מאחד קוד חכם Pro 2.0 מתחילה..."
echo "============================================="

# יצירת תיקיות
echo "📁 יוצר מבנה תיקיות..."

# תיקיית בסיס
BASE_DIR="$(pwd)/smart_code_merger_pro"
mkdir -p "$BASE_DIR"

# תיקיות ליבה
mkdir -p "$BASE_DIR/core"
mkdir -p "$BASE_DIR/utils"
mkdir -p "$BASE_DIR/ui"
mkdir -p "$BASE_DIR/api"
mkdir -p "$BASE_DIR/api/endpoints"
mkdir -p "$BASE_DIR/models"
mkdir -p "$BASE_DIR/assets/css"
mkdir -p "$BASE_DIR/assets/js"
mkdir -p "$BASE_DIR/assets/images"
mkdir -p "$BASE_DIR/pwa"
mkdir -p "$BASE_DIR/logs"
mkdir -p "$BASE_DIR/uploads"
mkdir -p "$BASE_DIR/temp"
mkdir -p "$BASE_DIR/versions"
mkdir -p "$BASE_DIR/security_reports"
mkdir -p "$BASE_DIR/sandboxes"
mkdir -p "$BASE_DIR/remote_cache"
mkdir -p "$BASE_DIR/docs/api_docs"
mkdir -p "$BASE_DIR/docs/user_guide"
mkdir -p "$BASE_DIR/docs/developer_docs"
mkdir -p "$BASE_DIR/docs/images"

echo "✅ מבנה תיקיות נוצר בהצלחה!"

# התקנת תלויות Python
echo "📦 מתקין תלויות Python..."

# בדיקה אם pip זמין
if command -v pip3 &>/dev/null; then
    PIP_CMD="pip3"
elif command -v pip &>/dev/null; then
    PIP_CMD="pip"
else
    echo "❌ שגיאה: pip לא נמצא. אנא התקן Python ו-pip לפני המשך ההתקנה."
    exit 1
fi

# יצירת קובץ requirements.txt
cat > "$BASE_DIR/requirements.txt" << 'EOF'
Flask>=2.1.1
Flask-Cors>=3.0.10
werkzeug>=2.1.1
python-dateutil>=2.8.2
chardet>=4.0.0
numpy>=1.22.0
nltk>=3.7
fuzzywuzzy>=0.18.0
scikit-learn>=1.0.2
tensorflow>=2.9.0
joblib>=1.1.0
pandas>=1.4.2
pillow>=9.1.0
pytesseract>=0.3.9
python-magic>=0.4.25
pytest>=7.1.2
gitpython>=3.1.27
bandit>=1.7.4
safety>=2.1.1
difflib-unified>=0.2.0
pygments>=2.12.0
jsonschema>=4.6.0
requests>=2.28.0
boto3>=1.24.0
pymongo>=4.1.1
paramiko>=2.11.0
webdav3.client>=3.14.6
pysmb>=1.2.9
beautifulsoup4>=4.11.1
EOF

# התקנת התלויות
$PIP_CMD install -r "$BASE_DIR/requirements.txt"

echo "✅ תלויות Python הותקנו בהצלחה!"

# יצירת קובץ metadata.json
echo "📄 יוצר קובץ metadata.json..."

cat > "$BASE_DIR/metadata.json" << 'EOF'
{
  "name": "smart_code_merger_pro",
  "version": "2.0.0",
  "description": "מודול חכם מורחב לאיחוד קבצי ZIP עם קוד ממקורות שונים, ניתוח מעמיק, ניהול גרסאות וסריקת אבטחה",
  "author": "Claude AI",
  "license": "MIT",
  "main": "module.py",
  "module_dependencies": [],
  "dependencies": {
    "python_packages": [
      "python-dateutil>=2.8.2",
      "chardet>=4.0.0",
      "numpy>=1.22.0",
      "nltk>=3.7",
      "fuzzywuzzy>=0.18.0",
      "flask>=2.1.1",
      "flask-cors>=3.0.10",
      "werkzeug>=2.1.1",
      "scikit-learn>=1.0.2",
      "tensorflow>=2.9.0",
      "joblib>=1.1.0",
      "pandas>=1.4.2",
      "pillow>=9.1.0",
      "pytesseract>=0.3.9",
      "python-magic>=0.4.25",
      "pytest>=7.1.2",
      "gitpython>=3.1.27",
      "bandit>=1.7.4",
      "safety>=2.1.1",
      "difflib-unified>=0.2.0"
    ]
  },
  "ui_components": {
    "settings_tab": true,
    "main_tab": true,
    "diff_viewer": true,
    "version_manager": true,
    "security_scanner": true
  },
  "hooks": [
    "system_startup",
    "system_shutdown",
    "project_detection",
    "file_merge",
    "security_scan",
    "version_change"
  ],
  "features": {
    "project_detection": true,
    "content_analysis": true,
    "system_merge": true,
    "document_analysis": true,
    "version_management": true,
    "security_scanning": true,
    "code_completion": true,
    "code_running": true,
    "media_handling": true,
    "remote_storage": true,
    "export_import": true,
    "ci_cd_integration": true
  }
}
EOF

echo "✅ קובץ metadata.json נוצר בהצלחה!"

# יצירת קובץ config.json
echo "📄 יוצר קובץ config.json..."

cat > "$BASE_DIR/config.json" << 'EOF'
{
  "file_types": "*.py;*.js;*.html;*.css;*.java;*.xml;*.json;*.md;*.txt;*.c;*.cpp;*.cs;*.go;*.rb;*.php;*.scala;*.swift;*.ts;*.jsx;*.tsx;*.vue;*.rs;*.kt;*.dart;*.sql;*.sh;*.bat;*.yaml;*.yml;*.toml;*.ini;*.config;*.jpg;*.png;*.gif;*.svg;*.mp4;*.mp3;*.wav;*.pdf;*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx",
  "project_detection": {
    "min_files_for_project": 2,
    "key_files": [
      "package.json", ".gitignore", "README.md", "setup.py", "pom.xml", 
      "build.gradle", "Makefile", "CMakeLists.txt", ".travis.yml", 
      "Dockerfile", "docker-compose.yml", "requirements.txt", "Cargo.toml",
      "pubspec.yaml", "tsconfig.json", "tslint.json", ".eslintrc"
    ],
    "min_relationship_score": 0.5,
    "use_advanced_analysis": true,
    "use_machine_learning": true,
    "ml_model_path": "models/project_detector.pkl",
    "crosscheck_percent": 100
  },
  "merger": {
    "preserve_comments": true,
    "date_based_priority": true,
    "smart_structure_analysis": true,
    "conflict_resolution": "smart",
    "create_zip": true,
    "max_sources": 10,
    "backup_originals": true
  },
  "version_management": {
    "enabled": true,
    "max_versions": 10,
    "compression": "gzip",
    "storage_path": "versions",
    "include_metadata": true,
    "branch_tracking": true
  },
  "file_handling": {
    "process_binary_files": true,
    "process_documents": true,
    "process_media": true,
    "excluded_extensions": [".exe", ".dll", ".so", ".pyc", ".pyo", ".pyd", ".class", ".o", ".obj"],
    "max_file_size_mb": 50,
    "detect_encoding": true
  },
  "security_scanning": {
    "enabled": true,
    "scan_level": "medium",
    "excluded_patterns": ["node_modules", "venv", "__pycache__", ".git"],
    "vulnerability_db_update": true,
    "report_path": "security_reports"
  },
  "code_completion": {
    "enabled": true,
    "suggestions_limit": 5,
    "context_lines": 10,
    "supported_languages": ["python", "javascript", "java", "c", "cpp"]
  },
  "code_running": {
    "enabled": true,
    "sandbox_enabled": true,
    "timeout_seconds": 30,
    "memory_limit_mb": 512,
    "supported_languages": ["python", "javascript", "bash"]
  },
  "system_merge": {
    "allow_cross_technology": true,
    "detect_conflicts": true,
    "rename_conflicts": true,
    "create_zip": true,
    "smart_integration": true
  },
  "remote_storage": {
    "enabled": true,
    "types": ["local", "ssh", "s3", "ftp", "webdav", "smb", "nfs"],
    "timeout_seconds": 30,
    "cache_enabled": true,
    "cache_expiry_seconds": 3600
  },
  "logging": {
    "level": "INFO",
    "max_size_mb": 10,
    "backup_count": 5,
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "log_requests": true,
    "performance_metrics": true
  },
  "performance": {
    "max_threads": 8,
    "chunk_size": 1000000,
    "cache_enabled": true,
    "cache_size_mb": 100,
    "batch_processing": true
  },
  "ui": {
    "theme": "auto",
    "animations": true,
    "expanded_info": true,
    "max_file_preview_kb": 500,
    "syntax_highlighting": true,
    "show_line_numbers": true,
    "auto_refresh": true,
    "multi_file_view": true
  },
  "api": {
    "enabled": true,
    "require_auth": true,
    "rate_limit": 100,
    "cors_enabled": true,
    "versions": ["v1", "v2"],
    "documentation": true,
    "swagger_enabled": true
  },
  "export_import": {
    "formats": ["json", "yaml", "xml", "csv"],
    "include_settings": true,
    "include_versions": true,
    "import_validation": true
  },
  "ci_cd": {
    "providers": ["jenkins", "github", "gitlab", "travis", "circle", "azure", "aws"],
    "webhook_enabled": true,
    "artifact_storage": true,
    "report_generation": true
  }
}
EOF

echo "✅ קובץ config.json נוצר בהצלחה!"

# יצירת קובץ languages_config.json
echo "📄 יוצר קובץ languages_config.json..."

cat > "$BASE_DIR/languages_config.json" << 'EOF'
{
  "python": {
    "command": "python",
    "extension": ".py",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["python", "--version"]
  },
  "javascript": {
    "command": "node",
    "extension": ".js",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["node", "--version"]
  },
  "typescript": {
    "command": "ts-node",
    "extension": ".ts",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["ts-node", "--version"]
  },
  "bash": {
    "command": "bash",
    "extension": ".sh",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["bash", "--version"]
  },
  "java": {
    "command": "java",
    "extension": ".java",
    "compile_command": "javac",
    "compile_args": [],
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["java", "--version"]
  },
  "c": {
    "command": "./a.out",
    "extension": ".c",
    "compile_command": "gcc",
    "compile_args": ["-o", "a.out"],
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["gcc", "--version"]
  },
  "cpp": {
    "command": "./a.out",
    "extension": ".cpp",
    "compile_command": "g++",
    "compile_args": ["-o", "a.out"],
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["g++", "--version"]
  },
  "php": {
    "command": "php",
    "extension": ".php",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["php", "--version"]
  },
  "ruby": {
    "command": "ruby",
    "extension": ".rb",
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["ruby", "--version"]
  },
  "go": {
    "command": "go",
    "extension": ".go",
    "args": ["run"],
    "env": {},
    "file_position": "{file}",
    "version_command": ["go", "version"]
  },
  "rust": {
    "command": "./target/debug/main",
    "extension": ".rs",
    "compile_command": "rustc",
    "compile_args": ["-o", "target/debug/main"],
    "args": [],
    "env": {},
    "file_position": "{file}",
    "version_command": ["rustc", "--version"]
  }
}
EOF

echo "✅ קובץ languages_config.json נוצר בהצלחה!"

# הורדת תמונות ואייקונים
echo "🖼️ מוריד תמונות ואייקונים..."

# אלו אייקונים לדוגמה, במציאות היית מוריד תמונות אמיתיות
mkdir -p "$BASE_DIR/assets/images"

# לוגו לדוגמה
cat > "$BASE_DIR/assets/images/logo.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="60" viewBox="0 0 200 60">
  <rect width="200" height="60" fill="#2D3748" rx="6" ry="6"/>
  <text x="20" y="35" font-family="Arial" font-size="20" fill="white">מאחד קוד חכם Pro</text>
  <text x="20" y="48" font-family="Arial" font-size="10" fill="#63B3ED">גרסה 2.0</text>
</svg>
EOF

# אייקונים
cat > "$BASE_DIR/assets/images/security.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
</svg>
EOF

cat > "$BASE_DIR/assets/images/versions.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <polyline points="12 6 12 12 16 14"></polyline>
</svg>
EOF

cat > "$BASE_DIR/assets/images/run.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polygon points="5 3 19 12 5 21 5 3"></polygon>
</svg>
EOF

cat > "$BASE_DIR/assets/images/cloud.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"></path>
</svg>
EOF

cat > "$BASE_DIR/assets/images/merge.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="18" cy="18" r="3"></circle>
  <circle cx="6" cy="6" r="3"></circle>
  <path d="M6 21V9a9 9 0 0 0 9 9"></path>
</svg>
EOF

cat > "$BASE_DIR/assets/images/code.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="16 18 22 12 16 6"></polyline>
  <polyline points="8 6 2 12 8 18"></polyline>
</svg>
EOF

echo "✅ תמונות ואייקונים נוצרו בהצלחה!"

# יצירת קבצי CSS
echo "🎨 יוצר קבצי CSS..."

# קובץ CSS ראשי
cat > "$BASE_DIR/assets/css/main.css" << 'EOF'
/* מאחד קוד חכם Pro 2.0 - סגנון ראשי */

:root {
  --primary-color: #3182ce;
  --secondary-color: #4299e1;
  --accent-color: #ed8936;
  --background-color: #f7fafc;
  --text-color: #2d3748;
  --border-color: #e2e8f0;
  --success-color: #48bb78;
  --warning-color: #ecc94b;
  --error-color: #f56565;
  --border-radius: 0.375rem;
  --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  --transition: all 0.2s ease-in-out;
}

/* סגנון כללי */
html, body {
  height: 100%;
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 16px;
  line-height: 1.5;
  color: var(--text-color);
  background-color: var(--background-color);
  direction: rtl;
}

/* מבנה ראשי */
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

/* כותרות */
h1, h2, h3, h4, h5, h6 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-weight: 600;
  line-height: 1.2;
}

h1 {
  font-size: 2rem;
}

h2 {
  font-size: 1.75rem;
}

h3 {
  font-size: 1.5rem;
}

h4 {
  font-size: 1.25rem;
}

/* כפתורים */
.btn {
  display: inline-block;
  padding: 0.5rem 1rem;
  font-size: 1rem;
  font-weight: 500;
  text-align: center;
  text-decoration: none;
  cursor: pointer;
  border: 1px solid transparent;
  border-radius: var(--border-radius);
  transition: var(--transition);
}

.btn-primary {
  color: white;
  background-color: var(--primary-color);
  border-color: var(--primary-color);
}

.btn-primary:hover {
  background-color: var(--secondary-color);
  border-color: var(--secondary-color);
}

.btn-secondary {
  color: var(--text-color);
  background-color: white;
  border-color: var(--border-color);
}

.btn-secondary:hover {
  background-color: var(--border-color);
}

.btn-success {
  color: white;
  background-color: var(--success-color);
  border-color: var(--success-color);
}

.btn-warning {
  color: white;
  background-color: var(--warning-color);
  border-color: var(--warning-color);
}

.btn-error {
  color: white;
  background-color: var(--error-color);
  border-color: var(--error-color);
}

/* טבלאות */
table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}

th, td {
  padding: 0.75rem;
  text-align: right;
  border-bottom: 1px solid var(--border-color);
}

th {
  background-color: var(--border-color);
  font-weight: 600;
}

tr:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

/* טפסים */
input, select, textarea {
  width: 100%;
  padding: 0.5rem;
  font-size: 1rem;
  line-height: 1.5;
  color: var(--text-color);
  background-color: white;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
  transition: var(--transition);
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.5);
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

/* רספונסיביות */
@media (max-width: 768px) {
  .container {
    padding: 0.5rem;
  }
  
  h1 {
    font-size: 1.75rem;
  }
  
  h2 {
    font-size: 1.5rem;
  }
  
  h3 {
    font-size: 1.25rem;
  }
}

/* אנימציות */
@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.spinner {
  display: inline-block;
  width: 1.5rem;
  height: 1.5rem;
  border: 0.25rem solid rgba(0, 0, 0, 0.1);
  border-radius: 50%;
  border-top-color: var(--primary-color);
  animation: spin 1s linear infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
  100% {
    opacity: 1;
  }
}

.pulse {
  animation: pulse 2s ease-in-out infinite;
}
EOF

# קובץ CSS של תצוגת הבדלים
cat > "$BASE_DIR/assets/css/diff.css" << 'EOF'
/* מאחד קוד חכם Pro 2.0 - סגנון תצוגת הבדלים */

.diff-viewer {
  font-family: monospace;
  line-height: 1.5;
  white-space: pre-wrap;
  margin: 1rem 0;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
  overflow: hidden;
}

.diff-header {
  padding: 0.5rem;
  background-color: #f8fafc;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
}

.diff-content {
  padding: 0;
  margin: 0;
  list-style: none;
}

.diff-line {
  display: flex;
  padding: 0;
  margin: 0;
}

.diff-line-number {
  width: 3rem;
  padding: 0 0.5rem;
  text-align: right;
  color: #718096;
  border-right: 1px solid var(--border-color);
  background-color: #f8fafc;
  user-select: none;
}

.diff-line-content {
  flex: 1;
  padding: 0 0.5rem;
}

.diff-line-added {
  background-color: #f0fff4;
}

.diff-line-added .diff-line-content {
  background-color: #c6f6d5;
}

.diff-line-removed {
  background-color: #fff5f5;
}

.diff-line-removed .diff-line-content {
  background-color: #fed7d7;
}

.diff-line-info {
  background-color: #ebf8ff;
}

.diff-line-info .diff-line-content {
  background-color: #bee3f8;
}

/* צבעי תחביר */
.diff-keyword {
  color: #805ad5;
}

.diff-string {
  color: #dd6b20;
}

.diff-comment {
  color: #718096;
  font-style: italic;
}

.diff-function {
  color: #3182ce;
  font-weight: bold;
}

.diff-number {
  color: #38a169;
}
EOF

echo "✅ קבצי CSS נוצרו בהצלחה!"

# יצירת קבצי JavaScript
echo "📝 יוצר קבצי JavaScript..."

# קובץ JavaScript ראשי
cat > "$BASE_DIR/assets/js/main.js" << 'EOF'
/**
 * מאחד קוד חכם Pro 2.0 - קובץ JavaScript ראשי
 */

// טעינת מסמך
document.addEventListener('DOMContentLoaded', function() {
  console.log('מאחד קוד חכם Pro 2.0 נטען בהצלחה');
  initializeApp();
});

// אתחול האפליקציה
function initializeApp() {
  // חיבור מאזיני אירועים
  setupEventListeners();
  
  // אתחול ממשק משתמש
  initUI();
  
  // בדיקת תמיכה ב-PWA
  checkPWASupport();
  
  // טעינת הגדרות
  loadSettings();
}

// חיבור מאזיני אירועים
function setupEventListeners() {
  // טפסים
  const uploadForm = document.getElementById('upload-form');
  if (uploadForm) {
    uploadForm.addEventListener('submit', handleFileUpload);
  }
  
  // כפתורים
  const analyzeBtn = document.getElementById('analyze-btn');
  if (analyzeBtn) {
    analyzeBtn.addEventListener('click', startAnalysis);
  }
  
  const mergeBtn = document.getElementById('merge-btn');
  if (mergeBtn) {
    mergeBtn.addEventListener('click', startMerge);
  }
  
  // לשוניות
  const tabs = document.querySelectorAll('.tab-btn');
  tabs.forEach(tab => {
    tab.addEventListener('click', switchTab);
  });
}

// אתחול ממשק משתמש
function initUI() {
  // אתחול לשונית פעילה
  const activeTab = document.querySelector('.tab-btn.active');
  if (activeTab) {
    const tabId = activeTab.getAttribute('data-tab');
    showTabContent(tabId);
  }
  
  // אתחול תצוגות קוד
  initCodeEditors();
  
  // אתחול הנפשות
  initAnimations();
}

// הנפשות
function initAnimations() {
  // הנפשת רכיבים דינמיים
  const spinners = document.querySelectorAll('.spinner');
  spinners.forEach(spinner => {
    // הנפשה כבר מוגדרת ב-CSS
  });
  
  // הנפשת פולס לעדכונים
  const pulseElements = document.querySelectorAll('.pulse');
  pulseElements.forEach(element => {
    // הנפשה כבר מוגדרת ב-CSS
  });
  
  // הנפשת החלפת צבעים בכפתורים
  const statusButtons = document.querySelectorAll('.status-btn');
  statusButtons.forEach(button => {
    button.addEventListener('click', function() {
      // הסרת כל מצבי סטטוס קודמים
      this.classList.remove('status-running', 'status-success', 'status-error');
      
      // הוספת מצב חדש
      this.classList.add('status-running');
      
      // החלפת טקסט
      const originalText = this.textContent;
      this.textContent = 'מריץ...';
      
      // סימולציה של פעולה שלוקחת זמן
      setTimeout(() => {
        // בחירה אקראית של תוצאה (להדגמה בלבד)
        const result = Math.random() > 0.2 ? 'success' : 'error';
        
        // החלפת סטטוס
        this.classList.remove('status-running');
        this.classList.add(`status-${result}`);
        
        // החלפת טקסט
        this.textContent = result === 'success' ? 'הצלחה' : 'שגיאה';
        
        // החזרת הטקסט המקורי לאחר זמן קצר
        setTimeout(() => {
          this.textContent = originalText;
          this.classList.remove(`status-${result}`);
        }, 2000);
      }, 1500);
    });
  });
}

// בדיקת תמיכה ב-PWA
function checkPWASupport() {
  // בדיקה אם Service Worker נתמך
  if ('serviceWorker' in navigator) {
    // רישום Service Worker
    navigator.serviceWorker.register('/service-worker.js')
      .then(registration => {
        console.log('Service Worker רשום בהצלחה:', registration);
      })
      .catch(error => {
        console.log('רישום Service Worker נכשל:', error);
      });
  }
  
  // בדיקה אם האפליקציה מותקנת או ניתנת להתקנה
  window.addEventListener('beforeinstallprompt', (e) => {
    // שמירת האירוע כדי להציג אותו מאוחר יותר
    const deferredPrompt = e;
    
    // הצגת כפתור התקנה
    const installBtn = document.getElementById('install-btn');
    if (installBtn) {
      installBtn.style.display = 'inline-block';
      
      installBtn.addEventListener('click', () => {
        // הצגת חלון ההתקנה
        deferredPrompt.prompt();
        
        // בדיקת תוצאת הבחירה של המשתמש
        deferredPrompt.userChoice.then((choiceResult) => {
          if (choiceResult.outcome === 'accepted') {
            console.log('המשתמש התקין את האפליקציה');
            installBtn.style.display = 'none';
          } else {
            console.log('המשתמש דחה את ההתקנה');
          }
        });
      });
    }
  });
}

// טעינת הגדרות
function loadSettings() {
  // ניסיון לטעון הגדרות מאחסון מקומי
  const savedSettings = localStorage.getItem('smartCodeMergerSettings');
  
  if (savedSettings) {
    try {
      const settings = JSON.parse(savedSettings);
      applySettings(settings);
    } catch (e) {
      console.error('שגיאה בטעינת הגדרות:', e);
    }
  } else {
    // טעינת הגדרות ברירת מחדל
    fetch('/api/default-settings')
      .then(response => response.json())
      .then(settings => {
        applySettings(settings);
        // שמירת הגדרות ברירת מחדל
        localStorage.setItem('smartCodeMergerSettings', JSON.stringify(settings));
      })
      .catch(error => {
        console.error('שגיאה בטעינת הגדרות ברירת מחדל:', error);
      });
  }
}

// יישום הגדרות
function applySettings(settings) {
  // החלת ערכת נושא
  if (settings.theme === 'dark') {
    document.body.classList.add('dark-theme');
  } else if (settings.theme === 'light') {
    document.body.classList.add('light-theme');
  } else {
    // ערכת נושא אוטומטית
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      document.body.classList.add('dark-theme');
    } else {
      document.body.classList.add('light-theme');
    }
  }
  
  // הנפשות
  if (settings.animations === false) {
    document.body.classList.add('no-animations');
  }
  
  // הגדרות נוספות
  // ...
}

// לשוניות
function switchTab(event) {
  const tabId = event.target.getAttribute('data-tab');
  
  // הסרת פעיל מכל הלשוניות
  document.querySelectorAll('.tab-btn').forEach(tab => {
    tab.classList.remove('active');
  });
  
  // הוספת פעיל ללשונית הנוכחית
  event.target.classList.add('active');
  
  // הצגת תוכן הלשונית
  showTabContent(tabId);
}

function showTabContent(tabId) {
  // הסתרת כל תכני הלשוניות
  document.querySelectorAll('.tab-content').forEach(content => {
    content.style.display = 'none';
  });
  
  // הצגת תוכן הלשונית הנוכחית
  const currentTabContent = document.getElementById(`${tabId}-content`);
  if (currentTabContent) {
    currentTabContent.style.display = 'block';
  }
}

// אתחול עורכי קוד
function initCodeEditors() {
  // קוד לאתחול עורכי קוד
  // ...
}

// טיפול בהעלאת קבצים
function handleFileUpload(event) {
  event.preventDefault();
  
  // הצגת אנימציית טעינה
  const uploadStatus = document.getElementById('upload-status');
  if (uploadStatus) {
    uploadStatus.innerHTML = '<div class="spinner"></div> מעלה קבצים...';
    uploadStatus.style.display = 'block';
  }
  
  // השגת נתוני הטופס
  const formData = new FormData(event.target);
  
  // שליחת הקבצים לשרת
  fetch('/api/upload', {
    method: 'POST',
    body: formData
  })
  .then(response => response.json())
  .then(data => {
    // עדכון סטטוס העלאה
    if (uploadStatus) {
      if (data.success) {
        uploadStatus.innerHTML = '<span class="success">הקבצים הועלו בהצלחה!</span>';
        
        // הצגת הקבצים שהועלו
        if (data.files && data.files.length > 0) {
          const filesList = document.getElementById('uploaded-files');
          if (filesList) {
            filesList.innerHTML = '';
            data.files.forEach(file => {
              const fileItem = document.createElement('div');
              fileItem.className = 'file-item';
              fileItem.innerHTML = `
                <span class="file-name">${file.name}</span>
                <span class="file-size">${formatFileSize(file.size)}</span>
              `;
              filesList.appendChild(fileItem);
            });
            filesList.style.display = 'block';
          }
        }
      } else {
        uploadStatus.innerHTML = `<span class="error">שגיאה בהעלאת הקבצים: ${data.error}</span>`;
      }
    }
  })
  .catch(error => {
    console.error('שגיאה בהעלאת קבצים:', error);
    if (uploadStatus) {
      uploadStatus.innerHTML = '<span class="error">שגיאה בהעלאת הקבצים. נסה שוב מאוחר יותר.</span>';
    }
  });
}

// התחלת ניתוח
function startAnalysis() {
  // הצגת אנימציית טעינה
  const analysisStatus = document.getElementById('analysis-status');
  if (analysisStatus) {
    analysisStatus.innerHTML = '<div class="spinner"></div> מנתח פרויקטים...';
    analysisStatus.style.display = 'block';
  }
  
  // קבלת תיקיית יעד
  const targetDir = document.getElementById('target-dir').value;
  
  // שליחת בקשת ניתוח לשרת
  fetch('/api/analyze', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      target_dir: targetDir
    })
  })
  .then(response => response.json())
  .then(data => {
    // עדכון סטטוס ניתוח
    if (analysisStatus) {
      if (data.success) {
        analysisStatus.innerHTML = '<span class="success">הניתוח הושלם בהצלחה!</span>';
        
        // הצגת הפרויקטים שזוהו
        displayProjects(data.projects);
      } else {
        analysisStatus.innerHTML = `<span class="error">שגיאה בניתוח: ${data.error}</span>`;
      }
    }
  })
  .catch(error => {
    console.error('שגיאה בניתוח:', error);
    if (analysisStatus) {
      analysisStatus.innerHTML = '<span class="error">שגיאה בניתוח. נסה שוב מאוחר יותר.</span>';
    }
  });
}

// התחלת מיזוג
function startMerge() {
  // הצגת אנימציית טעינה
  const mergeStatus = document.getElementById('merge-status');
  if (mergeStatus) {
    mergeStatus.innerHTML = '<div class="spinner"></div> ממזג פרויקטים...';
    mergeStatus.style.display = 'block';
  }
  
  // קבלת פרויקטים נבחרים
  const selectedProjects = [];
  document.querySelectorAll('.project-checkbox:checked').forEach(checkbox => {
    selectedProjects.push(checkbox.value);
  });
  
  // בדיקה שנבחרו פרויקטים
  if (selectedProjects.length === 0) {
    if (mergeStatus) {
      mergeStatus.innerHTML = '<span class="error">יש לבחור לפחות פרויקט אחד למיזוג.</span>';
    }
    return;
  }
  
  // שליחת בקשת מיזוג לשרת
  fetch('/api/merge', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      projects: selectedProjects
    })
  })
  .then(response => response.json())
  .then(data => {
    // עדכון סטטוס מיזוג
    if (mergeStatus) {
      if (data.success) {
        mergeStatus.innerHTML = '<span class="success">המיזוג הושלם בהצלחה!</span>';
        
        // הצגת קישור להורדת הפרויקט הממוזג
        if (data.download_url) {
          const downloadLink = document.createElement('a');
          downloadLink.href = data.download_url;
          downloadLink.className = 'btn btn-primary';
          downloadLink.textContent = 'הורדת הפרויקט הממוזג';
          mergeStatus.appendChild(document.createElement('br'));
          mergeStatus.appendChild(downloadLink);
        }
      } else {
        mergeStatus.innerHTML = `<span class="error">שגיאה במיזוג: ${data.error}</span>`;
      }
    }
  })
  .catch(error => {
    console.error('שגיאה במיזוג:', error);
    if (mergeStatus) {
      mergeStatus.innerHTML = '<span class="error">שגיאה במיזוג. נסה שוב מאוחר יותר.</span>';
    }
  });
}

// הצגת פרויקטים
function displayProjects(projects) {
  const projectsList = document.getElementById('projects-list');
  if (!projectsList) return;
  
  // ניקוי רשימת פרויקטים קיימת
  projectsList.innerHTML = '';
  
  if (!projects || Object.keys(projects).length === 0) {
    projectsList.innerHTML = '<div class="info-message">לא זוהו פרויקטים.</div>';
    return;
  }
  
  // יצירת רשימת פרויקטים
  Object.entries(projects).forEach(([projectId, project]) => {
    const projectItem = document.createElement('div');
    projectItem.className = 'project-item';
    
    projectItem.innerHTML = `
      <div class="project-header">
        <input type="checkbox" id="project-${projectId}" class="project-checkbox" value="${projectId}">
        <label for="project-${projectId}" class="project-name">${project.name || projectId}</label>
        <span class="project-files-count">${Object.keys(project.files || {}).length} קבצים</span>
      </div>
      <div class="project-details">
        <div class="project-description">${project.description || 'אין תיאור'}</div>
        <button class="btn btn-secondary btn-sm view-files-btn" data-project="${projectId}">הצג קבצים</button>
        <button class="btn btn-primary btn-sm merge-project-btn" data-project="${projectId}">מזג פרויקט</button>
      </div>
      <div class="project-files" id="files-${projectId}" style="display: none;"></div>
    `;
    
    projectsList.appendChild(projectItem);
    
    // הוספת פונקציונליות לכפתורים
    const viewFilesBtn = projectItem.querySelector('.view-files-btn');
    if (viewFilesBtn) {
      viewFilesBtn.addEventListener('click', () => {
        const filesContainer = document.getElementById(`files-${projectId}`);
        if (filesContainer) {
          if (filesContainer.style.display === 'none') {
            // טעינת רשימת קבצים
            filesContainer.innerHTML = '<div class="spinner"></div> טוען קבצים...';
            filesContainer.style.display = 'block';
            
            // טעינת הקבצים
            setTimeout(() => {
              displayProjectFiles(filesContainer, project.files || {});
            }, 500);
          } else {
            filesContainer.style.display = 'none';
          }
        }
      });
    }
    
    const mergeProjectBtn = projectItem.querySelector('.merge-project-btn');
    if (mergeProjectBtn) {
      mergeProjectBtn.addEventListener('click', () => {
        // בחירת הפרויקט הנוכחי
        const checkbox = document.getElementById(`project-${projectId}`);
        if (checkbox) {
          checkbox.checked = true;
        }
        
        // ביצוע מיזוג
        startMerge();
      });
    }
  });
}

// הצגת קבצי פרויקט
function displayProjectFiles(container, files) {
  if (!container) return;
  
  // ניקוי תוכן קיים
  container.innerHTML = '';
  
  if (!files || Object.keys(files).length === 0) {
    container.innerHTML = '<div class="info-message">אין קבצים בפרויקט זה.</div>';
    return;
  }
  
  // יצירת טבלת קבצים
  const table = document.createElement('table');
  table.className = 'files-table';
  
  // כותרות
  table.innerHTML = `
    <thead>
      <tr>
        <th>שם</th>
        <th>סוג</th>
        <th>גודל</th>
        <th>קשרים</th>
        <th>פעולות</th>
      </tr>
    </thead>
    <tbody></tbody>
  `;
  
  const tbody = table.querySelector('tbody');
  
  // מיון הקבצים לפי נתיב
  const sortedFiles = Object.entries(files).sort((a, b) => {
    return a[0].localeCompare(b[0]);
  });
  
  // הוספת שורות לטבלה
  sortedFiles.forEach(([path, fileInfo]) => {
    const tr = document.createElement('tr');
    
    tr.innerHTML = `
      <td>${path}</td>
      <td>${fileInfo.type || 'לא ידוע'}</td>
      <td>${formatFileSize(fileInfo.size || 0)}</td>
      <td>${fileInfo.relationships?.length || 0}</td>
      <td>
        <button class="btn btn-sm btn-secondary view-file-btn" data-path="${path}">צפייה</button>
      </td>
    `;
    
    tbody.appendChild(tr);
    
    // הוספת פונקציונליות לכפתור צפייה
    const viewFileBtn = tr.querySelector('.view-file-btn');
    if (viewFileBtn) {
      viewFileBtn.addEventListener('click', () => {
        viewFile(path);
      });
    }
  });
  
  container.appendChild(table);
}

// פונקציית עזר להמרת גודל קובץ
function formatFileSize(size) {
  if (size < 1024) {
    return `${size} B`;
  } else if (size < 1024 * 1024) {
    return `${(size / 1024).toFixed(2)} KB`;
  } else if (size < 1024 * 1024 * 1024) {
    return `${(size / (1024 * 1024)).toFixed(2)} MB`;
  } else {
    return `${(size / (1024 * 1024 * 1024)).toFixed(2)} GB`;
  }
}

// צפייה בקובץ
function viewFile(path) {
  // טעינת תוכן הקובץ
  fetch(`/api/file-content?path=${encodeURIComponent(path)}`)
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // יצירת חלון צפייה
        const modal = document.createElement('div');
        modal.className = 'modal';
        
        modal.innerHTML = `
          <div class="modal-content">
            <div class="modal-header">
              <h3>${path}</h3>
              <button class="close-btn">&times;</button>
            </div>
            <div class="modal-body">
              <pre class="file-content">${escapeHtml(data.content)}</pre>
            </div>
          </div>
        `;
        
        document.body.appendChild(modal);
        
        // סגירת חלון בלחיצה על X
        const closeBtn = modal.querySelector('.close-btn');
        if (closeBtn) {
          closeBtn.addEventListener('click', () => {
            modal.remove();
          });
        }
        
        // סגירת חלון בלחיצה מחוץ לתוכן
        modal.addEventListener('click', (event) => {
          if (event.target === modal) {
            modal.remove();
          }
        });
      } else {
        alert(`שגיאה בטעינת הקובץ: ${data.error}`);
      }
    })
    .catch(error => {
      console.error('שגיאה בטעינת תוכן הקובץ:', error);
      alert('שגיאה בטעינת תוכן הקובץ. נסה שוב מאוחר יותר.');
    });
}

// פונקציית עזר לבריחה מתווים מיוחדים
function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
EOF

echo "✅ קבצי JavaScript נוצרו בהצלחה!"

# יצירת קובץ PWA בסיסי (index.html)
echo "📱 יוצר קובץ index.html של PWA..."

cat > "$BASE_DIR/pwa/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#3182ce">
  <title>מאחד קוד חכם Pro 2.0</title>
  
  <!-- קישורים לקבצי CSS -->
  <link rel="stylesheet" href="/assets/css/main.css">
  <link rel="stylesheet" href="/assets/css/diff.css">
  
  <!-- קישור למניפסט PWA -->
  <link rel="manifest" href="/manifest.json">
  
  <!-- אייקונים -->
  <link rel="icon" href="/assets/images/favicon.ico">
  <link rel="apple-touch-icon" href="/assets/images/icon-192x192.png">
  
  <!-- תסריטים -->
  <script src="/assets/js/main.js" defer></script>
</head>
<body>
  <!-- כותרת -->
  <header class="app-header">
    <div class="container">
      <div class="logo">
        <img src="/assets/images/logo.svg" alt="מאחד קוד חכם Pro" width="200">
        <h1>מאחד קוד חכם Pro <span class="version">2.0</span></h1>
      </div>
      <div class="header-actions">
        <button id="install-btn" class="btn btn-primary" style="display: none;">התקן אפליקציה</button>
      </div>
    </div>
  </header>
  
  <!-- תפריט ניווט -->
  <nav class="app-nav">
    <div class="container">
      <div class="tabs">
        <button class="tab-btn active" data-tab="main">ראשי</button>
        <button class="tab-btn" data-tab="projects">פרויקטים</button>
        <button class="tab-btn" data-tab="versions">גרסאות</button>
        <button class="tab-btn" data-tab="security">אבטחה</button>
        <button class="tab-btn" data-tab="code">קוד</button>
        <button class="tab-btn" data-tab="remote">התחברות מרוחקת</button>
        <button class="tab-btn" data-tab="settings">הגדרות</button>
      </div>
    </div>
  </nav>
  
  <!-- תוכן ראשי -->
  <main class="app-main">
    <div class="container">
      <!-- לשונית ראשית -->
      <div id="main-content" class="tab-content">
        <h2>ברוכים הבאים למאחד קוד חכם Pro 2.0</h2>
        <p>בחר קבצי ZIP להעלאה והגדר תיקיית יעד למיזוג:</p>
        
        <form id="upload-form" class="form">
          <div class="form-group">
            <label for="zip-files">בחר קבצי ZIP:</label>
            <input type="file" id="zip-files" name="files" multiple accept=".zip">
          </div>
          
          <div class="form-group">
            <label for="target-dir">תיקיית יעד:</label>
            <input type="text" id="target-dir" name="target_dir" value="output">
          </div>
          
          <button type="submit" class="btn btn-primary status-btn">העלאת קבצים</button>
        </form>
        
        <div id="upload-status" class="status-message" style="display: none;"></div>
        
        <div id="uploaded-files" class="files-list" style="display: none;">
          <h3>קבצים שהועלו:</h3>
          <!-- כאן יוצגו הקבצים שהועלו -->
        </div>
        
        <div class="actions">
          <button id="analyze-btn" class="btn btn-primary status-btn">ניתוח פרויקטים</button>
        </div>
        
        <div id="analysis-status" class="status-message" style="display: none;"></div>
      </div>
      
      <!-- לשונית פרויקטים -->
      <div id="projects-content" class="tab-content" style="display: none;">
        <h2>פרויקטים שזוהו</h2>
        
        <div id="projects-list" class="projects-list">
          <!-- כאן יוצגו הפרויקטים שזוהו -->
          <div class="info-message">
            <p>טרם בוצע ניתוח. לחץ על "ניתוח פרויקטים" בלשונית הראשית.</p>
          </div>
        </div>
        
        <div class="actions">
          <button id="merge-btn" class="btn btn-primary status-btn">מיזוג פרויקטים נבחרים</button>
          <button id="merge-multiple-btn" class="btn btn-secondary status-btn">מיזוג מרובה</button>
        </div>
        
        <div id="merge-status" class="status-message" style="display: none;"></div>
      </div>
      
      <!-- לשונית גרסאות -->
      <div id="versions-content" class="tab-content" style="display: none;">
        <h2>ניהול גרסאות</h2>
        
        <div class="feature-card">
          <div class="feature-icon">
            <img src="/assets/images/versions.svg" alt="גרסאות">
          </div>
          <div class="feature-info">
            <h3>שמירת היסטוריית גרסאות</h3>
            <p>המודול החדש מאפשר שמירה של היסטוריית גרסאות לכל קובץ במערכת. כך תוכל לעקוב אחרי שינויים ולשחזר גרסאות קודמות בקלות.</p>
            <div class="actions">
              <button class="btn btn-primary status-btn">הצג היסטוריית גרסאות</button>
            </div>
          </div>
        </div>
        
        <div class="version-viewer">
          <h3>גרסאות אחרונות</h3>
          <div class="version-list" id="version-list">
            <!-- כאן יוצגו גרסאות קודמות -->
            <div class="info-message">
              <p>לא נבחר קובץ. בחר קובץ מרשימת הפרויקטים כדי לצפות בגרסאות שלו.</p>
            </div>
          </div>
        </div>
        
        <div class="diff-viewer">
          <h3>השוואת גרסאות</h3>
          <div class="diff-controls">
            <div class="form-group">
              <label for="version-from">גרסה מקורית:</label>
              <select id="version-from">
                <option value="">-- בחר גרסה --</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="version-to">גרסה חדשה:</label>
              <select id="version-to">
                <option value="">-- בחר גרסה --</option>
              </select>
            </div>
            
            <button id="compare-btn" class="btn btn-primary status-btn">השווה גרסאות</button>
          </div>
          
          <div class="diff-result" id="diff-result">
            <!-- כאן תוצג השוואת הגרסאות -->
          </div>
        </div>
      </div>
      
      <!-- לשונית אבטחה -->
      <div id="security-content" class="tab-content" style="display: none;">
        <h2>סריקות אבטחה</h2>
        
        <div class="feature-card">
          <div class="feature-icon">
            <img src="/assets/images/security.svg" alt="אבטחה">
          </div>
          <div class="feature-info">
            <h3>סריקת אבטחה לפרויקטים</h3>
            <p>המודול החדש מאפשר סריקת אבטחה מקיפה לפרויקטים, איתור פגיעויות, בדיקת תלויות, וזיהוי סודות וסיסמאות בקוד.</p>
            <div class="actions">
              <button id="scan-security-btn" class="btn btn-primary status-btn">סריקת אבטחה</button>
            </div>
          </div>
        </div>
        
        <div class="security-results" id="security-results">
          <!-- כאן יוצגו תוצאות סריקת האבטחה -->
          <div class="info-message">
            <p>טרם בוצעה סריקת אבטחה. בחר פרויקט ולחץ על "סריקת אבטחה".</p>
          </div>
        </div>
      </div>
      
      <!-- לשונית קוד -->
      <div id="code-content" class="tab-content" style="display: none;">
        <h2>הרצת והשלמת קוד</h2>
        
        <div class="feature-card">
          <div class="feature-icon">
            <img src="/assets/images/run.svg" alt="הרצת קוד">
          </div>
          <div class="feature-info">
            <h3>הרצת קוד</h3>
            <p>המודול החדש מאפשר הרצת קוד בסביבה מבודדת כדי לבדוק את תקינותו לאחר מיזוג.</p>
            <div class="actions">
              <button id="run-code-btn" class="btn btn-primary status-btn">הרץ קוד</button>
            </div>
          </div>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">
            <img src="/assets/images/code.svg" alt="השלמת קוד">
          </div>
          <div class="feature-info">
            <h3>השלמת קוד</h3>
            <p>המודול החדש מאפשר זיהוי והשלמה של קוד חסר או שבור.</p>
            <div class="actions">
              <button id="complete-code-btn" class="btn btn-primary status-btn">השלם קוד</button>
            </div>
          </div>
        </div>
        
        <div class="code-editor">
          <h3>עורך קוד</h3>
          <textarea id="code-editor-area" class="code-editor-textarea" rows="10" placeholder="הכנס קוד להרצה או השלמה..."></textarea>
          
          <div class="form-group">
            <label for="code-language">שפת תכנות:</label>
            <select id="code-language">
              <option value="python">Python</option>
              <option value="javascript">JavaScript</option>
              <option value="java">Java</option>
              <option value="c">C</option>
              <option value="cpp">C++</option>
              <option value="bash">Bash</option>
            </select>
          </div>
          
          <div class="code-output" id="code-output">
            <!-- כאן יוצג פלט הרצת הקוד -->
          </div>
        </div>
      </div>
      
      <!-- לשונית התחברות מרוחקת -->
      <div id="remote-content" class="tab-content" style="display: none;">
        <h2>התחברות לאחסון מרוחק</h2>
        
        <div class="feature-card">
          <div class="feature-icon">
            <img src="/assets/images/cloud.svg" alt="אחסון מרוחק">
          </div>
          <div class="feature-info">
            <h3>גישה לאחסון מרוחק</h3>
            <p>המודול החדש מאפשר גישה למערכות קבצים מרוחקות כולל SSH, S3, FTP, WebDAV ועוד.</p>
          </div>
        </div>
        
        <div class="connection-form">
          <h3>התחברות למקור מרוחק</h3>
          
          <form id="connect-form" class="form">
            <div class="form-group">
              <label for="storage-type">סוג אחסון:</label>
              <select id="storage-type" name="storage_type">
                <option value="local">מקומי</option>
                <option value="ssh">SSH</option>
                <option value="s3">S3</option>
                <option value="ftp">FTP</option>
                <option value="webdav">WebDAV</option>
                <option value="smb">SMB</option>
                <option value="nfs">NFS</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="host">שרת:</label>
              <input type="text" id="host" name="host" placeholder="example.com">
            </div>
            
            <div class="form-group">
              <label for="username">שם משתמש:</label>
              <input type="text" id="username" name="username">
            </div>
            
            <div class="form-group">
              <label for="password">סיסמה:</label>
              <input type="password" id="password" name="password">
            </div>
            
            <div class="form-group">
              <label for="path">נתיב:</label>
              <input type="text" id="path" name="path" value="/">
            </div>
            
            <button type="submit" class="btn btn-primary status-btn">התחבר</button>
          </form>
          
          <div id="connection-status" class="status-message" style="display: none;"></div>
        </div>
        
        <div class="remote-browser" id="remote-browser" style="display: none;">
          <h3>דפדפן קבצים מרוחק</h3>
          
          <div class="path-navigation">
            <span id="current-path">/</span>
            <button id="parent-dir-btn" class="btn btn-secondary btn-sm">תיקייה למעלה</button>
          </div>
          
          <div class="remote-files" id="remote-files">
            <!-- כאן יוצגו קבצים מרוחקים -->
          </div>
          
          <div class="actions">
            <button id="refresh-remote-btn" class="btn btn-secondary">רענון</button>
            <button id="download-remote-btn" class="btn btn-primary">הורדת קבצים נבחרים</button>
          </div>
        </div>
      </div>
      
      <!-- לשונית הגדרות -->
      <div id="settings-content" class="tab-content" style="display: none;">
        <h2>הגדרות</h2>
        
        <form id="settings-form" class="form">
          <div class="form-group">
            <label for="theme">ערכת נושא:</label>
            <select id="theme" name="theme">
              <option value="auto">אוטומטי</option>
              <option value="light">בהיר</option>
              <option value="dark">כהה</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="animations">הנפשות:</label>
            <select id="animations" name="animations">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="version-management">ניהול גרסאות:</label>
            <select id="version-management" name="version_management">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="security-scanning">סריקות אבטחה:</label>
            <select id="security-scanning" name="security_scanning">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="code-running">הרצת קוד:</label>
            <select id="code-running" name="code_running">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="code-completion">השלמת קוד:</label>
            <select id="code-completion" name="code_completion">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="multi-file-view">תצוגת קבצים מרובה:</label>
            <select id="multi-file-view" name="multi_file_view">
              <option value="true">מופעל</option>
              <option value="false">כבוי</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="logging-level">רמת לוגים:</label>
            <select id="logging-level" name="logging_level">
              <option value="DEBUG">דיבאג</option>
              <option value="INFO" selected>מידע</option>
              <option value="WARNING">אזהרה</option>
              <option value="ERROR">שגיאה</option>
              <option value="CRITICAL">קריטי</option>
            </select>
          </div>
          
          <button type="submit" class="btn btn-primary">שמור הגדרות</button>
        </form>
        
        <div id="settings-status" class="status-message" style="display: none;"></div>
      </div>
    </div>
  </main>
  
  <!-- כותרת תחתונה -->
  <footer class="app-footer">
    <div class="container">
      <p>מאחד קוד חכם Pro 2.0 &copy; 2025 כל הזכויות שמורות</p>
    </div>
  </footer>
</body>
</html>
EOF

# יצירת קובץ manifest.json
cat > "$BASE_DIR/pwa/manifest.json" << 'EOF'
{
  "name": "מאחד קוד חכם Pro",
  "short_name": "מאחד קוד",
  "description": "מערכת לאיחוד חכם של קבצי קוד ממקורות שונים",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#3182ce",
  "icons": [
    {
      "src": "/assets/images/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/images/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

# יצירת קובץ service-worker.js
cat > "$BASE_DIR/pwa/service-worker.js" << 'EOF'
// מאחד קוד חכם Pro 2.0 - Service Worker

const CACHE_NAME = 'smart-code-merger-pro-v2';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/assets/css/main.css',
  '/assets/css/diff.css',
  '/assets/js/main.js',
  '/assets/images/logo.svg',
  '/assets/images/security.svg',
  '/assets/images/versions.svg',
  '/assets/images/run.svg',
  '/assets/images/cloud.svg',
  '/assets/images/merge.svg',
  '/assets/images/code.svg',
  '/assets/images/icon-192x192.png',
  '/assets/images/icon-512x512.png'
];

// התקנת Service Worker
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll(ASSETS_TO_CACHE);
      })
      .then(() => {
        return self.skipWaiting();
      })
  );
});

// הפעלת Service Worker
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.filter((cacheName) => {
          return cacheName !== CACHE_NAME;
        }).map((cacheName) => {
          return caches.delete(cacheName);
        })
      );
    }).then(() => {
      return self.clients.claim();
    })
  );
});

// טיפול בבקשות
self.addEventListener('fetch', (event) => {
  // לא לטפל בבקשות API
  if (event.request.url.includes('/api/')) {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // שימוש בגרסה במטמון אם יש
        if (response) {
          return response;
        }
        
        // אחרת, מבצע בקשת רשת רגילה
        return fetch(event.request).then(
          (response) => {
            // בדיקה שהתשובה תקינה
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // שכפול התשובה (תשובות ניתן להשתמש בהן רק פעם אחת)
            const responseToCache = response.clone();
            
            // שמירת התשובה במטמון
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          }
        ).catch(() => {
          // אם אין חיבור רשת, החזרת דף שגיאה
          if (event.request.url.includes('.html')) {
            return caches.match('/offline.html');
          }
          
          return null;
        });
      })
  );
});
EOF

echo "✅ קבצי PWA נוצרו בהצלחה!"

# יצירת שרת PWA
echo "🖥️ יוצר שרת PWA..."

cat > "$BASE_DIR/pwa_server.py" << 'EOF'
#!/usr/bin/env python3
"""
שרת PWA למאחד קוד חכם Pro 2.0

שרת Flask פשוט להרצת ממשק PWA ולחשיפת API של המערכת.
"""

import os
import sys
import json
import logging
import tempfile
import mimetypes
from flask import Flask, request, jsonify, send_from_directory, send_file, redirect, url_for
from flask_cors import CORS
from werkzeug.utils import secure_filename

# תיקון ה-PATH כדי לאפשר ייבוא מקבצים במיקום הנוכחי
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)

# ייבוא המודול העיקרי
from module import SmartCodeMergerProModule

# יצירת אפליקציית Flask
app = Flask(__name__, static_folder='assets')
CORS(app)  # אפשור CORS לגישה מדפדפן

# אתחול המודול
module = SmartCodeMergerProModule()
if not module.initialize():
    print("שגיאה באתחול המודול. בדוק את הלוגים לפרטים נוספים.")
    sys.exit(1)

# הגדרת תיקיית העלאות
UPLOAD_FOLDER = os.path.join(current_dir, 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# הגדרת נתיב לתיקיית PWA
PWA_FOLDER = os.path.join(current_dir, 'pwa')

# הגדרת קובץ לוגים
log_dir = os.path.join(current_dir, 'logs')
os.makedirs(log_dir, exist_ok=True)
logging.basicConfig(
    filename=os.path.join(log_dir, 'pwa_server.log'),
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# קונפיגורציית Flask
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 1024 * 1024 * 1024  # 1GB מקסימום להעלאה

# נתיבי PWA

@app.route('/')
def index():
    """דף הבית של האפליקציה"""
    return send_from_directory(PWA_FOLDER, 'index.html')

@app.route('/manifest.json')
def manifest():
    """קובץ manifest של PWA"""
    return send_from_directory(PWA_FOLDER, 'manifest.json')

@app.route('/service-worker.js')
def service_worker():
    """קובץ service worker של PWA"""
    return send_from_directory(PWA_FOLDER, 'service-worker.js')

@app.route('/assets/<path:path>')
def serve_static(path):
    """סטטיק פיילז (CSS, JS, תמונות)"""
    return send_from_directory('assets', path)

# נתיבי API

@app.route('/api/upload', methods=['POST'])
def upload_files():
    """העלאת קבצי ZIP"""
    if 'files' not in request.files:
        return jsonify({"success": False, "error": "לא נמצאו קבצים בבקשה"}), 400
    
    files = request.files.getlist('files')
    if not files or files[0].filename == '':
        return jsonify({"success": False, "error": "לא נבחרו קבצים"}), 400
    
    # שמירת הקבצים
    saved_files = []
    for file in files:
        if file and file.filename.endswith('.zip'):
            filename = secure_filename(file.filename)
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(file_path)
            
            file_info = {
                "name": filename,
                "path": file_path,
                "size": os.path.getsize(file_path)
            }
            saved_files.append(file_info)
    
    if not saved_files:
        return jsonify({"success": False, "error": "אין קבצי ZIP חוקיים"}), 400
    
    # עדכון המודול עם הקבצים שהועלו
    zip_files = [file["path"] for file in saved_files]
    module.select_zip_files(zip_files)
    
    return jsonify({"success": True, "files": saved_files})

@app.route('/api/set-target', methods=['POST'])
def set_target():
    """הגדרת תיקיית יעד"""
    data = request.json
    if not data or 'target_dir' not in data:
        return jsonify({"success": False, "error": "חסר נתיב יעד"}), 400
    
    target_dir = data['target_dir']
    
    # יצירת התיקייה אם לא קיימת
    full_path = os.path.join(current_dir, target_dir)
    os.makedirs(full_path, exist_ok=True)
    
    # הגדרת תיקיית יעד במודול
    result = module.set_target_directory(full_path)
    
    if result:
        return jsonify({"success": True, "target_dir": full_path})
    else:
        return jsonify({"success": False, "error": "שגיאה בהגדרת תיקיית יעד"}), 500

@app.route('/api/analyze', methods=['POST'])
def analyze_projects():
    """ניתוח פרויקטים"""
    data = request.json
    if not data:
        data = {}
    
    target_dir = data.get('target_dir')
    if target_dir:
        # יצירת התיקייה אם לא קיימת
        full_path = os.path.join(current_dir, target_dir)
        os.makedirs(full_path, exist_ok=True)
        
        # הגדרת תיקיית יעד במודול
        module.set_target_directory(full_path)
    
    # ביצוע ניתוח
    results = module.analyze_projects()
    
    if not results or not results.get('detected_projects'):
        return jsonify({
            "success": False,
            "error": "לא זוהו פרויקטים או שאירעה שגיאה בניתוח"
        }), 500
    
    return jsonify({
        "success": True,
        "projects": results.get('detected_projects', {}),
        "orphan_files": results.get('orphan_files', {})
    })

@app.route('/api/merge', methods=['POST'])
def merge_projects():
    """מיזוג פרויקטים"""
    data = request.json
    if not data or 'projects' not in data:
        return jsonify({"success": False, "error": "חסרים פרויקטים למיזוג"}), 400
    
    projects = data['projects']
    
    if not projects:
        return jsonify({"success": False, "error": "לא נבחרו פרויקטים"}), 400
    
    # ביצוע מיזוג לכל פרויקט
    merged_projects = []
    
    for project_id in projects:
        result = module.merge_project(project_id)
        
        if result and result.get('status') == 'success':
            merged_projects.append({
                "project_id": project_id,
                "project_name": result.get('project_name', project_id),
                "output_dir": result.get('output_dir', ''),
                "files_count": result.get('files_count', 0)
            })
    
    if not merged_projects:
        return jsonify({"success": False, "error": "שגיאה במיזוג פרויקטים"}), 500
    
    # יצירת ZIP מהתוצאה
    output_dir = merged_projects[0]['output_dir']
    zip_file = tempfile.NamedTemporaryFile(delete=False, suffix='.zip').name
    
    import zipfile
    with zipfile.ZipFile(zip_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(output_dir):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, os.path.relpath(file_path, output_dir))
    
    # יצירת קישור להורדה
    download_url = f'/api/download?file={os.path.basename(zip_file)}'
    
    return jsonify({
        "success": True,
        "merged_projects": merged_projects,
        "download_url": download_url,
        "temp_file": zip_file
    })

@app.route('/api/merge-multiple', methods=['POST'])
def merge_multiple():
    """מיזוג מרובה של פרויקטים"""
    data = request.json
    if not data or 'projects' not in data or 'target_name' not in data:
        return jsonify({"success": False, "error": "חסרים פרויקטים או שם יעד"}), 400
    
    projects = data['projects']
    target_name = data['target_name']
    
    if not projects or len(projects) < 2:
        return jsonify({"success": False, "error": "יש לבחור לפחות שני פרויקטים למיזוג מרובה"}), 400
    
    # ביצוע מיזוג מרובה
    result = module.merge_multiple_projects(projects, target_name)
    
    if not result or result.get('status') != 'success':
        return jsonify({
            "success": False,
            "error": result.get('error', "שגיאה במיזוג מרובה")
        }), 500
    
    # יצירת ZIP מהתוצאה
    output_dir = result.get('output_dir', '')
    zip_file = tempfile.NamedTemporaryFile(delete=False, suffix='.zip').name
    
    import zipfile
    with zipfile.ZipFile(zip_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(output_dir):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, os.path.relpath(file_path, output_dir))
    
    # יצירת קישור להורדה
    download_url = f'/api/download?file={os.path.basename(zip_file)}'
    
    return jsonify({
        "success": True,
        "target_name": target_name,
        "output_dir": output_dir,
        "files_count": result.get('files_count', 0),
        "download_url": download_url,
        "temp_file": zip_file
    })

@app.route('/api/file-content')
def get_file_content():
    """קבלת תוכן קובץ"""
    path = request.args.get('path')
    if not path:
        return jsonify({"success": False, "error": "חסר נתיב לקובץ"}), 400
    
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        return jsonify({
            "success": True,
            "content": content,
            "path": path
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בקריאת הקובץ: {str(e)}",
            "path": path
        }), 500

@app.route('/api/download')
def download_file():
    """הורדת קובץ ZIP"""
    file = request.args.get('file')
    if not file:
        return jsonify({"success": False, "error": "חסר קובץ להורדה"}), 400
    
    # חיפוש הקובץ בתיקיית temp
    temp_dir = tempfile.gettempdir()
    file_path = os.path.join(temp_dir, file)
    
    if not os.path.exists(file_path):
        return jsonify({"success": False, "error": "קובץ לא נמצא"}), 404
    
    return send_file(file_path, as_attachment=True, download_name=file)

@app.route('/api/versions/<path:file_path>')
def get_file_versions(file_path):
    """קבלת גרסאות של קובץ"""
    # המרת נתיב יחסי לנתיב מלא
    try:
        # לקרוא גרסאות מהקובץ
        versions = module.get_file_versions(file_path)
        
        return jsonify({
            "success": True,
            "file_path": file_path,
            "versions": versions
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בקבלת גרסאות: {str(e)}",
            "file_path": file_path
        }), 500

@app.route('/api/compare-versions', methods=['POST'])
def compare_versions():
    """השוואת גרסאות"""
    data = request.json
    if not data or 'version1' not in data or 'version2' not in data:
        return jsonify({"success": False, "error": "חסרים מזהי גרסאות להשוואה"}), 400
    
    version1 = data['version1']
    version2 = data['version2']
    
    try:
        # השוואת גרסאות
        comparison = module.compare_file_versions(version1, version2)
        
        return jsonify({
            "success": True,
            "comparison": comparison
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בהשוואת גרסאות: {str(e)}"
        }), 500

@app.route('/api/security-scan', methods=['POST'])
def security_scan():
    """סריקת אבטחה"""
    data = request.json
    if not data or 'project_id' not in data:
        return jsonify({"success": False, "error": "חסר מזהה פרויקט לסריקה"}), 400
    
    project_id = data['project_id']
    
    try:
        # סריקת אבטחה
        scan_results = module.scan_project_security(project_id)
        
        return jsonify({
            "success": True,
            "results": scan_results
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בסריקת אבטחה: {str(e)}",
            "project_id": project_id
        }), 500

@app.route('/api/run-code', methods=['POST'])
def run_code():
    """הרצת קוד"""
    data = request.json
    if not data or 'code' not in data or 'language' not in data:
        return jsonify({"success": False, "error": "חסר קוד או שפה להרצה"}), 400
    
    code = data['code']
    language = data['language']
    parameters = data.get('parameters', {})
    
    try:
        # הרצת קוד
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=f'.{language}')
        temp_file.write(code.encode('utf-8'))
        temp_file.close()
        
        run_results = module.run_code(temp_file.name, parameters)
        
        # ניקוי
        os.unlink(temp_file.name)
        
        return jsonify({
            "success": True,
            "results": run_results
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בהרצת קוד: {str(e)}",
            "language": language
        }), 500

@app.route('/api/complete-code', methods=['POST'])
def complete_code():
    """השלמת קוד"""
    data = request.json
    if not data or 'code' not in data or 'language' not in data:
        return jsonify({"success": False, "error": "חסר קוד או שפה להשלמה"}), 400
    
    code = data['code']
    language = data['language']
    
    try:
        # זיהוי חלקים חסרים
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=f'.{language}')
        temp_file.write(code.encode('utf-8'))
        temp_file.close()
        
        missing_parts = module.detect_missing_parts(temp_file.name)
        
        # השלמת חלקים חסרים
        completion_results = module.complete_code(temp_file.name, missing_parts.get('missing_parts', []))
        
        # ניקוי
        os.unlink(temp_file.name)
        
        return jsonify({
            "success": True,
            "results": completion_results
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בהשלמת קוד: {str(e)}",
            "language": language
        }), 500

@app.route('/api/connect-remote', methods=['POST'])
def connect_remote():
    """התחברות לאחסון מרוחק"""
    data = request.json
    if not data or 'storage_type' not in data:
        return jsonify({"success": False, "error": "חסר סוג אחסון"}), 400
    
    storage_type = data['storage_type']
    connection_params = {k: v for k, v in data.items() if k != 'storage_type'}
    
    try:
        # התחברות לאחסון מרוחק
        connection_id = module.connect_remote_storage(storage_type, connection_params)
        
        if not connection_id:
            return jsonify({
                "success": False,
                "error": "שגיאה בהתחברות לאחסון מרוחק"
            }), 500
        
        return jsonify({
            "success": True,
            "connection_id": connection_id,
            "storage_type": storage_type
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בהתחברות לאחסון מרוחק: {str(e)}",
            "storage_type": storage_type
        }), 500

@app.route('/api/list-remote-files')
def list_remote_files():
    """רשימת קבצים באחסון מרוחק"""
    path = request.args.get('path', '/')
    connection_id = request.args.get('connection_id')
    
    try:
        # רשימת קבצים
        files = module.list_remote_files(path, connection_id)
        
        return jsonify({
            "success": True,
            "files": files
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בקבלת רשימת קבצים: {str(e)}",
            "path": path
        }), 500

@app.route('/api/download-remote-file', methods=['POST'])
def download_remote_file():
    """הורדת קובץ מאחסון מרוחק"""
    data = request.json
    if not data or 'remote_path' not in data:
        return jsonify({"success": False, "error": "חסר נתיב מרוחק"}), 400
    
    remote_path = data['remote_path']
    connection_id = data.get('connection_id')
    
    try:
        # יצירת קובץ זמני ליעד
        local_path = tempfile.NamedTemporaryFile(delete=False).name
        
        # הורדת הקובץ
        result = module.download_remote_file(remote_path, local_path, connection_id)
        
        if not result or result.get('status') != 'success':
            return jsonify({
                "success": False,
                "error": result.get('error', "שגיאה בהורדת קובץ")
            }), 500
        
        # יצירת קישור להורדה
        download_url = f'/api/download-file?file={os.path.basename(local_path)}&name={os.path.basename(remote_path)}'
        
        return jsonify({
            "success": True,
            "download_url": download_url,
            "remote_path": remote_path,
            "local_path": local_path
        })
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"שגיאה בהורדת קובץ: {str(e)}",
            "remote_path": remote_path
        }), 500

@app.route('/api/default-settings')
def default_settings():
    """הגדרות ברירת מחדל"""
    return jsonify({
        "theme": "auto",
        "animations": True,
        "version_management": True,
        "security_scanning": True,
        "code_running": True,
        "code_completion": True,
        "multi_file_view": True,
        "logging_level": "INFO"
    })

@app.route('/api/system-info')
def system_info():
    """מידע מערכת"""
    return jsonify({
        "module_name": module.name,
        "module_version": module.version,
        "supported_languages": [
            "python", "javascript", "typescript", "java", "c", "cpp", 
            "csharp", "go", "ruby", "php", "rust", "swift", "kotlin", 
            "scala", "bash", "html", "css", "xml", "json", "yaml"
        ],
        "supported_storage_types": [
            "local", "ssh", "s3", "ftp", "webdav", "smb", "nfs"
        ],
        "new_features": [
            "ניהול גרסאות",
            "סריקות אבטחה",
            "הרצת קוד",
            "השלמת קוד",
            "אחסון מרוחק",
            "מיזוג מרובה",
            "ניתוח קשרים מעמיק"
        ]
    })

# הרצת השרת
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

echo "✅ שרת PWA נוצר בהצלחה!"

# יצירת קובץ README.md
echo "📝 יוצר קובץ README.md..."

cat > "$BASE_DIR/README.md" << 'EOF'
# מאחד קוד חכם Pro 2.0

> מערכת חכמה לאיחוד קבצי ZIP הכוללים קוד ממקורות שונים למערכות מאוחדות ומסודרות.

![לוגו מאחד קוד חכם Pro](assets/images/logo.svg)

## 📋 תיאור

מאחד קוד חכם Pro 2.0 היא תוכנה מתקדמת לאיחוד מתוחכם של קבצי קוד מקבצי ZIP שונים. התוכנה מזהה באופן אוטומטי לאיזה פרויקט כל קובץ שייך, מאחדת את הגרסאות השונות של כל קובץ, ויוצרת מבנה פרויקטים מסודר ומאוחד. גרסה 2.0 כוללת יכולות חדשות רבות כמו ניהול גרסאות, סריקות אבטחה, הרצת והשלמת קוד, וגישה לאחסון מרוחק.

### 🚀 יתרונות מרכזיים

- **זיהוי חכם של פרויקטים** - מערכת מתקדמת לניתוח תוכן קוד וזיהוי אוטומטי של פרויקטים שונים
- **ניתוח קשרים מתקדם** - זיהוי קשרים בין קבצים על בסיס 50+ פרמטרים
- **טיפול בכל סוגי הקבצים** - תמיכה בקבצי קוד, מסמכים, תמונות וקבצים בינאריים
- **מיזוג בין מערכות** - אפשרות למזג פרויקטים שונים בצורה חכמה
- **ממשק PWA נוח** - גישה לממשק דרך דפדפן ללא צורך בתצוגה גרפית בשרת
- **ניהול גרסאות** - שמירה והשוואה של גרסאות קוד
- **סריקות אבטחה** - זיהוי פגיעויות וקוד בעייתי
- **הרצת קוד** - בדיקת קוד בסביבה מבודדת
- **השלמת קוד** - זיהוי וטיפול בקוד חסר/שבור
- **גישה לאחסון מרוחק** - חיבור למערכות קבצים מרוחקות

## 🔧 התקנה והפעלה

### התקנה מהירה

להתקנה מהירה, הרץ:

```bash
./install.sh