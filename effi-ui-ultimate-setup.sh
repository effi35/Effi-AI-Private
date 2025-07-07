#!/bin/bash

# Effi-UI Ultimate Setup Script
# מתקין את כל המערכת + מנקה עיצובים ישנים + מוסיף חילוץ תבניות
# Created with love for Haim ❤️

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
INSTALL_DIR="/var/www/html/effi_ui_engine"
SITE_DIR="/var/www/html"

# Logo
show_logo() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║     _____ ___ ___ ___   _   _ ___                    ║
    ║    | ____|  _|  _|_ _| | | | |_ _|                   ║
    ║    |  _| | |_| |_ | |  | | | || |                    ║
    ║    | |___|  _|  _|| |  | |_| || |                    ║
    ║    |_____|_| |_| |___|  \___/|___|                   ║
    ║                                                       ║
    ║          ULTIMATE SETUP v2.0                          ║
    ║                                                       ║
    ║    🎨 Complete Installation                           ║
    ║    🧹 Clean Old Styles                                ║
    ║    📋 Template Extraction                             ║
    ║    ✨ Auto Apply to All Pages                        ║
    ║                                                       ║
    ║         Made with ❤️ for Haim                         ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    sleep 2
}

# Print functions
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_step() { echo -e "\n${MAGENTA}▶ $1${NC}\n"; }

# Check root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Please run as root: sudo $0"
        exit 1
    fi
}

# Step 1: Install Effi-UI main system
install_effi_ui() {
    print_step "Step 1: Installing Effi-UI Engine..."
    
    # Run the main installer
    if [ -f "effi-ui-installer.sh" ]; then
        bash effi-ui-installer.sh "$INSTALL_DIR"
    else
        print_error "Main installer not found!"
        print_info "Downloading..."
        wget -O effi-ui-installer.sh "https://your-domain.com/effi-ui-installer.sh"
        chmod +x effi-ui-installer.sh
        bash effi-ui-installer.sh "$INSTALL_DIR"
    fi
    
    print_success "Effi-UI Engine installed!"
}

# Step 2: Add template extractor
add_template_extractor() {
    print_step "Step 2: Adding Template Extractor..."
    
    # Add template extractor to main engine file
    cat >> "$INSTALL_DIR/effi_ui_engine.js" << 'EOFEXTRACTOR'

// Template Extractor Addition
${cat effi-ui-template-extractor.js}
EOFEXTRACTOR
    
    print_success "Template Extractor added!"
}

# Step 3: Clean and inject into all pages
clean_and_inject() {
    print_step "Step 3: Cleaning old styles and injecting Effi-UI..."
    
    local backup_dir="effi_ultimate_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    print_info "Backing up original files to: $backup_dir"
    
    # Process each HTML file
    local count=0
    while IFS= read -r -d '' file; do
        ((count++))
        local filename=$(basename "$file")
        
        print_info "Processing: $file"
        
        # Backup
        cp "$file" "$backup_dir/$filename.backup"
        
        # Clean old styles
        sed -i 's/style="[^"]*"//g' "$file"
        sed -i "s/style='[^']*'//g" "$file"
        sed -i '/<style[^>]*>/,/<\/style>/d' "$file"
        sed -i '/<link.*rel="stylesheet"[^>]*>/d' "$file"
        
        # Add Effi-UI
        if ! grep -q "effi_ui_loader.js" "$file"; then
            if grep -q "</body>" "$file"; then
                sed -i 's|</body>|    <script src="/effi_ui_engine/effi_ui_loader.js"></script>\n</body>|' "$file"
            elif grep -q "</html>" "$file"; then
                sed -i 's|</html>|    <script src="/effi_ui_engine/effi_ui_loader.js"></script>\n</html>|' "$file"
            fi
        fi
        
        # Add viewport meta if missing
        if ! grep -q "viewport" "$file"; then
            sed -i '/<head>/a\    <meta name="viewport" content="width=device-width, initial-scale=1.0">' "$file"
        fi
        
        print_success "Processed: $filename"
        
    done < <(find "$SITE_DIR" -type f \( -name "*.html" -o -name "*.htm" \) -print0)
    
    print_success "Processed $count files!"
    print_info "Backups saved in: $backup_dir"
}

# Step 4: Create helper scripts
create_helper_scripts() {
    print_step "Step 4: Creating helper scripts..."
    
    # Create quick template extractor
    cat > "$INSTALL_DIR/extract-template.html" << 'EOFHELPER'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>Effi-UI Template Extractor</title>
    <script src="/effi_ui_engine/effi_ui_loader.js"></script>
</head>
<body style="padding: 40px; font-family: Arial, sans-serif; background: #f5f5f5;">
    <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
        <h1 style="text-align: center; color: #667eea;">🎨 חילוץ תבנית Effi-UI</h1>
        
        <p>הכנס כתובת של דף שאתה אוהב את העיצוב שלו:</p>
        
        <input type="url" id="template-url" placeholder="https://example.com" style="
            width: 100%;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            margin-bottom: 20px;
            box-sizing: border-box;
        ">
        
        <button onclick="extractTemplate()" style="
            width: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px;
            border-radius: 8px;
            font-size: 18px;
            cursor: pointer;
        ">חלץ והחל על כל האתר</button>
        
        <div id="status" style="margin-top: 20px;"></div>
    </div>
    
    <script>
        function extractTemplate() {
            const url = document.getElementById('template-url').value;
            if (!url) {
                alert('אנא הכנס כתובת URL');
                return;
            }
            
            document.getElementById('status').innerHTML = '<p style="color: #667eea;">⏳ מחלץ תבנית...</p>';
            
            // Wait for Effi-UI to load
            setTimeout(() => {
                if (window.EffiTemplateExtractor) {
                    window.EffiTemplateExtractor.extractFromPage(url, (template) => {
                        document.getElementById('status').innerHTML = '<p style="color: #4caf50;">✅ התבנית הוחלה בהצלחה!</p>';
                    });
                } else {
                    document.getElementById('status').innerHTML = '<p style="color: #f44336;">❌ שגיאה בטעינת המערכת</p>';
                }
            }, 2000);
        }
    </script>
</body>
</html>
EOFHELPER
    
    # Create management script
    cat > "$INSTALL_DIR/manage-effi-ui.sh" << 'EOFMANAGE'
#!/bin/bash

# Effi-UI Management Script

case "$1" in
    extract)
        echo "Opening template extractor..."
        xdg-open "http://localhost/effi_ui_engine/extract-template.html"
        ;;
    panel)
        echo "Opening control panel..."
        xdg-open "http://localhost/effi_ui_engine/effi_ui_panel.html"
        ;;
    clean)
        echo "Cleaning all styles..."
        bash effi-ui-clean-inject.sh -i
        ;;
    backup)
        echo "Creating backup..."
        tar -czf "effi_backup_$(date +%Y%m%d_%H%M%S).tar.gz" /var/www/html
        ;;
    *)
        echo "Usage: $0 {extract|panel|clean|backup}"
        echo ""
        echo "  extract - Open template extractor"
        echo "  panel   - Open control panel"
        echo "  clean   - Clean old styles"
        echo "  backup  - Create site backup"
        ;;
