#!/bin/bash

# Effi-UI Clean & Inject Script
# מנקה עיצובים ישנים ומחליף ב-Effi-UI
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
SEARCH_DIR="${1:-.}"
BACKUP_DIR="effi_clean_backup_$(date +%Y%m%d_%H%M%S)"
INJECT_CODE='<script src="/effi_ui_engine/effi_ui_loader.js"></script>'
FILES_CLEANED=0
FILES_FAILED=0

# Logo
show_logo() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════╗
    ║     Effi-UI Clean & Replace Tool          ║
    ║   Removing old styles, adding new magic!  ║
    ║         Made with ❤️ for Haim             ║
    ╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Print functions
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# Create backup
backup_file() {
    local file="$1"
    local filename=$(basename "$file")
    cp "$file" "$BACKUP_DIR/$filename.backup"
}

# Clean old styles and scripts
clean_old_styles() {
    local file="$1"
    local temp_file="${file}.tmp"
    
    print_info "Cleaning: $file"
    
    # Start with original file
    cp "$file" "$temp_file"
    
    # Remove inline styles
    print_info "  → Removing inline styles..."
    sed -i 's/style="[^"]*"//g' "$temp_file"
    sed -i "s/style='[^']*'//g" "$temp_file"
    
    # Remove style tags (but keep Effi-UI styles)
    print_info "  → Removing old <style> tags..."
    sed -i '/<style[^>]*>/,/<\/style>/d' "$temp_file"
    
    # Remove CSS links (but keep Effi-UI CSS)
    print_info "  → Removing old CSS links..."
    sed -i '/<link.*rel="stylesheet"[^>]*>/d' "$temp_file"
    sed -i '/<link.*\.css[^>]*>/d' "$temp_file"
    
    # Remove JavaScript files (but keep Effi-UI)
    print_info "  → Removing old scripts..."
    sed -i '/<script.*src="[^"]*\.js"[^>]*><\/script>/d' "$temp_file"
    sed -i '/<script.*src='"'"'[^'"'"']*\.js'"'"'[^>]*><\/script>/d' "$temp_file"
    
    # Remove inline JavaScript (optional - be careful!)
    if [[ "$REMOVE_INLINE_JS" == "yes" ]]; then
        print_info "  → Removing inline JavaScript..."
        sed -i '/<script[^>]*>/,/<\/script>/d' "$temp_file"
    fi
    
    # Remove class attributes (optional)
    if [[ "$REMOVE_CLASSES" == "yes" ]]; then
        print_info "  → Removing class attributes..."
        sed -i 's/class="[^"]*"//g' "$temp_file"
        sed -i "s/class='[^']*'//g" "$temp_file"
    fi
    
    # Clean empty lines
    sed -i '/^[[:space:]]*$/d' "$temp_file"
    
    # Move cleaned content back
    mv "$temp_file" "$file"
    
    print_success "Cleaned old styles from $(basename $file)"
}

# Add Effi-UI to file
add_effi_ui() {
    local file="$1"
    
    # Add Effi-UI before </body>
    if grep -q "</body>" "$file"; then
        sed -i "s|</body>|    $INJECT_CODE\n</body>|" "$file"
        print_success "Added Effi-UI to $(basename $file)"
    elif grep -q "</html>" "$file"; then
        sed -i "s|</html>|    $INJECT_CODE\n</html>|" "$file"
        print_success "Added Effi-UI to $(basename $file)"
    else
        print_error "Failed to add Effi-UI to $(basename $file)"
        ((FILES_FAILED++))
        return 1
    fi
    
    ((FILES_CLEANED++))
}

