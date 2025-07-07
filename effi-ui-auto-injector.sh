#!/bin/bash

# Effi-UI Auto Injector Script
# מוסיף את Effi-UI לכל דפי ה-HTML באופן אוטומטי
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
SEARCH_DIR="${1:-.}"  # ברירת מחדל: תיקייה נוכחית
BACKUP_DIR="effi_backup_$(date +%Y%m%d_%H%M%S)"
INJECT_CODE='<script src="/effi_ui_engine/effi_ui_loader.js"></script>'
FILES_PROCESSED=0
FILES_SKIPPED=0
FILES_FAILED=0

# Logo
show_logo() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════╗
    ║        Effi-UI Auto Injector              ║
    ║   Adding magic to all your HTML files!    ║
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

# Check if file already has Effi-UI
has_effi_ui() {
    local file="$1"
    grep -q "effi_ui_loader.js" "$file" || grep -q "effi_ui_engine.js" "$file"
}

# Inject Effi-UI into HTML file
inject_effi_ui() {
    local file="$1"
    local filename=$(basename "$file")
    
    print_info "Processing: $file"
    
    # Check if already has Effi-UI
    if has_effi_ui "$file"; then
        print_warning "Skipping $filename - already has Effi-UI"
        ((FILES_SKIPPED++))
        return
    fi
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$filename.backup" 2>/dev/null
    
    # Try to inject before </body>
    if grep -q "</body>" "$file"; then
        # Add before </body>
        sed -i "s|</body>|    $INJECT_CODE\n</body>|" "$file"
        print_success "Added to $filename (before </body>)"
        ((FILES_PROCESSED++))
    
    # Try to inject before </html>
    elif grep -q "</html>" "$file"; then
        # Add before </html>
        sed -i "s|</html>|    $INJECT_CODE\n</html>|" "$file"
        print_success "Added to $filename (before </html>)"
        ((FILES_PROCESSED++))
    
    # Try to inject after <head>
    elif grep -q "<head>" "$file"; then
        # Add after <head>
        sed -i "s|<head>|<head>\n    $INJECT_CODE|" "$file"
        print_success "Added to $filename (in <head>)"
        ((FILES_PROCESSED++))
    
    else
        print_error "Failed to add to $filename - no suitable location found"
        ((FILES_FAILED++))
    fi
}

# Process single file
process_file() {
    local file="$1"
    inject_effi_ui "$file"
}

# Process directory
process_directory() {
    local dir="$1"
    local count=0
    
    print_info "Searching for HTML files in: $dir"
    
    # Find all HTML files
    while IFS= read -r -d '' file; do
        ((count++))
        process_file "$file"
    done < <(find "$dir" -type f \( -name "*.html" -o -name "*.htm" \) -print0)
    
    if [ $count -eq 0 ]; then
        print_warning "No HTML files found in $dir"
    fi
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    fi
}

# Show summary
show_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}           Summary Report              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Files processed:${NC} $FILES_PROCESSED"
    echo -e "${YELLOW}⚠ Files skipped:${NC} $FILES_SKIPPED"
    echo -e "${RED}✗ Files failed:${NC} $FILES_FAILED"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    if [ $FILES_PROCESSED -gt 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 Success! Effi-UI has been added to $FILES_PROCESSED files!${NC}"
        echo -e "${BLUE}📁 Backups saved in: $BACKUP_DIR${NC}"
    fi
}

# Interactive mode
interactive_mode() {
    echo -e "${MAGENTA}🔍 Interactive Mode${NC}"
    echo ""
    echo "Choose an option:"
    echo "1) Process current directory"
    echo "2) Process specific directory"
    echo "3) Process single file"
    echo "4) Process entire website (/var/www/html)"
    echo ""
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            process_directory "."
            ;;
        2)
            read -p "Enter directory path: " custom_dir
            if [ -d "$custom_dir" ]; then
                process_directory "$custom_dir"
            else
                print_error "Directory not found: $custom_dir"
                exit 1
            fi
            ;;
        3)
            read -p "Enter file path: " custom_file
            if [ -f "$custom_file" ]; then
                create_backup_dir
                process_file "$custom_file"
            else
                print_error "File not found: $custom_file"
                exit 1
            fi
            ;;
        4)
            if [ -d "/var/www/html" ]; then
                process_directory "/var/www/html"
            else
                print_error "Website directory not found: /var/www/html"
                exit 1
            fi
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# Remove Effi-UI mode
remove_mode() {
    print_warning "Remove mode - This will remove Effi-UI from all HTML files"
    read -p "Are you sure? (y/n): " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    
    local count=0
    while IFS= read -r -d '' file; do
        if has_effi_ui "$file"; then
            # Remove the script tag
            sed -i "/$INJECT_CODE/d" "$file"
            sed -i "/effi_ui_loader.js/d" "$file"
            sed -i "/effi_ui_engine.js/d" "$file"
            print_success "Removed from: $file"
            ((count++))
        fi
    done < <(find "$SEARCH_DIR" -type f \( -name "*.html" -o -name "*.htm" \) -print0)
    
    echo ""
    print_success "Removed Effi-UI from $count files"
}

# Safe mode - preview changes
preview_mode() {
    print_info "Preview mode - showing what would be changed:"
    echo ""
    
    local would_process=0
    local would_skip=0
    
    while IFS= read -r -d '' file; do
        if has_effi_ui "$file"; then
            echo -e "${YELLOW}[SKIP]${NC} $file - already has Effi-UI"
            ((would_skip++))
        else
            echo -e "${GREEN}[ADD]${NC} $file - would add Effi-UI"
            ((would_process++))
        fi
    done < <(find "$SEARCH_DIR" -type f \( -name "*.html" -o -name "*.htm" \) -print0)
    
    echo ""
    echo -e "${CYAN}Preview Summary:${NC}"
    echo -e "Would process: ${GREEN}$would_process${NC} files"
    echo -e "Would skip: ${YELLOW}$would_skip${NC} files"
    echo ""
    
    if [ $would_process -gt 0 ]; then
        read -p "Continue with actual processing? (y/n): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            create_backup_dir
            process_directory "$SEARCH_DIR"
        fi
    fi
}

# Main function
main() {
    clear
    show_logo
    
    # Parse arguments
    case "${1:-}" in
        --help|-h)
            echo "Usage: $0 [options] [directory]"
            echo ""
            echo "Options:"
            echo "  -h, --help      Show this help"
            echo "  -i, --interactive  Interactive mode"
            echo "  -r, --remove    Remove Effi-UI from files"
            echo "  -p, --preview   Preview changes without applying"
            echo "  -a, --all       Process all files in /var/www/html"
            echo ""
            echo "Examples:"
            echo "  $0              # Process current directory"
            echo "  $0 /path/to/dir # Process specific directory"
            echo "  $0 -i           # Interactive mode"
            echo "  $0 -r           # Remove mode"
            echo "  $0 -p           # Preview mode"
            exit 0
            ;;
        --interactive|-i)
            interactive_mode
            ;;
        --remove|-r)
            remove_mode
            exit 0
            ;;
        --preview|-p)
            SEARCH_DIR="${2:-.}"
            preview_mode
            exit 0
            ;;
        --all|-a)
            SEARCH_DIR="/var/www/html"
            create_backup_dir
            process_directory "$SEARCH_DIR"
            ;;
        *)
            # Default: process given directory or current
            create_backup_dir
            process_directory "$SEARCH_DIR"
            ;;
    esac
    
    show_summary
}

# Run main
main "$@"