esac
EOFMANAGE
    
    chmod +x "$INSTALL_DIR/manage-effi-ui.sh"
    
    print_success "Helper scripts created!"
}

# Step 5: Final setup
final_setup() {
    print_step "Step 5: Final setup..."
    
    # Set permissions
    chown -R www-data:www-data "$INSTALL_DIR"
    find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
    find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
    chmod +x "$INSTALL_DIR"/*.sh
    
    # Create test page
    cat > "$SITE_DIR/effi-ui-test.html" << 'EOFTEST'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Effi-UI Ultimate Test</title>
    <script src="/effi_ui_engine/effi_ui_loader.js"></script>
</head>
<body>
    <div class="effi-container" style="padding: 40px;">
        <h1>🎉 Effi-UI Ultimate מותקן בהצלחה!</h1>
        
        <div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
            <h2>✅ מה הותקן:</h2>
            <ul>
                <li>מערכת Effi-UI מלאה עם 100+ רכיבים</li>
                <li>עורך HTML משולב</li>
                <li>מנקה עיצובים ישנים</li>
                <li>מחלץ תבניות אוטומטי</li>
                <li>החלה על כל דפי האתר</li>
            </ul>
        </div>
        
        <div style="display: flex; gap: 20px; flex-wrap: wrap;">
            <button class="effi-btn effi-btn-primary" onclick="window.open('/effi_ui_engine/effi_ui_panel.html')">
                🎨 פתח לוח בקרה
            </button>
            <button class="effi-btn" style="background: #764ba2; color: white;" onclick="window.open('/effi_ui_engine/extract-template.html')">
                📋 חלץ תבנית
            </button>
            <button class="effi-btn" style="background: #4caf50; color: white;" onclick="EffiUI.togglePanel()">
                🎯 פתח פאנל מהיר
            </button>
        </div>
        
        <div style="margin-top: 40px;">
            <h3>🚀 התחל לעבוד:</h3>
            <ol>
                <li>לחץ Ctrl+E לפתיחת הפאנל</li>
                <li>גרור אפקטים לכל אלמנט בדף</li>
                <li>לחץ פעמיים על טקסט לעריכה</li>
                <li>בחר פרופיל צבעים מהטאבים</li>
            </ol>
        </div>
    </div>
</body>
</html>
EOFTEST
    
    print_success "Test page created!"
}

# Summary
show_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}              🎉 Installation Complete! 🎉              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}✅ What's installed:${NC}"
    echo "  • Effi-UI Engine with 100+ components"
    echo "  • HTML Editor integrated"
    echo "  • Old styles cleaned from all pages"
    echo "  • Template extractor ready"
    echo "  • Applied to all HTML files"
    echo ""
    echo -e "${YELLOW}🔗 Important Links:${NC}"
    echo -e "  Control Panel: ${BLUE}http://localhost/effi_ui_engine/effi_ui_panel.html${NC}"
    echo -e "  Template Extractor: ${BLUE}http://localhost/effi_ui_engine/extract-template.html${NC}"
    echo -e "  Test Page: ${BLUE}http://localhost/effi-ui-test.html${NC}"
    echo ""
    echo -e "${MAGENTA}⌨️  Quick Commands:${NC}"
    echo "  • Press Ctrl+E on any page to open Effi-UI panel"
    echo "  • Use: $INSTALL_DIR/manage-effi-ui.sh {extract|panel|clean|backup}"
    echo ""
    echo -e "${GREEN}Enjoy your new Effi-UI powered website! 🚀${NC}"
    echo -e "${CYAN}Created with ❤️ for Haim${NC}"
    echo ""
}

# Main execution
main() {
    show_logo
    check_root
    
    print_info "Starting Effi-UI Ultimate Setup..."
    echo ""
    
    # Ask for confirmation
    print_warning "This will:"
    echo "  1. Install Effi-UI Engine"
    echo "  2. Clean all old styles from HTML files"
    echo "  3. Add Effi-UI to all pages"
    echo "  4. Install template extractor"
    echo ""
    read -p "Continue? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    
    # Run all steps
    install_effi_ui
    add_template_extractor
    clean_and_inject
    create_helper_scripts
    final_setup
    
    # Show summary
    show_summary
}

# Run main
main