# Add basic HTML structure if needed
add_basic_structure() {
    local file="$1"
    
    # Add viewport meta tag if missing
    if ! grep -q "viewport" "$file"; then
        sed -i '/<head>/a\    <meta name="viewport" content="width=device-width, initial-scale=1.0">' "$file"
    fi
    
    # Add charset if missing
    if ! grep -q "charset" "$file"; then
        sed -i '/<head>/a\    <meta charset="UTF-8">' "$file"
    fi
    
    # Add basic container structure
    if grep -q "<body>" "$file"; then
        # Wrap body content in container
        sed -i '/<body>/a\<div class="effi-container">' "$file"
        sed -i '/<\/body>/i\</div>' "$file"
    fi
}

# Process single file
process_file() {
    local file="$1"
    
    # Backup original
    backup_file "$file"
    
    # Clean old styles
    clean_old_styles "$file"
    
    # Add Effi-UI
    add_effi_ui "$file"
    
    # Add basic structure
    add_basic_structure "$file"
}

# Process directory
process_directory() {
    local dir="$1"
    
    print_info "Processing directory: $dir"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    print_success "Created backup directory: $BACKUP_DIR"
    
    # Find and process all HTML files
    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(find "$dir" -type f \( -name "*.html" -o -name "*.htm" \) -print0)
}

# Interactive mode
interactive_mode() {
    echo -e "${MAGENTA}🧹 Clean & Replace Mode${NC}"
    echo ""
    echo "This will:"
    echo "  • Remove all inline styles"
    echo "  • Remove all <style> tags"
    echo "  • Remove all CSS links"
    echo "  • Remove old JavaScript files"
    echo "  • Add Effi-UI to all pages"
    echo ""
    
    read -p "Remove inline JavaScript too? (y/n): " remove_js
    [[ $remove_js =~ ^[Yy]$ ]] && REMOVE_INLINE_JS="yes"
    
    read -p "Remove all class attributes? (y/n): " remove_classes
    [[ $remove_classes =~ ^[Yy]$ ]] && REMOVE_CLASSES="yes"
    
    echo ""
    read -p "Directory to process [current]: " custom_dir
    SEARCH_DIR="${custom_dir:-.}"
    
    echo ""
    print_warning "This will modify all HTML files in: $SEARCH_DIR"
    read -p "Continue? (y/n): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        process_directory "$SEARCH_DIR"
    else
        echo "Cancelled"
        exit 0
    fi
}

# Aggressive clean mode
aggressive_clean() {
    print_warning "AGGRESSIVE CLEAN MODE"
    echo "This will remove EVERYTHING except basic HTML structure!"
    read -p "Are you SURE? (type 'yes' to confirm): " confirm
    
    if [[ $confirm == "yes" ]]; then
        REMOVE_INLINE_JS="yes"
        REMOVE_CLASSES="yes"
        process_directory "$SEARCH_DIR"
    else
        echo "Cancelled"
        exit 0
    fi
}

# Show summary
show_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}           Summary Report              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Files cleaned & updated:${NC} $FILES_CLEANED"
    echo -e "${RED}✗ Files failed:${NC} $FILES_FAILED"
    echo -e "${BLUE}📁 Backups saved in:${NC} $BACKUP_DIR"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    if [ $FILES_CLEANED -gt 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Success! Your site is now clean and powered by Effi-UI!${NC}"
        echo -e "${YELLOW}⚠️  Original files backed up in: $BACKUP_DIR${NC}"
    fi
}

# Main function
main() {
    clear
    show_logo
    
    case "${1:-}" in
        --help|-h)
            echo "Usage: $0 [options] [directory]"
            echo ""
            echo "Options:"
            echo "  -h, --help         Show this help"
            echo "  -i, --interactive  Interactive mode (recommended)"
            echo "  -a, --aggressive   Aggressive clean (removes everything)"
            echo "  -d, --directory    Specify directory"
            echo ""
            exit 0
            ;;
        --interactive|-i)
            interactive_mode
            ;;
        --aggressive|-a)
            aggressive_clean
            ;;
        --directory|-d)
            SEARCH_DIR="${2:-.}"
            process_directory "$SEARCH_DIR"
            ;;
        *)
            interactive_mode
            ;;
    esac
    
    show_summary
}

# Run main
main "$@"