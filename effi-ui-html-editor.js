// Effi-UI HTML Editor Module - מודול עריכת דפי HTML
// מרחיב את מערכת Effi-UI עם יכולות יצירה ועריכת דפי HTML מלאות

(function(window) {
    'use strict';

    // המודול הראשי
    const EffiHTMLEditor = {
        version: '1.0.0',
        currentPage: null,
        pages: {},
        selectedElement: null,
        history: [],
        historyIndex: -1,
        
        // אתחול המודול
        init: function() {
            console.log('🚀 Effi HTML Editor initialized');
            this.loadPages();
            this.createEditorUI();
            this.bindEvents();
            this.initDragDrop();
            this.initKeyboardShortcuts();
            
            // שילוב עם Effi-UI הקיים
            if (window.EffiUI) {
                window.EffiUI.htmlEditor = this;
                console.log('✅ Integrated with Effi-UI Engine');
            }
        },

        // יצירת ממשק העורך
        createEditorUI: function() {
            const editorHTML = `
                <div id="effi-html-editor" class="effi-html-editor" dir="rtl">
                    <!-- סרגל כלים עליון -->
                    <div class="editor-toolbar">
                        <div class="toolbar-section">
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.newPage()">
                                <i class="icon-new"></i> דף חדש
                            </button>
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.savePage()">
                                <i class="icon-save"></i> שמור
                            </button>
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.loadPageDialog()">
                                <i class="icon-open"></i> פתח
                            </button>
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.exportHTML()">
                                <i class="icon-export"></i> ייצא HTML
                            </button>
                        </div>
                        
                        <div class="toolbar-section">
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.undo()">
                                <i class="icon-undo"></i> בטל
                            </button>
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.redo()">
                                <i class="icon-redo"></i> חזור
                            </button>
                            <button class="toolbar-btn" onclick="EffiHTMLEditor.previewMode()">
                                <i class="icon-preview"></i> תצוגה מקדימה
                            </button>
                        </div>
                        
                        <div class="toolbar-section">
                            <select id="device-selector" onchange="EffiHTMLEditor.changeDevice(this.value)">
                                <option value="desktop">🖥️ מחשב</option>
                                <option value="tablet">📱 טאבלט</option>
                                <option value="mobile">📱 מובייל</option>
                            </select>
                        </div>
                    </div>

                    <!-- אזור עבודה ראשי -->
                    <div class="editor-workspace">
                        <!-- פאנל רכיבים -->
                        <div class="components-panel">
                            <h3>רכיבי HTML</h3>
                            
                            <!-- רכיבי בסיס -->
                            <div class="component-group">
                                <h4>רכיבי בסיס</h4>
                                <div class="component-item" draggable="true" data-component="heading">
                                    <i class="icon-heading"></i> כותרת
                                </div>
                                <div class="component-item" draggable="true" data-component="paragraph">
                                    <i class="icon-text"></i> פסקה
                                </div>
                                <div class="component-item" draggable="true" data-component="image">
                                    <i class="icon-image"></i> תמונה
                                </div>
                                <div class="component-item" draggable="true" data-component="button">
                                    <i class="icon-button"></i> כפתור
                                </div>
                                <div class="component-item" draggable="true" data-component="link">
                                    <i class="icon-link"></i> קישור
                                </div>
                                <div class="component-item" draggable="true" data-component="divider">
                                    <i class="icon-divider"></i> קו מפריד
                                </div>
                            </div>

                            <!-- רכיבי פריסה -->
                            <div class="component-group">
                                <h4>פריסה</h4>
                                <div class="component-item" draggable="true" data-component="container">
                                    <i class="icon-container"></i> מיכל
                                </div>
                                <div class="component-item" draggable="true" data-component="columns">
                                    <i class="icon-columns"></i> עמודות
                                </div>
                                <div class="component-item" draggable="true" data-component="grid">
                                    <i class="icon-grid"></i> רשת
                                </div>
                                <div class="component-item" draggable="true" data-component="section">
                                    <i class="icon-section"></i> אזור
                                </div>
                            </div>

                            <!-- רכיבי טפסים -->
                            <div class="component-group">
                                <h4>טפסים</h4>
                                <div class="component-item" draggable="true" data-component="form">
                                    <i class="icon-form"></i> טופס
                                </div>
                                <div class="component-item" draggable="true" data-component="input">
                                    <i class="icon-input"></i> שדה טקסט
                                </div>
                                <div class="component-item" draggable="true" data-component="textarea">
                                    <i class="icon-textarea"></i> אזור טקסט
                                </div>
                                <div class="component-item" draggable="true" data-component="select">
                                    <i class="icon-select"></i> רשימה נפתחת
                                </div>
                                <div class="component-item" draggable="true" data-component="checkbox">
                                    <i class="icon-checkbox"></i> תיבת סימון
                                </div>
                                <div class="component-item" draggable="true" data-component="radio">
                                    <i class="icon-radio"></i> כפתור רדיו
                                </div>
                            </div>

                            <!-- רכיבים מתקדמים -->
                            <div class="component-group">
                                <h4>רכיבים מתקדמים</h4>
                                <div class="component-item" draggable="true" data-component="video">
                                    <i class="icon-video"></i> וידאו
                                </div>
                                <div class="component-item" draggable="true" data-component="map">
                                    <i class="icon-map"></i> מפה
                                </div>
                                <div class="component-item" draggable="true" data-component="carousel">
                                    <i class="icon-carousel"></i> קרוסלה
                                </div>
                                <div class="component-item" draggable="true" data-component="accordion">
                                    <i class="icon-accordion"></i> אקורדיון
                                </div>
                                <div class="component-item" draggable="true" data-component="tabs">
                                    <i class="icon-tabs"></i> טאבים
                                </div>
                                <div class="component-item" draggable="true" data-component="modal">
                                    <i class="icon-modal"></i> חלון קופץ
                                </div>
                            </div>

                            <!-- תבניות מוכנות -->
                            <div class="component-group">
                                <h4>תבניות</h4>
                                <div class="component-item" draggable="true" data-component="header-template">
                                    <i class="icon-template"></i> כותרת אתר
                                </div>
                                <div class="component-item" draggable="true" data-component="hero-template">
                                    <i class="icon-template"></i> Hero Section
                                </div>
                                <div class="component-item" draggable="true" data-component="footer-template">
                                    <i class="icon-template"></i> כותרת תחתונה
                                </div>
                                <div class="component-item" draggable="true" data-component="contact-template">
                                    <i class="icon-template"></i> טופס יצירת קשר
                                </div>
                            </div>
                        </div>

                        <!-- אזור העריכה -->
                        <div class="editor-canvas">
                            <div class="canvas-toolbar">
                                <button onclick="EffiHTMLEditor.zoomIn()">🔍+</button>
                                <span id="zoom-level">100%</span>
                                <button onclick="EffiHTMLEditor.zoomOut()">🔍-</button>
                                <button onclick="EffiHTMLEditor.toggleGrid()">⊞ רשת</button>
                                <button onclick="EffiHTMLEditor.toggleRulers()">📏 סרגלים</button>
                            </div>
                            
                            <div id="editor-frame" class="editor-frame">
                                <iframe id="page-iframe" src="about:blank"></iframe>
                            </div>
                        </div>

                        <!-- פאנל מאפיינים -->
                        <div class="properties-panel">
                            <h3>מאפיינים</h3>
                            <div id="properties-content">
                                <p class="empty-state">בחר אלמנט לעריכה</p>
                            </div>
                        </div>
                    </div>

                    <!-- שורת סטטוס -->
                    <div class="status-bar">
                        <span id="element-path">בחר אלמנט</span>
                        <span id="page-info">דף חדש</span>
                        <span id="coordinates">X: 0, Y: 0</span>
                    </div>
                </div>
            `;

            // הוספת העורך לדף
            document.body.insertAdjacentHTML('beforeend', editorHTML);
            
            // טעינת הסגנונות
            this.injectStyles();
        },

        // הזרקת סגנונות CSS
        injectStyles: function() {
            const styles = `
                /* Effi HTML Editor Styles */
                .effi-html-editor {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: #1a1a1a;
                    color: #fff;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    z-index: 10000;
                    display: none;
                }

                .effi-html-editor.active {
                    display: flex;
                    flex-direction: column;
                }

                /* סרגל כלים */
                .editor-toolbar {
                    background: #2d2d2d;
                    padding: 10px;
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    border-bottom: 1px solid #444;
                }

                .toolbar-section {
                    display: flex;
                    gap: 5px;
                }

                .toolbar-btn {
                    background: #3d3d3d;
                    color: #fff;
                    border: none;
                    padding: 8px 16px;
                    border-radius: 4px;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    gap: 5px;
                    transition: all 0.3s;
                }

                .toolbar-btn:hover {
                    background: #4d4d4d;
                    transform: translateY(-1px);
                }

                /* אזור עבודה */
                .editor-workspace {
                    flex: 1;
                    display: flex;
                    overflow: hidden;
                }

                /* פאנל רכיבים */
                .components-panel {
                    width: 250px;
                    background: #2d2d2d;
                    padding: 20px;
                    overflow-y: auto;
                    border-left: 1px solid #444;
                }

                .component-group {
                    margin-bottom: 20px;
                }

                .component-group h4 {
                    color: #667eea;
                    margin-bottom: 10px;
                    font-size: 14px;
                }

                .component-item {
                    background: #3d3d3d;
                    padding: 10px;
                    margin-bottom: 5px;
                    border-radius: 4px;
                    cursor: move;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    transition: all 0.3s;
                }

                .component-item:hover {
                    background: #4d4d4d;
                    transform: translateX(-5px);
                }

                .component-item.dragging {
                    opacity: 0.5;
                }

                /* אזור העריכה */
                .editor-canvas {
                    flex: 1;
                    background: #222;
                    position: relative;
                    overflow: hidden;
                }

                .canvas-toolbar {
                    position: absolute;
                    top: 10px;
                    left: 50%;
                    transform: translateX(-50%);
                    background: rgba(0,0,0,0.8);
                    padding: 5px 10px;
                    border-radius: 20px;
                    display: flex;
                    gap: 10px;
                    align-items: center;
                    z-index: 10;
                }

                .canvas-toolbar button {
                    background: transparent;
                    color: #fff;
                    border: none;
                    padding: 5px 10px;
                    cursor: pointer;
                    border-radius: 4px;
                }

                .canvas-toolbar button:hover {
                    background: rgba(255,255,255,0.1);
                }

                .editor-frame {
                    width: 100%;
                    height: 100%;
                    padding: 40px;
                    box-sizing: border-box;
                }

                #page-iframe {
                    width: 100%;
                    height: 100%;
                    border: none;
                    background: #fff;
                    box-shadow: 0 10px 50px rgba(0,0,0,0.5);
                    border-radius: 8px;
                    transition: all 0.3s;
                }

                /* פאנל מאפיינים */
                .properties-panel {
                    width: 300px;
                    background: #2d2d2d;
                    padding: 20px;
                    overflow-y: auto;
                    border-right: 1px solid #444;
                }

                .property-group {
                    margin-bottom: 20px;
                    border-bottom: 1px solid #444;
                    padding-bottom: 20px;
                }

                .property-group h4 {
                    color: #667eea;
                    margin-bottom: 10px;
                    font-size: 14px;
                }

                .property-field {
                    margin-bottom: 15px;
                }

                .property-field label {
                    display: block;
                    margin-bottom: 5px;
                    font-size: 12px;
                    color: #aaa;
                }

                .property-field input,
                .property-field select,
                .property-field textarea {
                    width: 100%;
                    background: #3d3d3d;
                    color: #fff;
                    border: 1px solid #555;
                    padding: 8px;
                    border-radius: 4px;
                }

                .property-field input[type="color"] {
                    height: 40px;
                    cursor: pointer;
                }

                .property-field input[type="range"] {
                    margin-top: 5px;
                }

                /* שורת סטטוס */
                .status-bar {
                    background: #2d2d2d;
                    padding: 8px 20px;
                    border-top: 1px solid #444;
                    display: flex;
                    justify-content: space-between;
                    font-size: 12px;
                    color: #aaa;
                }

                /* אנימציות */
                @keyframes slideIn {
                    from {
                        transform: translateY(100%);
                        opacity: 0;
                    }
                    to {
                        transform: translateY(0);
                        opacity: 1;
                    }
                }

                .effi-html-editor.active {
                    animation: slideIn 0.3s ease-out;
                }

                /* רספונסיב */
                @media (max-width: 768px) {
                    .components-panel,
                    .properties-panel {
                        position: absolute;
                        height: 100%;
                        transform: translateX(-100%);
                        transition: transform 0.3s;
                        z-index: 20;
                    }

                    .components-panel.active,
                    .properties-panel.active {
                        transform: translateX(0);
                    }

                    .properties-panel {
                        right: 0;
                        left: auto;
                        transform: translateX(100%);
                    }
                }

                /* אלמנט נבחר */
                .selected-element {
                    outline: 2px solid #667eea !important;
                    position: relative;
                }

                .selected-element::before {
                    content: attr(data-element-type);
                    position: absolute;
                    top: -25px;
                    left: 0;
                    background: #667eea;
                    color: #fff;
                    padding: 2px 8px;
                    font-size: 11px;
                    border-radius: 3px;
                }

                /* אזור גרירה */
                .drop-zone {
                    border: 2px dashed #667eea;
                    background: rgba(102, 126, 234, 0.1);
                    min-height: 50px;
                    margin: 10px;
                    border-radius: 4px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #667eea;
                }

                .drop-zone.drag-over {
                    background: rgba(102, 126, 234, 0.2);
                    border-color: #764ba2;
                }

                /* כפתור פתיחת עורך */
                .open-html-editor {
                    position: fixed;
                    bottom: 80px;
                    left: 20px;
                    background: #667eea;
                    color: #fff;
                    border: none;
                    width: 60px;
                    height: 60px;
                    border-radius: 50%;
                    font-size: 24px;
                    cursor: pointer;
                    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
                    z-index: 9999;
                    transition: all 0.3s;
                }

                .open-html-editor:hover {
                    transform: scale(1.1);
                    box-shadow: 0 6px 30px rgba(102, 126, 234, 0.6);
                }
            `;

            const styleSheet = document.createElement('style');
            styleSheet.textContent = styles;
            document.head.appendChild(styleSheet);
        },

        // יצירת דף חדש
        newPage: function() {
            const pageName = prompt('שם הדף החדש:') || 'untitled';
            const pageId = 'page_' + Date.now();
            
            const newPage = {
                id: pageId,
                name: pageName,
                html: `<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageName}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            direction: rtl;
        }
        .drop-zone {
            min-height: 100px;
            border: 2px dashed #ccc;
            margin: 20px;
            padding: 20px;
            text-align: center;
            color: #999;
        }
        .drop-zone.drag-over {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.1);
        }
    </style>
</head>
<body>
    <div class="drop-zone" data-zone="main">
        גרור רכיבים לכאן
    </div>
</body>
</html>`,
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            };

            this.pages[pageId] = newPage;
            this.currentPage = pageId;
            this.loadPageInEditor(newPage);
            this.saveToHistory();
            
            this.showNotification('דף חדש נוצר בהצלחה', 'success');
        },

        // טעינת דף בעורך
        loadPageInEditor: function(page) {
            const iframe = document.getElementById('page-iframe');
            const doc = iframe.contentDocument || iframe.contentWindow.document;
            
            doc.open();
            doc.write(page.html);
            doc.close();
            
            // הוספת אירועי עריכה
            this.attachEditorEvents(doc);
            
            // עדכון שורת סטטוס
            document.getElementById('page-info').textContent = page.name;
        },

        // חיבור אירועי עריכה
        attachEditorEvents: function(doc) {
            const self = this;
            
            // אירועי לחיצה על אלמנטים
            doc.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                if (e.target.classList.contains('drop-zone')) return;
                
                self.selectElement(e.target);
            });

            // אירועי גרירה
            doc.addEventListener('dragover', function(e) {
                e.preventDefault();
                const dropZone = e.target.closest('.drop-zone');
                if (dropZone) {
                    dropZone.classList.add('drag-over');
                }
            });

            doc.addEventListener('dragleave', function(e) {
                const dropZone = e.target.closest('.drop-zone');
                if (dropZone) {
                    dropZone.classList.remove('drag-over');
                }
            });

            doc.addEventListener('drop', function(e) {
                e.preventDefault();
                const dropZone = e.target.closest('.drop-zone');
                if (dropZone) {
                    dropZone.classList.remove('drag-over');
                    const componentType = e.dataTransfer.getData('component-type');
                    if (componentType) {
                        self.addComponent(componentType, dropZone);
                    }
                }
            });

            // עריכה ישירה של טקסט
            doc.addEventListener('dblclick', function(e) {
                if (e.target.tagName === 'P' || 
                    e.target.tagName === 'H1' || 
                    e.target.tagName === 'H2' || 
                    e.target.tagName === 'H3' || 
                    e.target.tagName === 'SPAN' || 
                    e.target.tagName === 'DIV') {
                    e.target.contentEditable = true;
                    e.target.focus();
                    
                    e.target.addEventListener('blur', function() {
                        this.contentEditable = false;
                        self.saveToHistory();
                    });
                }
            });
        },

        // בחירת אלמנט
        selectElement: function(element) {
            // הסרת בחירה קודמת
            const iframe = document.getElementById('page-iframe');
            const doc = iframe.contentDocument;
            doc.querySelectorAll('.selected-element').forEach(el => {
                el.classList.remove('selected-element');
            });
            
            // הוספת בחירה חדשה
            element.classList.add('selected-element');
            element.setAttribute('data-element-type', element.tagName.toLowerCase());
            this.selectedElement = element;
            
            // עדכון פאנל מאפיינים
            this.updatePropertiesPanel(element);
            
            // עדכון נתיב אלמנט
            this.updateElementPath(element);
        },

        // עדכון פאנל מאפיינים
        updatePropertiesPanel: function(element) {
            const panel = document.getElementById('properties-content');
            
            let propertiesHTML = `
                <div class="property-group">
                    <h4>כללי</h4>
                    <div class="property-field">
                        <label>סוג אלמנט</label>
                        <input type="text" value="${element.tagName.toLowerCase()}" readonly>
                    </div>
                    <div class="property-field">
                        <label>ID</label>
                        <input type="text" id="prop-id" value="${element.id || ''}" 
                               onchange="EffiHTMLEditor.updateProperty('id', this.value)">
                    </div>
                    <div class="property-field">
                        <label>Class</label>
                        <input type="text" id="prop-class" value="${element.className || ''}" 
                               onchange="EffiHTMLEditor.updateProperty('className', this.value)">
                    </div>
                </div>

                <div class="property-group">
                    <h4>עיצוב</h4>
                    <div class="property-field">
                        <label>צבע רקע</label>
                        <input type="color" id="prop-bg-color" 
                               value="${this.rgbToHex(element.style.backgroundColor) || '#ffffff'}"
                               onchange="EffiHTMLEditor.updateStyle('backgroundColor', this.value)">
                    </div>
                    <div class="property-field">
                        <label>צבע טקסט</label>
                        <input type="color" id="prop-color" 
                               value="${this.rgbToHex(element.style.color) || '#000000'}"
                               onchange="EffiHTMLEditor.updateStyle('color', this.value)">
                    </div>
                    <div class="property-field">
                        <label>גודל פונט</label>
                        <input type="range" id="prop-font-size" min="10" max="72" 
                               value="${parseInt(element.style.fontSize) || 16}"
                               onchange="EffiHTMLEditor.updateStyle('fontSize', this.value + 'px')">
                        <span>${parseInt(element.style.fontSize) || 16}px</span>
                    </div>
                    <div class="property-field">
                        <label>משקל פונט</label>
                        <select id="prop-font-weight" 
                                onchange="EffiHTMLEditor.updateStyle('fontWeight', this.value)">
                            <option value="normal">רגיל</option>
                            <option value="bold">מודגש</option>
                            <option value="lighter">בהיר</option>
                        </select>
                    </div>
                </div>

                <div class="property-group">
                    <h4>מרווחים</h4>
                    <div class="property-field">
                        <label>Padding</label>
                        <input type="range" min="0" max="50" 
                               value="${parseInt(element.style.padding) || 0}"
                               onchange="EffiHTMLEditor.updateStyle('padding', this.value + 'px')">
                    </div>
                    <div class="property-field">
                        <label>Margin</label>
                        <input type="range" min="0" max="50" 
                               value="${parseInt(element.style.margin) || 0}"
                               onchange="EffiHTMLEditor.updateStyle('margin', this.value + 'px')">
                    </div>
                </div>

                <div class="property-group">
                    <h4>גבולות</h4>
                    <div class="property-field">
                        <label>עובי גבול</label>
                        <input type="range" min="0" max="10" 
                               value="${parseInt(element.style.borderWidth) || 0}"
                               onchange="EffiHTMLEditor.updateBorder()">
                    </div>
                    <div class="property-field">
                        <label>צבע גבול</label>
                        <input type="color" id="prop-border-color" 
                               value="${this.rgbToHex(element.style.borderColor) || '#000000'}"
                               onchange="EffiHTMLEditor.updateBorder()">
                    </div>
                    <div class="property-field">
                        <label>רדיוס פינות</label>
                        <input type="range" min="0" max="50" 
                               value="${parseInt(element.style.borderRadius) || 0}"
                               onchange="EffiHTMLEditor.updateStyle('borderRadius', this.value + 'px')">
                    </div>
                </div>

                <div class="property-group">
                    <h4>פעולות</h4>
                    <button class="toolbar-btn" onclick="EffiHTMLEditor.duplicateElement()">
                        שכפל אלמנט
                    </button>
                    <button class="toolbar-btn" onclick="EffiHTMLEditor.deleteElement()">
                        מחק אלמנט
                    </button>
                </div>
            `;

            panel.innerHTML = propertiesHTML;
        },

        // הוספת רכיב חדש
        addComponent: function(type, dropZone) {
            let newElement = '';
            
            switch(type) {
                case 'heading':
                    newElement = '<h2>כותרת חדשה</h2>';
                    break;
                case 'paragraph':
                    newElement = '<p>טקסט חדש. לחץ פעמיים לעריכה.</p>';
                    break;
                case 'image':
                    const imgUrl = prompt('כתובת התמונה:') || 'https://via.placeholder.com/300x200';
                    newElement = `<img src="${imgUrl}" alt="תמונה" style="max-width: 100%;">`;
                    break;
                case 'button':
                    newElement = '<button class="effi-btn">כפתור חדש</button>';
                    break;
                case 'link':
                    newElement = '<a href="#" style="color: #667eea;">קישור חדש</a>';
                    break;
                case 'divider':
                    newElement = '<hr style="margin: 20px 0;">';
                    break;
                case 'container':
                    newElement = `<div class="container" style="padding: 20px; background: #f5f5f5;">
                        <div class="drop-zone" data-zone="container">גרור רכיבים לכאן</div>
                    </div>`;
                    break;
                case 'columns':
                    newElement = `<div class="columns" style="display: flex; gap: 20px;">
                        <div class="column" style="flex: 1;">
                            <div class="drop-zone" data-zone="col1">עמודה 1</div>
                        </div>
                        <div class="column" style="flex: 1;">
                            <div class="drop-zone" data-zone="col2">עמודה 2</div>
                        </div>
                    </div>`;
                    break;
                case 'form':
                    newElement = `<form style="padding: 20px; background: #f9f9f9; border-radius: 8px;">
                        <h3>טופס יצירת קשר</h3>
                        <div class="drop-zone" data-zone="form">גרור שדות טופס לכאן</div>
                        <button type="submit" class="effi-btn">שלח</button>
                    </form>`;
                    break;
                case 'input':
                    newElement = `<div class="form-field" style="margin-bottom: 15px;">
                        <label>שם השדה</label>
                        <input type="text" placeholder="הכנס טקסט" style="width: 100%; padding: 8px;">
                    </div>`;
                    break;
                case 'video':
                    const videoUrl = prompt('כתובת הסרטון (YouTube/Vimeo):') || '';
                    newElement = `<div class="video-wrapper" style="position: relative; padding-bottom: 56.25%; height: 0;">
                        <iframe src="${videoUrl}" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" frameborder="0" allowfullscreen></iframe>
                    </div>`;
                    break;
                case 'header-template':
                    newElement = `<header style="background: #333; color: #fff; padding: 20px;">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <h1>לוגו האתר</h1>
                            <nav>
                                <a href="#" style="color: #fff; margin: 0 15px;">דף הבית</a>
                                <a href="#" style="color: #fff; margin: 0 15px;">אודות</a>
                                <a href="#" style="color: #fff; margin: 0 15px;">שירותים</a>
                                <a href="#" style="color: #fff; margin: 0 15px;">צור קשר</a>
                            </nav>
                        </div>
                    </header>`;
                    break;
                case 'hero-template':
                    newElement = `<section style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 80px 20px; text-align: center;">
                        <h1 style="font-size: 48px; margin-bottom: 20px;">ברוכים הבאים לאתר שלנו</h1>
                        <p style="font-size: 24px; margin-bottom: 30px;">תיאור קצר ומרשים על השירות שלכם</p>
                        <button class="effi-btn" style="font-size: 18px; padding: 15px 30px;">התחל עכשיו</button>
                    </section>`;
                    break;
            }

            // הכנסת האלמנט
            if (dropZone.innerHTML.includes('גרור רכיבים לכאן')) {
                dropZone.innerHTML = newElement;
            } else {
                dropZone.insertAdjacentHTML('beforeend', newElement);
            }

            // חיבור אירועים לאלמנטים החדשים
            const iframe = document.getElementById('page-iframe');
            const doc = iframe.contentDocument;
            this.attachEditorEvents(doc);
            
            this.saveToHistory();
            this.showNotification('רכיב נוסף בהצלחה', 'success');
        },

        // עדכון תכונה
        updateProperty: function(property, value) {
            if (this.selectedElement) {
                this.selectedElement[property] = value;
                this.saveToHistory();
            }
        },

        // עדכון סגנון
        updateStyle: function(property, value) {
            if (this.selectedElement) {
                this.selectedElement.style[property] = value;
                this.saveToHistory();
            }
        },

        // עדכון גבול
        updateBorder: function() {
            if (this.selectedElement) {
                const width = document.querySelector('[onchange*="updateBorder"]').value;
                const color = document.getElementById('prop-border-color').value;
                this.selectedElement.style.border = `${width}px solid ${color}`;
                this.saveToHistory();
            }
        },

        // שכפול אלמנט
        duplicateElement: function() {
            if (this.selectedElement) {
                const clone = this.selectedElement.cloneNode(true);
                clone.classList.remove('selected-element');
                this.selectedElement.parentNode.insertBefore(clone, this.selectedElement.nextSibling);
                this.saveToHistory();
                this.showNotification('אלמנט שוכפל', 'success');
            }
        },

        // מחיקת אלמנט
        deleteElement: function() {
            if (this.selectedElement && confirm('האם למחוק את האלמנט?')) {
                this.selectedElement.remove();
                this.selectedElement = null;
                document.getElementById('properties-content').innerHTML = '<p class="empty-state">בחר אלמנט לעריכה</p>';
                this.saveToHistory();
                this.showNotification('אלמנט נמחק', 'info');
            }
        },

        // שמירת דף
        savePage: function() {
            if (this.currentPage) {
                const iframe = document.getElementById('page-iframe');
                const doc = iframe.contentDocument;
                
                // הסרת סימונים זמניים
                doc.querySelectorAll('.selected-element').forEach(el => {
                    el.classList.remove('selected-element');
                    el.removeAttribute('data-element-type');
                });
                
                this.pages[this.currentPage].html = doc.documentElement.outerHTML;
                this.pages[this.currentPage].modified = new Date().toISOString();
                
                // שמירה ב-localStorage
                localStorage.setItem('effi_html_pages', JSON.stringify(this.pages));
                
                this.showNotification('הדף נשמר בהצלחה', 'success');
            }
        },

        // ייצוא HTML
        exportHTML: function() {
            if (this.currentPage) {
                const page = this.pages[this.currentPage];
                const blob = new Blob([page.html], { type: 'text/html' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = page.name + '.html';
                a.click();
                URL.revokeObjectURL(url);
                
                this.showNotification('הדף יוצא בהצלחה', 'success');
            }
        },

        // מצב תצוגה מקדימה
        previewMode: function() {
            const editor = document.getElementById('effi-html-editor');
            const newWindow = window.open('', '_blank');
            
            if (this.currentPage) {
                const page = this.pages[this.currentPage];
                newWindow.document.write(page.html);
                newWindow.document.close();
            }
        },

        // שינוי מכשיר
        changeDevice: function(device) {
            const iframe = document.getElementById('page-iframe');
            
            switch(device) {
                case 'desktop':
                    iframe.style.width = '100%';
                    iframe.style.height = '100%';
                    break;
                case 'tablet':
                    iframe.style.width = '768px';
                    iframe.style.height = '1024px';
                    break;
                case 'mobile':
                    iframe.style.width = '375px';
                    iframe.style.height = '667px';
                    break;
            }
        },

        // הגדלה/הקטנה
        zoomLevel: 100,
        zoomIn: function() {
            this.zoomLevel += 10;
            this.updateZoom();
        },
        zoomOut: function() {
            this.zoomLevel -= 10;
            this.updateZoom();
        },
        updateZoom: function() {
            const iframe = document.getElementById('page-iframe');
            iframe.style.transform = `scale(${this.zoomLevel / 100})`;
            document.getElementById('zoom-level').textContent = this.zoomLevel + '%';
        },

        // שמירה להיסטוריה
        saveToHistory: function() {
            if (this.currentPage) {
                const iframe = document.getElementById('page-iframe');
                const doc = iframe.contentDocument;
                const state = doc.documentElement.outerHTML;
                
                // חיתוך היסטוריה במקרה של undo/redo
                this.history = this.history.slice(0, this.historyIndex + 1);
                
                this.history.push(state);
                this.historyIndex++;
                
                // הגבלת גודל היסטוריה
                if (this.history.length > 50) {
                    this.history.shift();
                    this.historyIndex--;
                }
            }
        },

        // ביטול פעולה
        undo: function() {
            if (this.historyIndex > 0) {
                this.historyIndex--;
                const iframe = document.getElementById('page-iframe');
                const doc = iframe.contentDocument;
                doc.open();
                doc.write(this.history[this.historyIndex]);
                doc.close();
                this.attachEditorEvents(doc);
            }
        },

        // חזרה על פעולה
        redo: function() {
            if (this.historyIndex < this.history.length - 1) {
                this.historyIndex++;
                const iframe = document.getElementById('page-iframe');
                const doc = iframe.contentDocument;
                doc.open();
                doc.write(this.history[this.historyIndex]);
                doc.close();
                this.attachEditorEvents(doc);
            }
        },

        // הצגת התראה
        showNotification: function(message, type = 'info') {
            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            notification.textContent = message;
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                left: 50%;
                transform: translateX(-50%);
                background: ${type === 'success' ? '#4caf50' : type === 'error' ? '#f44336' : '#2196f3'};
                color: white;
                padding: 15px 30px;
                border-radius: 4px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                z-index: 10001;
                animation: slideDown 0.3s ease-out;
            `;
            
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.animation = 'slideUp 0.3s ease-out';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        },

        // עזרים
        rgbToHex: function(rgb) {
            if (!rgb) return '';
            const match = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
            if (!match) return rgb;
            
            function hex(x) {
                return ("0" + parseInt(x).toString(16)).slice(-2);
            }
            return "#" + hex(match[1]) + hex(match[2]) + hex(match[3]);
        },

        updateElementPath: function(element) {
            let path = [];
            let current = element;
            
            while (current && current.tagName) {
                let selector = current.tagName.toLowerCase();
                if (current.id) selector += '#' + current.id;
                if (current.className) selector += '.' + current.className.split(' ').join('.');
                path.unshift(selector);
                current = current.parentElement;
            }
            
            document.getElementById('element-path').textContent = path.join(' > ');
        },

        // טעינת דפים
        loadPages: function() {
            const saved = localStorage.getItem('effi_html_pages');
            if (saved) {
                this.pages = JSON.parse(saved);
            }
        },

        // דיאלוג טעינת דף
        loadPageDialog: function() {
            const pageList = Object.values(this.pages).map(page => 
                `${page.name} (${new Date(page.modified).toLocaleDateString('he-IL')})`
            ).join('\n');
            
            const selected = prompt('בחר דף לטעינה:\n' + pageList);
            if (selected) {
                const page = Object.values(this.pages).find(p => p.name === selected.split(' ')[0]);
                if (page) {
                    this.currentPage = page.id;
                    this.loadPageInEditor(page);
                }
            }
        },

        // אתחול גרירה ושחרור
        initDragDrop: function() {
            const components = document.querySelectorAll('.component-item');
            
            components.forEach(component => {
                component.addEventListener('dragstart', (e) => {
                    e.dataTransfer.setData('component-type', component.dataset.component);
                    component.classList.add('dragging');
                });
                
                component.addEventListener('dragend', (e) => {
                    component.classList.remove('dragging');
                });
            });
        },

        // קיצורי מקלדת
        initKeyboardShortcuts: function() {
            document.addEventListener('keydown', (e) => {
                if (e.ctrlKey || e.metaKey) {
                    switch(e.key) {
                        case 's':
                            e.preventDefault();
                            this.savePage();
                            break;
                        case 'z':
                            e.preventDefault();
                            this.undo();
                            break;
                        case 'y':
                            e.preventDefault();
                            this.redo();
                            break;
                        case 'n':
                            e.preventDefault();
                            this.newPage();
                            break;
                        case 'd':
                            e.preventDefault();
                            if (this.selectedElement) {
                                this.duplicateElement();
                            }
                            break;
                    }
                }
                
                if (e.key === 'Delete' && this.selectedElement) {
                    this.deleteElement();
                }
            });
        },

        // חיבור אירועים
        bindEvents: function() {
            // כפתור פתיחת העורך
            const openBtn = document.createElement('button');
            openBtn.className = 'open-html-editor';
            openBtn.innerHTML = '📝';
            openBtn.title = 'עורך HTML';
            openBtn.onclick = () => this.toggle();
            document.body.appendChild(openBtn);
            
            // סגירה בלחיצה על ESC
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') {
                    const editor = document.getElementById('effi-html-editor');
                    if (editor.classList.contains('active')) {
                        this.toggle();
                    }
                }
            });
        },

        // החלפת מצב העורך
        toggle: function() {
            const editor = document.getElementById('effi-html-editor');
            editor.classList.toggle('active');
            
            if (editor.classList.contains('active') && !this.currentPage) {
                this.newPage();
            }
        },

        // פונקציות נוספות לשרת רשת וכו'
        toggleGrid: function() {
            const iframe = document.getElementById('page-iframe');
            const doc = iframe.contentDocument;
            
            if (!doc.getElementById('editor-grid')) {
                const grid = doc.createElement('style');
                grid.id = 'editor-grid';
                grid.textContent = `
                    body {
                        background-image: 
                            repeating-linear-gradient(0deg, transparent, transparent 19px, rgba(0,0,0,0.05) 19px, rgba(0,0,0,0.05) 20px),
                            repeating-linear-gradient(90deg, transparent, transparent 19px, rgba(0,0,0,0.05) 19px, rgba(0,0,0,0.05) 20px);
                    }
                `;
                doc.head.appendChild(grid);
            } else {
                doc.getElementById('editor-grid').remove();
            }
        },

        toggleRulers: function() {
            // TODO: מימוש סרגלים
            this.showNotification('סרגלים בפיתוח', 'info');
        }
    };

    // חשיפת המודול
    window.EffiHTMLEditor = EffiHTMLEditor;

    // אתחול אוטומטי
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => EffiHTMLEditor.init());
    } else {
        EffiHTMLEditor.init();
    }

})(window);