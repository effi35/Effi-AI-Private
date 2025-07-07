// Effi-UI Template Extractor
// חולץ עיצוב מדף דוגמה ומחיל על כל האתר
// Created with love for Haim ❤️

(function() {
    'use strict';
    
    const EffiTemplateExtractor = {
        version: '1.0.0',
        extractedTemplate: null,
        
        // חילוץ עיצוב מדף
        extractFromPage: function(pageUrl, callback) {
            console.log('🎨 Extracting template from:', pageUrl);
            
            // טען את הדף בiframe נסתר
            const iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            iframe.src = pageUrl;
            
            iframe.onload = () => {
                const doc = iframe.contentDocument;
                const template = {
                    colors: this.extractColors(doc),
                    fonts: this.extractFonts(doc),
                    spacing: this.extractSpacing(doc),
                    buttons: this.extractButtons(doc),
                    backgrounds: this.extractBackgrounds(doc),
                    animations: this.extractAnimations(doc),
                    layout: this.extractLayout(doc),
                    components: this.extractComponents(doc)
                };
                
                // הסר את הiframe
                document.body.removeChild(iframe);
                
                // שמור את התבנית
                this.extractedTemplate = template;
                
                // צור פרופיל Effi-UI
                this.createEffiProfile(template);
                
                if (callback) callback(template);
            };
            
            document.body.appendChild(iframe);
        },
        
        // חילוץ צבעים
        extractColors: function(doc) {
            const colors = {
                primary: null,
                secondary: null,
                background: null,
                text: null,
                accents: []
            };
            
            // חלץ צבעים מה-body
            const bodyStyle = doc.defaultView.getComputedStyle(doc.body);
            colors.background = bodyStyle.backgroundColor;
            colors.text = bodyStyle.color;
            
            // חלץ צבעים מכותרות
            const h1 = doc.querySelector('h1');
            if (h1) {
                const h1Style = doc.defaultView.getComputedStyle(h1);
                colors.primary = h1Style.color;
            }
            
            // חלץ צבעים מכפתורים
            const buttons = doc.querySelectorAll('button, .btn, [type="submit"]');
            buttons.forEach(btn => {
                const btnStyle = doc.defaultView.getComputedStyle(btn);
                if (btnStyle.backgroundColor !== 'rgba(0, 0, 0, 0)') {
                    colors.accents.push(btnStyle.backgroundColor);
                }
            });
            
            // חלץ צבעים מקישורים
            const links = doc.querySelectorAll('a');
            if (links.length > 0) {
                const linkStyle = doc.defaultView.getComputedStyle(links[0]);
                colors.secondary = linkStyle.color;
            }
            
            return colors;
        },
        
        // חילוץ פונטים
        extractFonts: function(doc) {
            const fonts = {
                primary: null,
                headings: null,
                sizes: {}
            };
            
            const bodyStyle = doc.defaultView.getComputedStyle(doc.body);
            fonts.primary = bodyStyle.fontFamily;
            fonts.sizes.body = bodyStyle.fontSize;
            
            // חלץ פונטים מכותרות
            ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'].forEach(tag => {
                const element = doc.querySelector(tag);
                if (element) {
                    const style = doc.defaultView.getComputedStyle(element);
                    fonts.sizes[tag] = style.fontSize;
                    if (!fonts.headings) {
                        fonts.headings = style.fontFamily;
                    }
                }
            });
            
            return fonts;
        },
        
        // חילוץ מרווחים
        extractSpacing: function(doc) {
            const spacing = {
                containerWidth: null,
                padding: {},
                margins: {}
            };
            
            // חפש container ראשי
            const container = doc.querySelector('.container, .wrapper, main, [class*="container"]');
            if (container) {
                const style = doc.defaultView.getComputedStyle(container);
                spacing.containerWidth = style.maxWidth || style.width;
                spacing.padding.container = style.padding;
            }
            
            // חלץ מרווחים מאלמנטים נפוצים
            const elements = ['p', 'h1', 'h2', 'section', 'article'];
            elements.forEach(tag => {
                const el = doc.querySelector(tag);
                if (el) {
                    const style = doc.defaultView.getComputedStyle(el);
                    spacing.margins[tag] = style.margin;
                    spacing.padding[tag] = style.padding;
                }
            });
            
            return spacing;
        },
        
        // חילוץ סגנונות כפתורים
        extractButtons: function(doc) {
            const buttons = [];
            const btnElements = doc.querySelectorAll('button, .btn, [type="submit"], [type="button"]');
            
            btnElements.forEach((btn, index) => {
                if (index < 5) { // מקסימום 5 סוגי כפתורים
                    const style = doc.defaultView.getComputedStyle(btn);
                    buttons.push({
                        background: style.backgroundColor,
                        color: style.color,
                        border: style.border,
                        borderRadius: style.borderRadius,
                        padding: style.padding,
                        fontSize: style.fontSize,
                        fontWeight: style.fontWeight,
                        boxShadow: style.boxShadow,
                        transition: style.transition
                    });
                }
            });
            
            return buttons;
        },
        
        // חילוץ רקעים
        extractBackgrounds: function(doc) {
            const backgrounds = [];
            
            // חלץ רקעים מסקשנים ראשיים
            const sections = doc.querySelectorAll('section, header, footer, .hero, [class*="banner"]');
            sections.forEach((section, index) => {
                if (index < 5) {
                    const style = doc.defaultView.getComputedStyle(section);
                    if (style.backgroundImage !== 'none' || style.backgroundColor !== 'rgba(0, 0, 0, 0)') {
                        backgrounds.push({
                            backgroundImage: style.backgroundImage,
                            backgroundColor: style.backgroundColor,
                            backgroundSize: style.backgroundSize,
                            backgroundPosition: style.backgroundPosition,
                            backgroundRepeat: style.backgroundRepeat
                        });
                    }
                }
            });
            
            return backgrounds;
        },
        
        // חילוץ אנימציות
        extractAnimations: function(doc) {
            const animations = [];
            const animatedElements = doc.querySelectorAll('*');
            
            animatedElements.forEach(el => {
                const style = doc.defaultView.getComputedStyle(el);
                if (style.animation !== 'none' && style.animation !== '') {
                    animations.push({
                        animation: style.animation,
                        transition: style.transition
                    });
                }
            });
            
            return [...new Set(animations.map(a => a.animation))]; // ייחודיים בלבד
        },
        
        // חילוץ פריסה
        extractLayout: function(doc) {
            const layout = {
                type: 'standard',
                header: null,
                footer: null,
                sidebar: null,
                gridSystem: null
            };
            
            // זהה סוג פריסה
            if (doc.querySelector('.sidebar, aside')) {
                layout.type = 'sidebar';
                layout.sidebar = 'right'; // או left
            }
            
            // זהה מערכת גריד
            const gridElements = doc.querySelectorAll('[class*="col-"], [class*="grid"]');
            if (gridElements.length > 0) {
                layout.gridSystem = 'detected';
            }
            
            return layout;
        },
        
        // חילוץ רכיבים
        extractComponents: function(doc) {
            const components = {
                cards: [],
                forms: [],
                navigation: [],
                modals: []
            };
            
            // חלץ כרטיסים
            const cards = doc.querySelectorAll('.card, [class*="card"], article');
            cards.forEach((card, index) => {
                if (index < 3) {
                    const style = doc.defaultView.getComputedStyle(card);
                    components.cards.push({
                        background: style.backgroundColor,
                        border: style.border,
                        borderRadius: style.borderRadius,
                        boxShadow: style.boxShadow,
                        padding: style.padding
                    });
                }
            });
            
            return components;
        },
        
        // יצירת פרופיל Effi-UI מהתבנית
        createEffiProfile: function(template) {
            const profile = {
                name: 'custom-extracted',
                displayName: 'תבנית מותאמת אישית',
                colors: {
                    primary: template.colors.primary || '#667eea',
                    secondary: template.colors.secondary || '#764ba2',
                    success: template.colors.accents[0] || '#4caf50',
                    danger: template.colors.accents[1] || '#f44336',
                    warning: template.colors.accents[2] || '#ff9800',
                    info: template.colors.accents[3] || '#2196f3',
                    light: template.colors.background || '#f5f5f5',
                    dark: template.colors.text || '#212121'
                },
                fonts: template.fonts,
                spacing: template.spacing,
                buttons: template.buttons,
                effects: []
            };
            
            // שמור בהגדרות Effi-UI
            if (window.EffiUI) {
                window.EffiUI.colorSchemes['custom-extracted'] = profile.colors;
                window.EffiUI.config.profiles['custom-extracted'] = profile;
                window.EffiUI.saveConfig();
                
                // החל את הפרופיל
                window.EffiUI.applyProfile('custom-extracted');
                
                console.log('✅ Template extracted and applied!');
                this.showSuccessMessage();
            }
            
            return profile;
        },
        
        // הצגת הודעת הצלחה
        showSuccessMessage: function() {
            const message = document.createElement('div');
            message.style.cssText = `
                position: fixed;
                top: 20px;
                left: 50%;
                transform: translateX(-50%);
                background: #4caf50;
                color: white;
                padding: 20px 40px;
                border-radius: 10px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.3);
                z-index: 10000;
                font-size: 18px;
                animation: slideDown 0.5s ease-out;
            `;
            message.innerHTML = `
                <h3 style="margin: 0 0 10px 0;">✅ תבנית הוחלה בהצלחה!</h3>
                <p style="margin: 0;">הפרופיל "תבנית מותאמת אישית" נוצר והוחל על האתר</p>
            `;
            
            document.body.appendChild(message);
            
            setTimeout(() => {
                message.style.animation = 'slideUp 0.5s ease-out';
                setTimeout(() => message.remove(), 500);
            }, 5000);
        },
        
        // ממשק משתמש לחילוץ
        showExtractorUI: function() {
            const ui = document.createElement('div');
            ui.id = 'effi-template-extractor-ui';
            ui.style.cssText = `
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: white;
                padding: 30px;
                border-radius: 15px;
                box-shadow: 0 10px 50px rgba(0,0,0,0.3);
                z-index: 10001;
                max-width: 500px;
                direction: rtl;
            `;
            
            ui.innerHTML = `
                <h2 style="margin: 0 0 20px 0; color: #333;">🎨 חילוץ תבנית מדף דוגמה</h2>
                <p style="color: #666; margin-bottom: 20px;">
                    הכנס כתובת של דף שאתה אוהב את העיצוב שלו, והמערכת תחלץ ממנו את כל האלמנטים ותיצור פרופיל מותאם אישית ב-Effi-UI
                </p>
                
                <input type="url" id="template-url" placeholder="https://example.com" style="
                    width: 100%;
                    padding: 15px;
                    border: 2px solid #ddd;
                    border-radius: 8px;
                    font-size: 16px;
                    margin-bottom: 20px;
                    box-sizing: border-box;
                ">
                
                <div style="display: flex; gap: 10px;">
                    <button onclick="EffiTemplateExtractor.extract()" style="
                        flex: 1;
                        background: #667eea;
                        color: white;
                        border: none;
                        padding: 15px;
                        border-radius: 8px;
                        font-size: 16px;
                        cursor: pointer;
                    ">חלץ והחל תבנית</button>
                    
                    <button onclick="document.getElementById('effi-template-extractor-ui').remove()" style="
                        background: #e0e0e0;
                        color: #333;
                        border: none;
                        padding: 15px 30px;
                        border-radius: 8px;
                        font-size: 16px;
                        cursor: pointer;
                    ">ביטול</button>
                </div>
                
                <div id="extract-status" style="margin-top: 20px; display: none;">
                    <div style="
                        background: #f0f0f0;
                        padding: 15px;
                        border-radius: 8px;
                        text-align: center;
                    ">
                        <div class="spinner" style="
                            border: 3px solid #f3f3f3;
                            border-top: 3px solid #667eea;
                            border-radius: 50%;
                            width: 30px;
                            height: 30px;
                            animation: spin 1s linear infinite;
                            margin: 0 auto 10px;
                        "></div>
                        <p style="margin: 0;">מחלץ תבנית...</p>
                    </div>
                </div>
                
                <style>
                    @keyframes spin {
                        0% { transform: rotate(0deg); }
                        100% { transform: rotate(360deg); }
                    }
                </style>
            `;
            
            document.body.appendChild(ui);
        },
        
        // חילוץ מהממשק
        extract: function() {
            const url = document.getElementById('template-url').value;
            if (!url) {
                alert('אנא הכנס כתובת URL');
                return;
            }
            
            // הצג סטטוס
            document.getElementById('extract-status').style.display = 'block';
            
            // חלץ תבנית
            this.extractFromPage(url, (template) => {
                // הסר את הממשק
                document.getElementById('effi-template-extractor-ui').remove();
                
                console.log('Extracted template:', template);
            });
        },
        
        // חילוץ מהדף הנוכחי
        extractFromCurrentPage: function() {
            console.log('🎨 Extracting from current page...');
            
            const template = {
                colors: this.extractColors(document),
                fonts: this.extractFonts(document),
                spacing: this.extractSpacing(document),
                buttons: this.extractButtons(document),
                backgrounds: this.extractBackgrounds(document),
                animations: this.extractAnimations(document),
                layout: this.extractLayout(document),
                components: this.extractComponents(document)
            };
            
            this.extractedTemplate = template;
            this.createEffiProfile(template);
            
            return template;
        }
    };
    
    // חשוף למערכת
    window.EffiTemplateExtractor = EffiTemplateExtractor;
    
    // הוסף כפתור לפאנל של Effi-UI
    if (window.EffiUI) {
        // הוסף כפתור בהגדרות
        const addExtractorButton = setInterval(() => {
            const settingsTab = document.getElementById('effi-settings-tab');
            if (settingsTab && !document.getElementById('template-extractor-btn')) {
                const button = document.createElement('button');
                button.id = 'template-extractor-btn';
                button.className = 'effi-action-btn';
                button.innerHTML = '🎨 חלץ תבנית מדף דוגמה';
                button.onclick = () => EffiTemplateExtractor.showExtractorUI();
                
                const section = settingsTab.querySelector('.effi-subsection');
                if (section) {
                    section.appendChild(button);
                    clearInterval(addExtractorButton);
                }
            }
        }, 1000);
    }
    
})();

// הוסף גם פונקציה גלובלית לשימוש מהיר
window.extractTemplateFromPage = function(url) {
    if (!url) {
        EffiTemplateExtractor.extractFromCurrentPage();
    } else {
        EffiTemplateExtractor.extractFromPage(url);
    }
};