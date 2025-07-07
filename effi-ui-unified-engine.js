// Effi-UI Dynamic Engine + HTML Editor - מערכת מאוחדת ומשולבת
// גרסה 2.0.0 - כוללת עורך HTML מלא, ארגז כלים מורחב ויכולות מתקדמות

const EffiUI = {
    version: '2.0.0',
    config: null,
    currentProfile: 'default',
    originalStyles: new Map(),
    appliedElements: new Set(),
    
    // מודול עורך HTML משולב
    htmlEditor: {
        active: false,
        currentPage: null,
        pages: {},
        selectedElement: null,
        history: [],
        historyIndex: -1,
        templates: {}
    },

    // הגדרות צבעים מתקדמות
    colorSchemes: {
        default: {
            primary: '#667eea',
            secondary: '#764ba2',
            success: '#4caf50',
            danger: '#f44336',
            warning: '#ff9800',
            info: '#2196f3',
            light: '#f5f5f5',
            dark: '#212121'
        },
        dark: {
            primary: '#bb86fc',
            secondary: '#03dac6',
            success: '#00e676',
            danger: '#cf6679',
            warning: '#ffab00',
            info: '#448aff',
            light: '#1e1e1e',
            dark: '#121212'
        },
        business: {
            primary: '#1976d2',
            secondary: '#424242',
            success: '#388e3c',
            danger: '#d32f2f',
            warning: '#f57c00',
            info: '#0288d1',
            light: '#fafafa',
            dark: '#263238'
        },
        creative: {
            primary: '#e91e63',
            secondary: '#9c27b0',
            success: '#8bc34a',
            danger: '#ff5722',
            warning: '#ffc107',
            info: '#00bcd4',
            light: '#fff3e0',
            dark: '#3e2723'
        },
        neon: {
            primary: '#00ffff',
            secondary: '#ff00ff',
            success: '#00ff00',
            danger: '#ff0066',
            warning: '#ffff00',
            info: '#0099ff',
            light: '#000000',
            dark: '#0a0a0a'
        }
    },

    // ארגז כלים מורחב - 100+ רכיבים
    toolbox: {
        // כפתורים מתקדמים
        buttons: {
            'gradient': {
                name: 'כפתור גרדיאנט',
                css: `
                    background: linear-gradient(45deg, var(--primary) 0%, var(--secondary) 100%);
                    color: white;
                    border: none;
                    padding: 12px 30px;
                    border-radius: 50px;
                    font-weight: bold;
                    cursor: pointer;
                    transition: all 0.3s;
                    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
                `,
                hover: `
                    transform: translateY(-2px);
                    box-shadow: 0 6px 20px rgba(0,0,0,0.3);
                `
            },
            '3d': {
                name: 'כפתור תלת מימד',
                css: `
                    background: linear-gradient(145deg, #6a7fea, #5968c4);
                    box-shadow: 20px 20px 60px #4e59a8, -20px -20px 60px #7c95ff;
                    color: white;
                    border: none;
                    padding: 15px 35px;
                    border-radius: 15px;
                    font-weight: bold;
                    cursor: pointer;
                    transition: all 0.3s;
                `,
                hover: `
                    box-shadow: inset 20px 20px 60px #4e59a8, inset -20px -20px 60px #7c95ff;
                `
            },
            'glass': {
                name: 'כפתור זכוכית',
                css: `
                    background: rgba(255, 255, 255, 0.1);
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    color: white;
                    padding: 12px 30px;
                    border-radius: 15px;
                    cursor: pointer;
                    transition: all 0.3s;
                `,
                hover: `
                    background: rgba(255, 255, 255, 0.2);
                    transform: scale(1.05);
                `
            },
            'neon': {
                name: 'כפתור ניאון',
                css: `
                    background: transparent;
                    color: #00ffff;
                    border: 2px solid #00ffff;
                    padding: 12px 30px;
                    border-radius: 5px;
                    cursor: pointer;
                    text-shadow: 0 0 10px #00ffff;
                    box-shadow: 0 0 20px #00ffff, inset 0 0 20px rgba(0, 255, 255, 0.2);
                    transition: all 0.3s;
                `,
                hover: `
                    background: rgba(0, 255, 255, 0.1);
                    box-shadow: 0 0 40px #00ffff, inset 0 0 40px rgba(0, 255, 255, 0.3);
                `
            },
            'glitch': {
                name: 'כפתור גליץ\'',
                css: `
                    background: #000;
                    color: #fff;
                    border: 2px solid #fff;
                    padding: 12px 30px;
                    position: relative;
                    cursor: pointer;
                    overflow: hidden;
                    transition: all 0.3s;
                `,
                hover: `
                    color: #00ffff;
                    border-color: #00ffff;
                    animation: glitch 0.5s infinite;
                `,
                keyframes: `
                    @keyframes glitch {
                        0%, 100% { transform: translate(0); }
                        20% { transform: translate(-2px, 2px); }
                        40% { transform: translate(-2px, -2px); }
                        60% { transform: translate(2px, 2px); }
                        80% { transform: translate(2px, -2px); }
                    }
                `
            },
            'magnetic': {
                name: 'כפתור מגנטי',
                css: `
                    background: var(--primary);
                    color: white;
                    border: none;
                    padding: 15px 40px;
                    border-radius: 50px;
                    cursor: pointer;
                    position: relative;
                    overflow: hidden;
                    transition: all 0.3s;
                `,
                hover: `
                    transform: scale(1.1);
                `,
                script: `
                    element.addEventListener('mousemove', (e) => {
                        const rect = element.getBoundingClientRect();
                        const x = e.clientX - rect.left - rect.width / 2;
                        const y = e.clientY - rect.top - rect.height / 2;
                        element.style.transform = \`translate(\${x * 0.3}px, \${y * 0.3}px) scale(1.1)\`;
                    });
                    element.addEventListener('mouseleave', () => {
                        element.style.transform = 'translate(0, 0) scale(1)';
                    });
                `
            },
            'liquid': {
                name: 'כפתור נוזלי',
                css: `
                    background: var(--primary);
                    color: white;
                    border: none;
                    padding: 15px 40px;
                    border-radius: 50px;
                    cursor: pointer;
                    position: relative;
                    overflow: hidden;
                    transition: all 0.6s cubic-bezier(0.23, 1, 0.320, 1);
                `,
                hover: `
                    border-radius: 10px;
                    transform: scale(1.05);
                `
            },
            'cyber': {
                name: 'כפתור סייבר',
                css: `
                    background: #000;
                    color: #0ff;
                    border: 1px solid #0ff;
                    padding: 12px 30px;
                    position: relative;
                    cursor: pointer;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    overflow: hidden;
                    transition: all 0.3s;
                `,
                before: `
                    content: '';
                    position: absolute;
                    top: 0;
                    left: -100%;
                    width: 100%;
                    height: 100%;
                    background: linear-gradient(90deg, transparent, #0ff, transparent);
                    transition: left 0.5s;
                `,
                hover: `
                    color: #000;
                    background: #0ff;
                    box-shadow: 0 0 30px #0ff;
                `,
                hoverBefore: `
                    left: 100%;
                `
            },
            'morph': {
                name: 'כפתור מורף',
                css: `
                    background: var(--primary);
                    color: white;
                    border: none;
                    padding: 15px 40px;
                    border-radius: 20px;
                    cursor: pointer;
                    animation: morph 8s ease-in-out infinite;
                    transition: all 0.3s;
                `,
                keyframes: `
                    @keyframes morph {
                        0%, 100% {
                            border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%;
                        }
                        50% {
                            border-radius: 30% 60% 70% 40% / 50% 60% 30% 60%;
                        }
                    }
                `
            },
            'hologram': {
                name: 'כפתור הולוגרמה',
                css: `
                    background: linear-gradient(45deg, #ff006e, #8338ec, #3a86ff);
                    background-size: 200% 200%;
                    animation: hologram 3s ease infinite;
                    color: white;
                    border: none;
                    padding: 15px 40px;
                    border-radius: 10px;
                    cursor: pointer;
                    position: relative;
                    overflow: hidden;
                `,
                keyframes: `
                    @keyframes hologram {
                        0% { background-position: 0% 50%; }
                        50% { background-position: 100% 50%; }
                        100% { background-position: 0% 50%; }
                    }
                `,
                before: `
                    content: '';
                    position: absolute;
                    top: -2px;
                    left: -2px;
                    right: -2px;
                    bottom: -2px;
                    background: linear-gradient(45deg, #ff006e, #8338ec, #3a86ff, #ff006e);
                    background-size: 400% 400%;
                    animation: hologram 3s ease infinite;
                    filter: blur(5px);
                    z-index: -1;
                `
            }
        },

        // אפקטי טקסט
        textEffects: {
            'gradient-text': {
                name: 'טקסט גרדיאנט',
                css: `
                    background: linear-gradient(45deg, var(--primary), var(--secondary));
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    font-weight: bold;
                `
            },
            'neon-text': {
                name: 'טקסט ניאון',
                css: `
                    color: #fff;
                    text-shadow: 
                        0 0 7px #fff,
                        0 0 10px #fff,
                        0 0 21px #fff,
                        0 0 42px var(--primary),
                        0 0 82px var(--primary),
                        0 0 92px var(--primary),
                        0 0 102px var(--primary),
                        0 0 151px var(--primary);
                `
            },
            'glitch-text': {
                name: 'טקסט גליץ\'',
                css: `
                    position: relative;
                    color: white;
                    animation: textGlitch 2s infinite;
                `,
                keyframes: `
                    @keyframes textGlitch {
                        0%, 100% { text-shadow: 0.05em 0 0 #00fffc, -0.05em -0.025em 0 #fc00ff, 0.025em 0.05em 0 #fffc00; }
                        14% { text-shadow: 0.05em 0 0 #00fffc, -0.05em -0.025em 0 #fc00ff, 0.025em 0.05em 0 #fffc00; }
                        15% { text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.025em 0 #fc00ff, -0.05em -0.05em 0 #fffc00; }
                        49% { text-shadow: -0.05em -0.025em 0 #00fffc, 0.025em 0.025em 0 #fc00ff, -0.05em -0.05em 0 #fffc00; }
                        50% { text-shadow: 0.025em 0.05em 0 #00fffc, 0.05em 0 0 #fc00ff, 0 -0.05em 0 #fffc00; }
                        99% { text-shadow: 0.025em 0.05em 0 #00fffc, 0.05em 0 0 #fc00ff, 0 -0.05em 0 #fffc00; }
                    }
                `
            },
            '3d-text': {
                name: 'טקסט תלת מימד',
                css: `
                    color: #fff;
                    text-shadow: 
                        1px 1px 1px #000,
                        2px 2px 1px #000,
                        3px 3px 1px #000,
                        4px 4px 1px #000,
                        5px 5px 1px #000,
                        6px 6px 1px #000,
                        7px 7px 1px #000,
                        8px 8px 1px #000;
                `
            },
            'animated-text': {
                name: 'טקסט מונפש',
                css: `
                    animation: textWave 2s ease-in-out infinite;
                `,
                keyframes: `
                    @keyframes textWave {
                        0%, 100% { transform: translateY(0); }
                        50% { transform: translateY(-10px); }
                    }
                `
            }
        },

        // אנימציות מתקדמות
        animations: {
            'pulse': {
                name: 'פועם',
                css: 'animation: pulse 2s ease-in-out infinite;',
                keyframes: `
                    @keyframes pulse {
                        0%, 100% { transform: scale(1); opacity: 1; }
                        50% { transform: scale(1.05); opacity: 0.9; }
                    }
                `
            },
            'shake': {
                name: 'רועד',
                css: 'animation: shake 0.5s ease-in-out infinite;',
                keyframes: `
                    @keyframes shake {
                        0%, 100% { transform: translateX(0); }
                        25% { transform: translateX(-5px); }
                        75% { transform: translateX(5px); }
                    }
                `
            },
            'bounce': {
                name: 'קופץ',
                css: 'animation: bounce 1s ease-in-out infinite;',
                keyframes: `
                    @keyframes bounce {
                        0%, 100% { transform: translateY(0); }
                        50% { transform: translateY(-20px); }
                    }
                `
            },
            'spin': {
                name: 'מסתובב',
                css: 'animation: spin 2s linear infinite;',
                keyframes: `
                    @keyframes spin {
                        from { transform: rotate(0deg); }
                        to { transform: rotate(360deg); }
                    }
                `
            },
            'flip': {
                name: 'מתהפך',
                css: 'animation: flip 2s ease-in-out infinite;',
                keyframes: `
                    @keyframes flip {
                        0%, 100% { transform: perspective(400px) rotateY(0); }
                        50% { transform: perspective(400px) rotateY(180deg); }
                    }
                `
            },
            'glow': {
                name: 'זוהר',
                css: 'animation: glow 2s ease-in-out infinite;',
                keyframes: `
                    @keyframes glow {
                        0%, 100% { box-shadow: 0 0 5px var(--primary); }
                        50% { box-shadow: 0 0 20px var(--primary), 0 0 30px var(--primary); }
                    }
                `
            },
            'float': {
                name: 'צף',
                css: 'animation: float 3s ease-in-out infinite;',
                keyframes: `
                    @keyframes float {
                        0%, 100% { transform: translateY(0); }
                        50% { transform: translateY(-10px); }
                    }
                `
            },
            'swing': {
                name: 'מתנדנד',
                css: 'animation: swing 2s ease-in-out infinite; transform-origin: top center;',
                keyframes: `
                    @keyframes swing {
                        0%, 100% { transform: rotate(0deg); }
                        25% { transform: rotate(10deg); }
                        75% { transform: rotate(-10deg); }
                    }
                `
            },
            'rubberBand': {
                name: 'גומי',
                css: 'animation: rubberBand 1s ease-in-out;',
                keyframes: `
                    @keyframes rubberBand {
                        0% { transform: scale3d(1, 1, 1); }
                        30% { transform: scale3d(1.25, 0.75, 1); }
                        40% { transform: scale3d(0.75, 1.25, 1); }
                        50% { transform: scale3d(1.15, 0.85, 1); }
                        65% { transform: scale3d(0.95, 1.05, 1); }
                        75% { transform: scale3d(1.05, 0.95, 1); }
                        100% { transform: scale3d(1, 1, 1); }
                    }
                `
            },
            'heartbeat': {
                name: 'פעימת לב',
                css: 'animation: heartbeat 1.5s ease-in-out infinite;',
                keyframes: `
                    @keyframes heartbeat {
                        0% { transform: scale(1); }
                        14% { transform: scale(1.3); }
                        28% { transform: scale(1); }
                        42% { transform: scale(1.3); }
                        70% { transform: scale(1); }
                    }
                `
            },
            'tada': {
                name: 'טאדה',
                css: 'animation: tada 1s ease-in-out;',
                keyframes: `
                    @keyframes tada {
                        0% { transform: scale3d(1, 1, 1); }
                        10%, 20% { transform: scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg); }
                        30%, 50%, 70%, 90% { transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg); }
                        40%, 60%, 80% { transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg); }
                        100% { transform: scale3d(1, 1, 1); }
                    }
                `
            },
            'jello': {
                name: 'ג\'לי',
                css: 'animation: jello 1s ease-in-out;',
                keyframes: `
                    @keyframes jello {
                        0%, 11.1%, 100% { transform: translate3d(0, 0, 0); }
                        22.2% { transform: skewX(-12.5deg) skewY(-12.5deg); }
                        33.3% { transform: skewX(6.25deg) skewY(6.25deg); }
                        44.4% { transform: skewX(-3.125deg) skewY(-3.125deg); }
                        55.5% { transform: skewX(1.5625deg) skewY(1.5625deg); }
                        66.6% { transform: skewX(-0.78125deg) skewY(-0.78125deg); }
                        77.7% { transform: skewX(0.390625deg) skewY(0.390625deg); }
                        88.8% { transform: skewX(-0.1953125deg) skewY(-0.1953125deg); }
                    }
                `
            }
        },

        // רקעים מתקדמים
        backgrounds: {
            'gradient-animated': {
                name: 'גרדיאנט מונפש',
                css: `
                    background: linear-gradient(45deg, var(--primary), var(--secondary), var(--primary));
                    background-size: 300% 300%;
                    animation: gradientShift 5s ease infinite;
                `,
                keyframes: `
                    @keyframes gradientShift {
                        0% { background-position: 0% 50%; }
                        50% { background-position: 100% 50%; }
                        100% { background-position: 0% 50%; }
                    }
                `
            },
            'particle-bg': {
                name: 'רקע חלקיקים',
                css: `
                    background: #000;
                    position: relative;
                    overflow: hidden;
                `,
                script: `
                    const particleContainer = document.createElement('div');
                    particleContainer.style.cssText = 'position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none;';
                    element.appendChild(particleContainer);
                    
                    function createParticle() {
                        const particle = document.createElement('div');
                        particle.style.cssText = \`
                            position: absolute;
                            width: 4px;
                            height: 4px;
                            background: #fff;
                            border-radius: 50%;
                            left: \${Math.random() * 100}%;
                            top: \${Math.random() * 100}%;
                            animation: particleFloat \${5 + Math.random() * 10}s linear infinite;
                        \`;
                        particleContainer.appendChild(particle);
                        setTimeout(() => particle.remove(), 15000);
                    }
                    
                    setInterval(createParticle, 300);
                `,
                keyframes: `
                    @keyframes particleFloat {
                        from { transform: translateY(0) translateX(0); opacity: 0; }
                        10% { opacity: 1; }
                        90% { opacity: 1; }
                        to { transform: translateY(-100vh) translateX(50px); opacity: 0; }
                    }
                `
            },
            'mesh-gradient': {
                name: 'רקע רשת',
                css: `
                    background: 
                        radial-gradient(at 0% 0%, var(--primary) 0px, transparent 50%),
                        radial-gradient(at 50% 0%, var(--secondary) 0px, transparent 50%),
                        radial-gradient(at 100% 0%, var(--primary) 0px, transparent 50%),
                        radial-gradient(at 0% 50%, var(--secondary) 0px, transparent 50%),
                        radial-gradient(at 100% 50%, var(--primary) 0px, transparent 50%),
                        radial-gradient(at 0% 100%, var(--secondary) 0px, transparent 50%),
                        radial-gradient(at 50% 100%, var(--primary) 0px, transparent 50%),
                        radial-gradient(at 100% 100%, var(--secondary) 0px, transparent 50%);
                    background-size: 40% 40%;
                `
            },
            'wave-pattern': {
                name: 'דפוס גלים',
                css: `
                    background-color: var(--primary);
                    background-image: 
                        repeating-linear-gradient(45deg, transparent, transparent 35px, rgba(255,255,255,.1) 35px, rgba(255,255,255,.1) 70px),
                        repeating-linear-gradient(-45deg, transparent, transparent 35px, rgba(255,255,255,.05) 35px, rgba(255,255,255,.05) 70px);
                `
            },
            'geometric': {
                name: 'גיאומטרי',
                css: `
                    background-color: var(--primary);
                    background-image: 
                        linear-gradient(30deg, var(--secondary) 12%, transparent 12.5%, transparent 87%, var(--secondary) 87.5%, var(--secondary)),
                        linear-gradient(150deg, var(--secondary) 12%, transparent 12.5%, transparent 87%, var(--secondary) 87.5%, var(--secondary)),
                        linear-gradient(30deg, var(--secondary) 12%, transparent 12.5%, transparent 87%, var(--secondary) 87.5%, var(--secondary)),
                        linear-gradient(150deg, var(--secondary) 12%, transparent 12.5%, transparent 87%, var(--secondary) 87.5%, var(--secondary)),
                        linear-gradient(60deg, rgba(255,255,255,0.1) 25%, transparent 25.5%, transparent 75%, rgba(255,255,255,0.1) 75%, rgba(255,255,255,0.1)),
                        linear-gradient(60deg, rgba(255,255,255,0.1) 25%, transparent 25.5%, transparent 75%, rgba(255,255,255,0.1) 75%, rgba(255,255,255,0.1));
                    background-size: 80px 140px;
                    background-position: 0 0, 0 0, 40px 70px, 40px 70px, 0 0, 40px 70px;
                `
            }
        },

        // אפקטים מיוחדים
        effects: {
            'glass-morphism': {
                name: 'זכוכית מטושטשת',
                css: `
                    background: rgba(255, 255, 255, 0.1);
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                `
            },
            'neumorphism': {
                name: 'ניאומורפיזם',
                css: `
                    background: #e0e0e0;
                    border-radius: 20px;
                    box-shadow: 
                        20px 20px 60px #bebebe,
                        -20px -20px 60px #ffffff;
                `
            },
            'cyberpunk': {
                name: 'סייברפאנק',
                css: `
                    background: #000;
                    border: 2px solid #0ff;
                    box-shadow: 
                        0 0 20px #0ff,
                        inset 0 0 20px rgba(0, 255, 255, 0.2);
                    position: relative;
                    overflow: hidden;
                `,
                before: `
                    content: '';
                    position: absolute;
                    top: -50%;
                    left: -50%;
                    width: 200%;
                    height: 200%;
                    background: repeating-linear-gradient(
                        0deg,
                        transparent,
                        transparent 2px,
                        rgba(0, 255, 255, 0.03) 2px,
                        rgba(0, 255, 255, 0.03) 4px
                    );
                    animation: scan 8s linear infinite;
                `,
                keyframes: `
                    @keyframes scan {
                        0% { transform: translateY(0); }
                        100% { transform: translateY(20px); }
                    }
                `
            },
            'holographic': {
                name: 'הולוגרפי',
                css: `
                    background: linear-gradient(45deg, #ff006e, #8338ec, #3a86ff, #06c, #00ff88, #ffdd00, #ff006e);
                    background-size: 300% 300%;
                    animation: holographicShift 6s ease infinite;
                    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
                `,
                keyframes: `
                    @keyframes holographicShift {
                        0%, 100% { background-position: 0% 50%; }
                        50% { background-position: 100% 50%; }
                    }
                `
            },
            'liquid-metal': {
                name: 'מתכת נוזלית',
                css: `
                    background: linear-gradient(45deg, #c0c0c0, #f0f0f0, #c0c0c0);
                    background-size: 200% 200%;
                    animation: liquidMetal 3s ease infinite;
                    box-shadow: 
                        inset 0 2px 4px rgba(255, 255, 255, 0.5),
                        inset 0 -2px 4px rgba(0, 0, 0, 0.5),
                        0 0 20px rgba(192, 192, 192, 0.5);
                `,
                keyframes: `
                    @keyframes liquidMetal {
                        0%, 100% { background-position: 0% 50%; }
                        50% { background-position: 100% 50%; }
                    }
                `
            }
        },

        // פריסות (Layouts)
        layouts: {
            'hero-section': {
                name: 'Hero Section',
                html: `
                    <section class="hero-section" style="
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background: linear-gradient(135deg, var(--primary), var(--secondary));
                        color: white;
                        text-align: center;
                        padding: 2rem;
                    ">
                        <div class="hero-content">
                            <h1 style="font-size: 3rem; margin-bottom: 1rem;">כותרת ראשית</h1>
                            <p style="font-size: 1.5rem; margin-bottom: 2rem;">תיאור משני</p>
                            <button class="effi-btn effi-btn-primary">התחל עכשיו</button>
                        </div>
                    </section>
                `
            },
            'card-grid': {
                name: 'רשת כרטיסים',
                html: `
                    <div class="card-grid" style="
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                        gap: 2rem;
                        padding: 2rem;
                    ">
                        <div class="card" style="
                            background: white;
                            border-radius: 10px;
                            padding: 2rem;
                            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                            transition: transform 0.3s;
                        ">
                            <h3>כרטיס 1</h3>
                            <p>תוכן הכרטיס</p>
                        </div>
                    </div>
                `
            },
            'split-section': {
                name: 'חלוקה 50/50',
                html: `
                    <section class="split-section" style="
                        display: flex;
                        min-height: 400px;
                        align-items: center;
                    ">
                        <div style="flex: 1; padding: 3rem;">
                            <h2>כותרת</h2>
                            <p>תוכן טקסט</p>
                        </div>
                        <div style="flex: 1; background: var(--primary); height: 100%;"></div>
                    </section>
                `
            }
        },

        // רכיבי טופס מתקדמים
        formElements: {
            'modern-input': {
                name: 'שדה מודרני',
                html: `
                    <div class="form-field" style="position: relative; margin: 20px 0;">
                        <input type="text" placeholder=" " style="
                            width: 100%;
                            padding: 15px;
                            border: 2px solid #ddd;
                            border-radius: 8px;
                            font-size: 16px;
                            transition: all 0.3s;
                        ">
                        <label style="
                            position: absolute;
                            top: 50%;
                            left: 15px;
                            transform: translateY(-50%);
                            background: white;
                            padding: 0 5px;
                            color: #999;
                            transition: all 0.3s;
                            pointer-events: none;
                        ">שם השדה</label>
                    </div>
                `,
                css: `
                    .form-field input:focus,
                    .form-field input:not(:placeholder-shown) {
                        border-color: var(--primary);
                    }
                    .form-field input:focus + label,
                    .form-field input:not(:placeholder-shown) + label {
                        top: 0;
                        font-size: 12px;
                        color: var(--primary);
                    }
                `
            },
            'toggle-switch': {
                name: 'מתג החלפה',
                html: `
                    <label class="toggle-switch" style="
                        position: relative;
                        display: inline-block;
                        width: 60px;
                        height: 30px;
                    ">
                        <input type="checkbox" style="opacity: 0; width: 0; height: 0;">
                        <span class="slider" style="
                            position: absolute;
                            cursor: pointer;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background-color: #ccc;
                            transition: .4s;
                            border-radius: 30px;
                        "></span>
                    </label>
                `,
                css: `
                    .toggle-switch input:checked + .slider {
                        background-color: var(--primary);
                    }
                    .toggle-switch .slider:before {
                        content: '';
                        position: absolute;
                        height: 22px;
                        width: 22px;
                        left: 4px;
                        bottom: 4px;
                        background-color: white;
                        transition: .4s;
                        border-radius: 50%;
                    }
                    .toggle-switch input:checked + .slider:before {
                        transform: translateX(30px);
                    }
                `
            },
            'radio-cards': {
                name: 'כרטיסי בחירה',
                html: `
                    <div class="radio-cards" style="display: flex; gap: 1rem;">
                        <label style="
                            flex: 1;
                            padding: 1.5rem;
                            border: 2px solid #ddd;
                            border-radius: 10px;
                            cursor: pointer;
                            transition: all 0.3s;
                            text-align: center;
                        ">
                            <input type="radio" name="option" style="display: none;">
                            <span>אפשרות 1</span>
                        </label>
                    </div>
                `,
                css: `
                    .radio-cards label:has(input:checked) {
                        border-color: var(--primary);
                        background: rgba(102, 126, 234, 0.1);
                    }
                `
            }
        },

        // רכיבי מדיה
        media: {
            'video-player': {
                name: 'נגן וידאו',
                html: `
                    <div class="video-container" style="
                        position: relative;
                        padding-bottom: 56.25%;
                        height: 0;
                        overflow: hidden;
                        background: #000;
                        border-radius: 10px;
                    ">
                        <iframe style="
                            position: absolute;
                            top: 0;
                            left: 0;
                            width: 100%;
                            height: 100%;
                            border: none;
                        " src="" allowfullscreen></iframe>
                    </div>
                `
            },
            'image-gallery': {
                name: 'גלריית תמונות',
                html: `
                    <div class="image-gallery" style="
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                        gap: 1rem;
                    ">
                        <img src="https://via.placeholder.com/200" style="
                            width: 100%;
                            height: 200px;
                            object-fit: cover;
                            border-radius: 8px;
                            cursor: pointer;
                            transition: transform 0.3s;
                        " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                    </div>
                `
            },
            'audio-player': {
                name: 'נגן אודיו',
                html: `
                    <div class="audio-player" style="
                        background: linear-gradient(135deg, var(--primary), var(--secondary));
                        padding: 2rem;
                        border-radius: 15px;
                        color: white;
                        text-align: center;
                    ">
                        <h3>שם השיר</h3>
                        <audio controls style="width: 100%; margin-top: 1rem;">
                            <source src="" type="audio/mpeg">
                        </audio>
                    </div>
                `
            }
        },

        // רכיבי ניווט
        navigation: {
            'modern-navbar': {
                name: 'תפריט מודרני',
                html: `
                    <nav style="
                        background: rgba(255, 255, 255, 0.95);
                        backdrop-filter: blur(10px);
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                        padding: 1rem 2rem;
                        position: sticky;
                        top: 0;
                        z-index: 1000;
                    ">
                        <div style="
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            max-width: 1200px;
                            margin: 0 auto;
                        ">
                            <div class="logo" style="font-size: 1.5rem; font-weight: bold;">לוגו</div>
                            <ul style="
                                display: flex;
                                list-style: none;
                                gap: 2rem;
                                margin: 0;
                                padding: 0;
                            ">
                                <li><a href="#" style="text-decoration: none; color: #333;">דף הבית</a></li>
                                <li><a href="#" style="text-decoration: none; color: #333;">אודות</a></li>
                                <li><a href="#" style="text-decoration: none; color: #333;">שירותים</a></li>
                                <li><a href="#" style="text-decoration: none; color: #333;">צור קשר</a></li>
                            </ul>
                        </div>
                    </nav>
                `
            },
            'sidebar': {
                name: 'תפריט צד',
                html: `
                    <aside style="
                        width: 250px;
                        height: 100vh;
                        background: #2c3e50;
                        color: white;
                        padding: 2rem 0;
                        position: fixed;
                        left: 0;
                        top: 0;
                        overflow-y: auto;
                    ">
                        <h2 style="padding: 0 2rem; margin-bottom: 2rem;">תפריט</h2>
                        <ul style="list-style: none; padding: 0; margin: 0;">
                            <li style="margin-bottom: 0.5rem;">
                                <a href="#" style="
                                    display: block;
                                    padding: 1rem 2rem;
                                    color: white;
                                    text-decoration: none;
                                    transition: background 0.3s;
                                ">פריט תפריט</a>
                            </li>
                        </ul>
                    </aside>
                `
            },
            'breadcrumb': {
                name: 'פירורי לחם',
                html: `
                    <nav aria-label="breadcrumb">
                        <ol style="
                            display: flex;
                            list-style: none;
                            padding: 1rem;
                            background: #f8f9fa;
                            border-radius: 5px;
                            margin: 0;
                        ">
                            <li style="margin-right: 0.5rem;">
                                <a href="#" style="color: var(--primary); text-decoration: none;">דף הבית</a>
                                <span style="margin: 0 0.5rem;">/</span>
                            </li>
                            <li style="color: #6c757d;">עמוד נוכחי</li>
                        </ol>
                    </nav>
                `
            }
        },

        // רכיבי תוכן
        content: {
            'testimonial': {
                name: 'המלצה',
                html: `
                    <div class="testimonial" style="
                        background: white;
                        padding: 2rem;
                        border-radius: 10px;
                        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                        text-align: center;
                        max-width: 600px;
                        margin: 0 auto;
                    ">
                        <img src="https://via.placeholder.com/80" style="
                            width: 80px;
                            height: 80px;
                            border-radius: 50%;
                            margin-bottom: 1rem;
                        ">
                        <p style="
                            font-style: italic;
                            color: #666;
                            margin-bottom: 1rem;
                        ">"טקסט המלצה מדהים על השירות או המוצר"</p>
                        <h4 style="margin: 0;">שם הלקוח</h4>
                        <p style="color: #999; margin: 0;">תפקיד, חברה</p>
                    </div>
                `
            },
            'pricing-card': {
                name: 'כרטיס מחיר',
                html: `
                    <div class="pricing-card" style="
                        background: white;
                        border: 2px solid #eee;
                        border-radius: 10px;
                        padding: 2rem;
                        text-align: center;
                        transition: all 0.3s;
                    ">
                        <h3 style="margin-bottom: 1rem;">תוכנית בסיסית</h3>
                        <div style="
                            font-size: 3rem;
                            font-weight: bold;
                            color: var(--primary);
                            margin-bottom: 1rem;
                        ">₪99<span style="font-size: 1rem; color: #999;">/חודש</span></div>
                        <ul style="
                            list-style: none;
                            padding: 0;
                            margin: 2rem 0;
                            text-align: right;
                        ">
                            <li style="padding: 0.5rem 0;">✓ תכונה 1</li>
                            <li style="padding: 0.5rem 0;">✓ תכונה 2</li>
                            <li style="padding: 0.5rem 0;">✓ תכונה 3</li>
                        </ul>
                        <button class="effi-btn effi-btn-primary" style="width: 100%;">בחר תוכנית</button>
                    </div>
                `
            },
            'timeline': {
                name: 'ציר זמן',
                html: `
                    <div class="timeline" style="
                        position: relative;
                        padding: 2rem 0;
                    ">
                        <div class="timeline-item" style="
                            position: relative;
                            padding-left: 3rem;
                            margin-bottom: 2rem;
                        ">
                            <div style="
                                position: absolute;
                                left: 0;
                                top: 0;
                                width: 20px;
                                height: 20px;
                                background: var(--primary);
                                border-radius: 50%;
                            "></div>
                            <div style="
                                position: absolute;
                                left: 9px;
                                top: 20px;
                                width: 2px;
                                height: calc(100% + 20px);
                                background: #ddd;
                            "></div>
                            <h4>2024</h4>
                            <p>תיאור האירוע</p>
                        </div>
                    </div>
                `
            },
            'accordion': {
                name: 'אקורדיון',
                html: `
                    <div class="accordion">
                        <div class="accordion-item" style="
                            border: 1px solid #ddd;
                            border-radius: 5px;
                            margin-bottom: 10px;
                            overflow: hidden;
                        ">
                            <button style="
                                width: 100%;
                                padding: 1rem;
                                background: #f8f9fa;
                                border: none;
                                text-align: right;
                                cursor: pointer;
                                font-size: 16px;
                                transition: background 0.3s;
                            " onclick="this.nextElementSibling.style.display = this.nextElementSibling.style.display === 'block' ? 'none' : 'block'">
                                שאלה או כותרת
                            </button>
                            <div style="
                                display: none;
                                padding: 1rem;
                                background: white;
                            ">
                                <p>תשובה או תוכן מורחב</p>
                            </div>
                        </div>
                    </div>
                `
            }
        },

        // אייקונים ומדיה
        icons: {
            'social-icons': {
                name: 'אייקוני רשתות חברתיות',
                html: `
                    <div class="social-icons" style="
                        display: flex;
                        gap: 1rem;
                        justify-content: center;
                    ">
                        <a href="#" style="
                            width: 40px;
                            height: 40px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            background: #1877f2;
                            color: white;
                            border-radius: 50%;
                            text-decoration: none;
                            transition: transform 0.3s;
                        ">F</a>
                        <a href="#" style="
                            width: 40px;
                            height: 40px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            background: #1da1f2;
                            color: white;
                            border-radius: 50%;
                            text-decoration: none;
                            transition: transform 0.3s;
                        ">T</a>
                        <a href="#" style="
                            width: 40px;
                            height: 40px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            background: linear-gradient(45deg, #405de6, #5851db, #833ab4, #c13584, #e1306c, #fd1d1d);
                            color: white;
                            border-radius: 50%;
                            text-decoration: none;
                            transition: transform 0.3s;
                        ">I</a>
                    </div>
                `
            },
            'feature-icons': {
                name: 'אייקוני תכונות',
                html: `
                    <div class="feature-icon" style="
                        width: 80px;
                        height: 80px;
                        background: linear-gradient(135deg, var(--primary), var(--secondary));
                        border-radius: 20px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-size: 2rem;
                        margin: 0 auto 1rem;
                        transform: rotate(45deg);
                    ">
                        <span style="transform: rotate(-45deg);">🚀</span>
                    </div>
                `
            }
        },

        // רכיבי אינטראקציה
        interactive: {
            'counter': {
                name: 'מונה',
                html: `
                    <div class="counter" style="text-align: center;">
                        <div style="
                            font-size: 4rem;
                            font-weight: bold;
                            color: var(--primary);
                        " data-target="100">0</div>
                        <p>לקוחות מרוצים</p>
                    </div>
                `,
                script: `
                    const counter = element.querySelector('[data-target]');
                    const target = +counter.getAttribute('data-target');
                    const increment = target / 200;
                    
                    function updateCounter() {
                        const current = +counter.innerText;
                        if (current < target) {
                            counter.innerText = Math.ceil(current + increment);
                            setTimeout(updateCounter, 10);
                        } else {
                            counter.innerText = target;
                        }
                    }
                    
                    updateCounter();
                `
            },
            'progress-bar': {
                name: 'סרגל התקדמות',
                html: `
                    <div class="progress-bar" style="margin: 1rem 0;">
                        <div style="
                            background: #e0e0e0;
                            border-radius: 10px;
                            overflow: hidden;
                            height: 20px;
                        ">
                            <div style="
                                background: linear-gradient(90deg, var(--primary), var(--secondary));
                                height: 100%;
                                width: 0%;
                                transition: width 2s ease;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                color: white;
                                font-size: 12px;
                            " data-progress="75">0%</div>
                        </div>
                    </div>
                `,
                script: `
                    setTimeout(() => {
                        const bar = element.querySelector('[data-progress]');
                        const progress = bar.getAttribute('data-progress');
                        bar.style.width = progress + '%';
                        bar.textContent = progress + '%';
                    }, 100);
                `
            },
            'tooltip': {
                name: 'טולטיפ',
                html: `
                    <span class="tooltip-wrapper" style="
                        position: relative;
                        display: inline-block;
                        cursor: help;
                        color: var(--primary);
                    ">
                        מידע נוסף
                        <span class="tooltip" style="
                            position: absolute;
                            bottom: 100%;
                            left: 50%;
                            transform: translateX(-50%);
                            background: #333;
                            color: white;
                            padding: 0.5rem 1rem;
                            border-radius: 5px;
                            white-space: nowrap;
                            opacity: 0;
                            visibility: hidden;
                            transition: all 0.3s;
                            margin-bottom: 5px;
                        ">זהו הסבר מפורט</span>
                    </span>
                `,
                css: `
                    .tooltip-wrapper:hover .tooltip {
                        opacity: 1;
                        visibility: visible;
                    }
                `
            },
            'modal': {
                name: 'חלון קופץ',
                html: `
                    <button onclick="document.getElementById('modal-demo').style.display='flex'" class="effi-btn effi-btn-primary">
                        פתח חלון קופץ
                    </button>
                    <div id="modal-demo" style="
                        display: none;
                        position: fixed;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        background: rgba(0,0,0,0.5);
                        align-items: center;
                        justify-content: center;
                        z-index: 1000;
                    " onclick="if(event.target === this) this.style.display='none'">
                        <div style="
                            background: white;
                            padding: 2rem;
                            border-radius: 10px;
                            max-width: 500px;
                            width: 90%;
                            position: relative;
                        ">
                            <button onclick="document.getElementById('modal-demo').style.display='none'" style="
                                position: absolute;
                                top: 10px;
                                left: 10px;
                                background: none;
                                border: none;
                                font-size: 1.5rem;
                                cursor: pointer;
                            ">×</button>
                            <h2>כותרת החלון</h2>
                            <p>תוכן החלון הקופץ</p>
                        </div>
                    </div>
                `
            },
            'tabs': {
                name: 'טאבים',
                html: `
                    <div class="tabs-container">
                        <div class="tabs-header" style="
                            display: flex;
                            border-bottom: 2px solid #ddd;
                            margin-bottom: 1rem;
                        ">
                            <button class="tab-btn active" onclick="showTab(this, 'tab1')" style="
                                background: none;
                                border: none;
                                padding: 1rem 2rem;
                                cursor: pointer;
                                border-bottom: 2px solid var(--primary);
                                color: var(--primary);
                                font-weight: bold;
                            ">טאב 1</button>
                            <button class="tab-btn" onclick="showTab(this, 'tab2')" style="
                                background: none;
                                border: none;
                                padding: 1rem 2rem;
                                cursor: pointer;
                                border-bottom: 2px solid transparent;
                            ">טאב 2</button>
                        </div>
                        <div class="tabs-content">
                            <div id="tab1" class="tab-panel" style="display: block;">
                                <p>תוכן טאב 1</p>
                            </div>
                            <div id="tab2" class="tab-panel" style="display: none;">
                                <p>תוכן טאב 2</p>
                            </div>
                        </div>
                    </div>
                `,
                script: `
                    window.showTab = function(btn, tabId) {
                        const container = btn.closest('.tabs-container');
                        container.querySelectorAll('.tab-btn').forEach(b => {
                            b.classList.remove('active');
                            b.style.borderBottomColor = 'transparent';
                            b.style.color = '#333';
                            b.style.fontWeight = 'normal';
                        });
                        container.querySelectorAll('.tab-panel').forEach(p => {
                            p.style.display = 'none';
                        });
                        btn.classList.add('active');
                        btn.style.borderBottomColor = 'var(--primary)';
                        btn.style.color = 'var(--primary)';
                        btn.style.fontWeight = 'bold';
                        document.getElementById(tabId).style.display = 'block';
                    }
                `
            }
        }
    },

    // אתחול המערכת
    init: function() {
        console.log('🚀 Effi-UI Engine v2.0.0 מתחיל...');
        
        this.loadConfig();
        this.injectBaseStyles();
        this.createUI();
        this.bindEvents();
        this.applyProfile(this.currentProfile);
        this.initTimeRules();
        this.setupServiceWorker();
        this.initHTMLEditor();
        
        // אירוע טעינה מוצלחת
        window.dispatchEvent(new CustomEvent('effi-ui-loaded', {
            detail: {
                version: this.version,
                profile: this.currentProfile,
                loadTime: performance.now()
            }
        }));
        
        console.log('✅ Effi-UI Engine + HTML Editor טעון ומוכן!');
    },

    // טעינת הגדרות
    loadConfig: function() {
        try {
            const saved = localStorage.getItem('effi_ui_config');
            if (saved) {
                this.config = JSON.parse(saved);
                this.currentProfile = this.config.currentProfile || 'default';
            } else {
                this.config = {
                    version: this.version,
                    currentProfile: 'default',
                    profiles: {
                        default: {
                            name: 'ברירת מחדל',
                            colors: this.colorSchemes.default,
                            effects: []
                        },
                        dark: {
                            name: 'מצב כהה',
                            colors: this.colorSchemes.dark,
                            effects: ['dark-mode']
                        },
                        business: {
                            name: 'עסקי',
                            colors: this.colorSchemes.business,
                            effects: ['professional']
                        }
                    },
                    timeRules: [],
                    customCSS: '',
                    htmlPages: {}
                };
                this.saveConfig();
            }
        } catch (e) {
            console.error('שגיאה בטעינת הגדרות:', e);
        }
    },

    // שמירת הגדרות
    saveConfig: function() {
        try {
            localStorage.setItem('effi_ui_config', JSON.stringify(this.config));
        } catch (e) {
            console.error('שגיאה בשמירת הגדרות:', e);
        }
    },

    // הזרקת סגנונות בסיס
    injectBaseStyles: function() {
        const styles = `
            /* Effi-UI Engine Styles v2.0.0 */
            :root {
                --effi-primary: ${this.colorSchemes.default.primary};
                --effi-secondary: ${this.colorSchemes.default.secondary};
                --effi-success: ${this.colorSchemes.default.success};
                --effi-danger: ${this.colorSchemes.default.danger};
                --effi-warning: ${this.colorSchemes.default.warning};
                --effi-info: ${this.colorSchemes.default.info};
                --effi-light: ${this.colorSchemes.default.light};
                --effi-dark: ${this.colorSchemes.default.dark};
                
                /* תאימות לאחור */
                --primary: var(--effi-primary);
                --secondary: var(--effi-secondary);
                --success: var(--effi-success);
                --danger: var(--effi-danger);
                --warning: var(--effi-warning);
                --info: var(--effi-info);
                --light: var(--effi-light);
                --dark: var(--effi-dark);
            }

            /* פאנל שליטה ראשי */
            #effi-ui-panel {
                position: fixed;
                top: 0;
                left: -400px;
                width: 400px;
                height: 100vh;
                background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
                color: white;
                transition: left 0.3s ease;
                z-index: 9999;
                overflow-y: auto;
                box-shadow: 2px 0 20px rgba(0,0,0,0.3);
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            #effi-ui-panel.active {
                left: 0;
            }

            /* כפתור פתיחה */
            #effi-ui-toggle {
                position: fixed;
                top: 50%;
                left: 0;
                transform: translateY(-50%);
                background: linear-gradient(135deg, var(--effi-primary), var(--effi-secondary));
                color: white;
                border: none;
                padding: 15px 10px;
                cursor: pointer;
                z-index: 9998;
                border-radius: 0 10px 10px 0;
                transition: all 0.3s;
                box-shadow: 2px 0 10px rgba(0,0,0,0.2);
            }

            #effi-ui-toggle:hover {
                padding-right: 20px;
                box-shadow: 4px 0 20px rgba(0,0,0,0.3);
            }

            /* כותרת הפאנל */
            .effi-panel-header {
                padding: 20px;
                background: rgba(255,255,255,0.1);
                text-align: center;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                position: sticky;
                top: 0;
                z-index: 10;
                backdrop-filter: blur(10px);
            }

            .effi-panel-header h2 {
                margin: 0;
                font-size: 24px;
                background: linear-gradient(45deg, var(--effi-primary), var(--effi-secondary));
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }

            /* טאבים */
            .effi-tabs {
                display: flex;
                background: rgba(0,0,0,0.2);
                padding: 5px;
                margin: 10px;
                border-radius: 10px;
            }

            .effi-tab {
                flex: 1;
                padding: 10px;
                background: transparent;
                border: none;
                color: rgba(255,255,255,0.6);
                cursor: pointer;
                border-radius: 8px;
                transition: all 0.3s;
                font-size: 14px;
                font-weight: 500;
            }

            .effi-tab.active {
                background: var(--effi-primary);
                color: white;
                box-shadow: 0 4px 10px rgba(102, 126, 234, 0.3);
            }

            /* תוכן הטאבים */
            .effi-tab-content {
                display: none;
                padding: 20px;
                animation: fadeIn 0.3s;
            }

            .effi-tab-content.active {
                display: block;
            }

            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }

            /* ארגז כלים */
            .effi-toolbox {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
                padding: 10px;
            }

            .effi-tool-item {
                background: rgba(255,255,255,0.1);
                border: 1px solid rgba(255,255,255,0.2);
                padding: 15px;
                border-radius: 10px;
                cursor: pointer;
                transition: all 0.3s;
                text-align: center;
                position: relative;
                overflow: hidden;
            }

            .effi-tool-item:hover {
                background: rgba(255,255,255,0.2);
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            }

            .effi-tool-item.dragging {
                opacity: 0.5;
                transform: scale(0.95);
            }

            /* אזורי גרירה */
            .effi-drop-zone {
                border: 2px dashed rgba(102, 126, 234, 0.5);
                background: rgba(102, 126, 234, 0.1);
                padding: 20px;
                margin: 10px;
                border-radius: 10px;
                text-align: center;
                color: rgba(255,255,255,0.6);
                transition: all 0.3s;
                min-height: 60px;
            }

            .effi-drop-zone.drag-over {
                border-color: var(--effi-primary);
                background: rgba(102, 126, 234, 0.2);
                color: white;
            }

            /* פרופילים */
            .effi-profile-selector {
                margin: 10px;
            }

            .effi-profile-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 10px;
                margin-top: 10px;
            }

            .effi-profile-card {
                background: rgba(255,255,255,0.1);
                padding: 15px;
                border-radius: 10px;
                cursor: pointer;
                transition: all 0.3s;
                border: 2px solid transparent;
                text-align: center;
            }

            .effi-profile-card.active {
                border-color: var(--effi-primary);
                background: rgba(102, 126, 234, 0.2);
            }

            .effi-profile-card:hover {
                transform: scale(1.05);
                box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            }

            /* עורך HTML משולב */
            .effi-html-editor-section {
                padding: 20px;
                background: rgba(255,255,255,0.05);
                margin: 10px;
                border-radius: 10px;
            }

            .effi-html-components {
                display: grid;
                grid-template-columns: 1fr;
                gap: 10px;
                max-height: 400px;
                overflow-y: auto;
                padding: 10px;
            }

            .effi-html-component {
                background: rgba(255,255,255,0.1);
                padding: 12px;
                border-radius: 8px;
                cursor: move;
                transition: all 0.3s;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .effi-html-component:hover {
                background: rgba(255,255,255,0.2);
                transform: translateX(-5px);
            }

            /* תצוגה מקדימה */
            .effi-preview-frame {
                width: 100%;
                height: 300px;
                border: none;
                border-radius: 10px;
                background: white;
                margin-top: 10px;
            }

            /* אנימציות עומס */
            .effi-spinner {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 3px solid rgba(255,255,255,0.3);
                border-radius: 50%;
                border-top-color: var(--effi-primary);
                animation: effi-spin 1s ease-in-out infinite;
            }

            @keyframes effi-spin {
                to { transform: rotate(360deg); }
            }

            /* התראות */
            .effi-notification {
                position: fixed;
                top: 20px;
                left: 50%;
                transform: translateX(-50%);
                background: var(--effi-success);
                color: white;
                padding: 15px 30px;
                border-radius: 50px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2);
                z-index: 10000;
                animation: slideDown 0.3s ease-out;
            }

            .effi-notification.error {
                background: var(--effi-danger);
            }

            .effi-notification.warning {
                background: var(--effi-warning);
            }

            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translate(-50%, -100%);
                }
                to {
                    opacity: 1;
                    transform: translate(-50%, 0);
                }
            }

            /* רספונסיב */
            @media (max-width: 768px) {
                #effi-ui-panel {
                    width: 100%;
                    left: -100%;
                }
                
                .effi-toolbox {
                    grid-template-columns: 1fr;
                }
                
                .effi-profile-grid {
                    grid-template-columns: 1fr;
                }
            }

            /* סגנונות נוספים לרכיבים */
            .effi-color-picker {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
                padding: 10px;
            }

            .effi-color-swatch {
                width: 40px;
                height: 40px;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s;
                border: 2px solid transparent;
            }

            .effi-color-swatch:hover {
                transform: scale(1.1);
                box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            }

            .effi-color-swatch.active {
                border-color: white;
            }

            /* כפתורי פעולה */
            .effi-action-btn {
                background: var(--effi-primary);
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s;
                font-size: 14px;
                font-weight: 500;
                width: 100%;
                margin-top: 10px;
            }

            .effi-action-btn:hover {
                background: var(--effi-secondary);
                transform: translateY(-2px);
                box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            }

            /* מצב עריכה */
            .effi-editing {
                outline: 2px dashed var(--effi-primary) !important;
                outline-offset: 4px;
                cursor: move;
            }

            /* אייקונים */
            .effi-icon {
                font-size: 24px;
                margin-bottom: 5px;
            }

            /* טולטיפ */
            .effi-tooltip {
                position: absolute;
                background: rgba(0,0,0,0.9);
                color: white;
                padding: 8px 12px;
                border-radius: 6px;
                font-size: 12px;
                white-space: nowrap;
                pointer-events: none;
                opacity: 0;
                transition: opacity 0.3s;
                z-index: 10001;
            }

            .effi-tooltip.show {
                opacity: 1;
            }

            /* Scrollbar מותאם אישית */
            #effi-ui-panel::-webkit-scrollbar {
                width: 8px;
            }

            #effi-ui-panel::-webkit-scrollbar-track {
                background: rgba(255,255,255,0.1);
            }

            #effi-ui-panel::-webkit-scrollbar-thumb {
                background: var(--effi-primary);
                border-radius: 4px;
            }

            #effi-ui-panel::-webkit-scrollbar-thumb:hover {
                background: var(--effi-secondary);
            }

            /* אפקטי Hover מתקדמים */
            .effi-hover-lift {
                transition: transform 0.3s, box-shadow 0.3s;
            }

            .effi-hover-lift:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }

            /* Grid Layout לעורך HTML */
            .effi-html-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 15px;
                padding: 15px;
            }

            .effi-html-grid-item {
                aspect-ratio: 1;
                background: rgba(255,255,255,0.1);
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                transition: all 0.3s;
                font-size: 14px;
                text-align: center;
                padding: 10px;
            }

            .effi-html-grid-item:hover {
                background: rgba(255,255,255,0.2);
                transform: scale(1.05);
            }

            /* תפריט הקשר */
            .effi-context-menu {
                position: fixed;
                background: #2d2d2d;
                border: 1px solid rgba(255,255,255,0.1);
                border-radius: 8px;
                padding: 5px 0;
                box-shadow: 0 4px 20px rgba(0,0,0,0.3);
                z-index: 10000;
                display: none;
            }

            .effi-context-menu-item {
                padding: 10px 20px;
                cursor: pointer;
                transition: background 0.2s;
                color: white;
                font-size: 14px;
            }

            .effi-context-menu-item:hover {
                background: var(--effi-primary);
            }

            /* מצב מסך מלא */
            .effi-fullscreen {
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                width: 100% !important;
                height: 100% !important;
                z-index: 9999 !important;
                background: white !important;
            }

            /* אנימציות כניסה */
            @keyframes effi-slideIn {
                from {
                    transform: translateX(-100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }

            @keyframes effi-fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            @keyframes effi-scaleIn {
                from {
                    transform: scale(0.8);
                    opacity: 0;
                }
                to {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            /* הוספת כל האנימציות מארגז הכלים */
            ${Object.values(this.toolbox.animations).map(anim => anim.keyframes || '').join('\n')}
            ${Object.values(this.toolbox.buttons).map(btn => btn.keyframes || '').join('\n')}
            ${Object.values(this.toolbox.textEffects).map(effect => effect.keyframes || '').join('\n')}
            ${Object.values(this.toolbox.backgrounds).map(bg => bg.keyframes || '').join('\n')}
            ${Object.values(this.toolbox.effects).map(effect => effect.keyframes || '').join('\n')}
        `;

        const styleSheet = document.createElement('style');
        styleSheet.id = 'effi-ui-styles';
        styleSheet.textContent = styles;
        document.head.appendChild(styleSheet);
    },

    // יצירת ממשק המשתמש
    createUI: function() {
        const panelHTML = `
            <div id="effi-ui-panel">
                <div class="effi-panel-header">
                    <h2>Effi-UI Engine 2.0</h2>
                    <p style="margin: 5px 0; opacity: 0.8; font-size: 12px;">מערכת שליטה ויזואלית + עורך HTML</p>
                </div>

                <div class="effi-tabs">
                    <button class="effi-tab active" onclick="EffiUI.switchTab('toolbox')">🧰 ארגז כלים</button>
                    <button class="effi-tab" onclick="EffiUI.switchTab('html-editor')">📝 עורך HTML</button>
                    <button class="effi-tab" onclick="EffiUI.switchTab('profiles')">🎨 פרופילים</button>
                    <button class="effi-tab" onclick="EffiUI.switchTab('settings')">⚙️ הגדרות</button>
                </div>

                <!-- טאב ארגז כלים -->
                <div id="effi-toolbox-tab" class="effi-tab-content active">
                    <div class="effi-section">
                        <h3 style="margin: 0 10px;">🎯 גרור אפקטים לאלמנטים</h3>
                        
                        <div class="effi-subsection">
                            <h4 style="margin: 10px;">כפתורים</h4>
                            <div class="effi-toolbox">
                                ${Object.entries(this.toolbox.buttons).map(([key, btn]) => `
                                    <div class="effi-tool-item" draggable="true" data-effect-type="button" data-effect-key="${key}">
                                        <div class="effi-icon">🔘</div>
                                        <div>${btn.name}</div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4 style="margin: 10px;">אפקטי טקסט</h4>
                            <div class="effi-toolbox">
                                ${Object.entries(this.toolbox.textEffects).map(([key, effect]) => `
                                    <div class="effi-tool-item" draggable="true" data-effect-type="text" data-effect-key="${key}">
                                        <div class="effi-icon">📝</div>
                                        <div>${effect.name}</div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4 style="margin: 10px;">אנימציות</h4>
                            <div class="effi-toolbox">
                                ${Object.entries(this.toolbox.animations).map(([key, anim]) => `
                                    <div class="effi-tool-item" draggable="true" data-effect-type="animation" data-effect-key="${key}">
                                        <div class="effi-icon">✨</div>
                                        <div>${anim.name}</div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4 style="margin: 10px;">רקעים</h4>
                            <div class="effi-toolbox">
                                ${Object.entries(this.toolbox.backgrounds).map(([key, bg]) => `
                                    <div class="effi-tool-item" draggable="true" data-effect-type="background" data-effect-key="${key}">
                                        <div class="effi-icon">🎨</div>
                                        <div>${bg.name}</div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4 style="margin: 10px;">אפקטים מיוחדים</h4>
                            <div class="effi-toolbox">
                                ${Object.entries(this.toolbox.effects).map(([key, effect]) => `
                                    <div class="effi-tool-item" draggable="true" data-effect-type="special" data-effect-key="${key}">
                                        <div class="effi-icon">🌟</div>
                                        <div>${effect.name}</div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- טאב עורך HTML -->
                <div id="effi-html-editor-tab" class="effi-tab-content">
                    <div class="effi-html-editor-section">
                        <h3 style="margin: 0 0 10px 0;">🏗️ בונה דפי HTML</h3>
                        
                        <div style="display: flex; gap: 10px; margin-bottom: 15px;">
                            <button class="effi-action-btn" onclick="EffiUI.htmlEditor.newPage()">
                                ➕ דף חדש
                            </button>
                            <button class="effi-action-btn" onclick="EffiUI.htmlEditor.openEditor()">
                                ✏️ עורך מתקדם
                            </button>
                        </div>

                        <div class="effi-subsection">
                            <h4>רכיבי בסיס</h4>
                            <div class="effi-html-components">
                                <div class="effi-html-component" draggable="true" data-component="heading">
                                    <span>🔤</span> כותרת
                                </div>
                                <div class="effi-html-component" draggable="true" data-component="paragraph">
                                    <span>📄</span> פסקה
                                </div>
                                <div class="effi-html-component" draggable="true" data-component="image">
                                    <span>🖼️</span> תמונה
                                </div>
                                <div class="effi-html-component" draggable="true" data-component="button">
                                    <span>🔲</span> כפתור
                                </div>
                                <div class="effi-html-component" draggable="true" data-component="link">
                                    <span>🔗</span> קישור
                                </div>
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4>פריסות</h4>
                            <div class="effi-html-grid">
                                ${Object.entries(this.toolbox.layouts).map(([key, layout]) => `
                                    <div class="effi-html-grid-item" onclick="EffiUI.insertLayout('${key}')">
                                        ${layout.name}
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4>רכיבי טופס</h4>
                            <div class="effi-html-grid">
                                ${Object.entries(this.toolbox.formElements).map(([key, form]) => `
                                    <div class="effi-html-grid-item" onclick="EffiUI.insertFormElement('${key}')">
                                        ${form.name}
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4>רכיבים אינטראקטיביים</h4>
                            <div class="effi-html-grid">
                                ${Object.entries(this.toolbox.interactive).map(([key, interactive]) => `
                                    <div class="effi-html-grid-item" onclick="EffiUI.insertInteractive('${key}')">
                                        ${interactive.name}
                                    </div>
                                `).join('')}
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4>תצוגה מקדימה</h4>
                            <iframe id="effi-preview-frame" class="effi-preview-frame" src="about:blank"></iframe>
                        </div>
                    </div>
                </div>

                <!-- טאב פרופילים -->
                <div id="effi-profiles-tab" class="effi-tab-content">
                    <div class="effi-profile-selector">
                        <h3 style="margin: 0 0 10px 0;">🎨 בחר פרופיל עיצוב</h3>
                        
                        <div class="effi-profile-grid">
                            ${Object.entries(this.colorSchemes).map(([key, scheme]) => `
                                <div class="effi-profile-card ${key === this.currentProfile ? 'active' : ''}" 
                                     onclick="EffiUI.applyProfile('${key}')">
                                    <div style="
                                        width: 100%;
                                        height: 50px;
                                        background: linear-gradient(45deg, ${scheme.primary}, ${scheme.secondary});
                                        border-radius: 8px;
                                        margin-bottom: 10px;
                                    "></div>
                                    <h4 style="margin: 5px 0;">${key === 'default' ? 'ברירת מחדל' : 
                                                                  key === 'dark' ? 'כהה' : 
                                                                  key === 'business' ? 'עסקי' :
                                                                  key === 'creative' ? 'יצירתי' :
                                                                  key === 'neon' ? 'ניאון' : key}</h4>
                                </div>
                            `).join('')}
                        </div>

                        <div class="effi-subsection">
                            <h4>צבעים מותאמים אישית</h4>
                            <div class="effi-color-picker">
                                <div>
                                    <label style="display: block; margin-bottom: 5px; font-size: 12px;">צבע ראשי</label>
                                    <input type="color" id="effi-primary-color" value="${this.colorSchemes.default.primary}" 
                                           onchange="EffiUI.updateCustomColors()">
                                </div>
                                <div>
                                    <label style="display: block; margin-bottom: 5px; font-size: 12px;">צבע משני</label>
                                    <input type="color" id="effi-secondary-color" value="${this.colorSchemes.default.secondary}" 
                                           onchange="EffiUI.updateCustomColors()">
                                </div>
                            </div>
                        </div>

                        <div class="effi-subsection">
                            <h4>חוקי זמן אוטומטיים</h4>
                            <button class="effi-action-btn" onclick="EffiUI.addTimeRule()">
                                ⏰ הוסף חוק זמן
                            </button>
                            <div id="effi-time-rules" style="margin-top: 10px;">
                                <!-- חוקי זמן יופיעו כאן -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- טאב הגדרות -->
                <div id="effi-settings-tab" class="effi-tab-content">
                    <div style="padding: 20px;">
                        <h3 style="margin: 0 0 20px 0;">⚙️ הגדרות מערכת</h3>
                        
                        <div class="effi-subsection">
                            <h4>ייבוא וייצוא</h4>
                            <button class="effi-action-btn" onclick="EffiUI.exportConfig()">
                                📤 ייצא הגדרות
                            </button>
                            <button class="effi-action-btn" onclick="EffiUI.importConfig()">
                                📥 ייבא הגדרות
                            </button>
                        </div>

                        <div class="effi-subsection">
                            <h4>CSS מותאם אישית</h4>
                            <textarea id="effi-custom-css" style="
                                width: 100%;
                                height: 150px;
                                background: rgba(0,0,0,0.3);
                                color: white;
                                border: 1px solid rgba(255,255,255,0.2);
                                border-radius: 8px;
                                padding: 10px;
                                font-family: monospace;
                            " placeholder="הוסף CSS מותאם אישית כאן..."></textarea>
                            <button class="effi-action-btn" onclick="EffiUI.applyCustomCSS()">
                                ✅ החל CSS
                            </button>
                        </div>

                        <div class="effi-subsection">
                            <h4>ניהול נתונים</h4>
                            <button class="effi-action-btn" onclick="EffiUI.clearAllData()">
                                🗑️ נקה את כל הנתונים
                            </button>
                            <button class="effi-action-btn" onclick="EffiUI.resetToDefaults()">
                                🔄 אפס לברירת מחדל
                            </button>
                        </div>

                        <div class="effi-subsection">
                            <h4>אודות</h4>
                            <p style="font-size: 14px; opacity: 0.8;">
                                Effi-UI Dynamic Engine v${this.version}<br>
                                מערכת שליטה ויזואלית מתקדמת<br>
                                כולל עורך HTML משולב<br>
                                © 2024 Effi-AI
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <button id="effi-ui-toggle" onclick="EffiUI.togglePanel()">
                <span style="font-size: 20px;">🎨</span>
            </button>

            <!-- תפריט הקשר -->
            <div class="effi-context-menu" id="effi-context-menu">
                <div class="effi-context-menu-item" onclick="EffiUI.editElement()">✏️ ערוך</div>
                <div class="effi-context-menu-item" onclick="EffiUI.duplicateElement()">📋 שכפל</div>
                <div class="effi-context-menu-item" onclick="EffiUI.deleteElement()">🗑️ מחק</div>
                <div class="effi-context-menu-item" onclick="EffiUI.inspectElement()">🔍 בחן</div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', panelHTML);
    },

    // החלפת טאבים
    switchTab: function(tabName) {
        // הסתר את כל הטאבים
        document.querySelectorAll('.effi-tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.querySelectorAll('.effi-tab').forEach(tab => {
            tab.classList.remove('active');
        });

        // הצג את הטאב הנבחר
        document.getElementById(`effi-${tabName}-tab`).classList.add('active');
        event.target.classList.add('active');
    },

    // החלפת מצב הפאנל
    togglePanel: function() {
        const panel = document.getElementById('effi-ui-panel');
        panel.classList.toggle('active');
    },

    // החלת פרופיל
    applyProfile: function(profileName) {
        if (this.colorSchemes[profileName]) {
            this.currentProfile = profileName;
            const colors = this.colorSchemes[profileName];
            
            // עדכון משתני CSS
            Object.entries(colors).forEach(([key, value]) => {
                document.documentElement.style.setProperty(`--effi-${key}`, value);
                document.documentElement.style.setProperty(`--${key}`, value);
            });
            
            // עדכון כרטיסי פרופיל
            document.querySelectorAll('.effi-profile-card').forEach(card => {
                card.classList.remove('active');
            });
            event.currentTarget.classList.add('active');
            
            // שמירה
            this.config.currentProfile = profileName;
            this.saveConfig();
            
            this.showNotification(`פרופיל "${profileName}" הוחל בהצלחה`, 'success');
        }
    },

    // חיבור אירועים
    bindEvents: function() {
        // Drag & Drop לארגז כלים
        document.querySelectorAll('.effi-tool-item').forEach(item => {
            item.addEventListener('dragstart', (e) => {
                e.dataTransfer.effectAllowed = 'copy';
                e.dataTransfer.setData('effect-type', item.dataset.effectType);
                e.dataTransfer.setData('effect-key', item.dataset.effectKey);
                item.classList.add('dragging');
            });
            
            item.addEventListener('dragend', () => {
                item.classList.remove('dragging');
            });
        });

        // Drag & Drop לרכיבי HTML
        document.querySelectorAll('.effi-html-component').forEach(comp => {
            comp.addEventListener('dragstart', (e) => {
                e.dataTransfer.effectAllowed = 'copy';
                e.dataTransfer.setData('component-type', comp.dataset.component);
                comp.classList.add('dragging');
            });
            
            comp.addEventListener('dragend', () => {
                comp.classList.remove('dragging');
            });
        });

        // מאזינים לאלמנטים בדף
        this.setupPageListeners();

        // קיצורי מקלדת
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case 'e':
                        e.preventDefault();
                        this.togglePanel();
                        break;
                    case 's':
                        e.preventDefault();
                        this.saveConfig();
                        this.showNotification('הגדרות נשמרו', 'success');
                        break;
                    case 'z':
                        e.preventDefault();
                        this.undo();
                        break;
                    case 'd':
                        e.preventDefault();
                        this.toggleDarkMode();
                        break;
                }
            }
        });

        // תפריט הקשר
        document.addEventListener('contextmenu', (e) => {
            if (e.target.classList.contains('effi-editable')) {
                e.preventDefault();
                this.showContextMenu(e);
            }
        });

        // סגירת תפריט הקשר
        document.addEventListener('click', () => {
            document.getElementById('effi-context-menu').style.display = 'none';
        });
    },

    // הגדרת מאזינים לדף
    setupPageListeners: function() {
        // הפוך אלמנטים לניתנים לגרירה
        document.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
            
            // הוסף אינדיקציה לאזור גרירה
            const target = e.target;
            if (target.tagName && target.tagName !== 'HTML' && target.tagName !== 'BODY') {
                target.classList.add('effi-drop-zone');
            }
        });

        document.addEventListener('dragleave', (e) => {
            e.target.classList.remove('effi-drop-zone');
        });

        document.addEventListener('drop', (e) => {
            e.preventDefault();
            e.target.classList.remove('effi-drop-zone');
            
            const effectType = e.dataTransfer.getData('effect-type');
            const effectKey = e.dataTransfer.getData('effect-key');
            const componentType = e.dataTransfer.getData('component-type');
            
            if (effectType && effectKey) {
                this.applyEffect(e.target, effectType, effectKey);
            } else if (componentType) {
                this.insertComponent(e.target, componentType);
            }
        });

        // לחיצה כפולה לעריכה
        document.addEventListener('dblclick', (e) => {
            if (e.target.tagName && 
                e.target.tagName !== 'HTML' && 
                e.target.tagName !== 'BODY' &&
                !e.target.closest('#effi-ui-panel')) {
                this.enableInlineEdit(e.target);
            }
        });
    },

    // החלת אפקט על אלמנט
    applyEffect: function(element, effectType, effectKey) {
        if (!element || element.tagName === 'HTML' || element.tagName === 'BODY') return;
        
        let effect = null;
        
        switch(effectType) {
            case 'button':
                effect = this.toolbox.buttons[effectKey];
                break;
            case 'text':
                effect = this.toolbox.textEffects[effectKey];
                break;
            case 'animation':
                effect = this.toolbox.animations[effectKey];
                break;
            case 'background':
                effect = this.toolbox.backgrounds[effectKey];
                break;
            case 'special':
                effect = this.toolbox.effects[effectKey];
                break;
        }
        
        if (effect) {
            // שמור סגנון מקורי
            if (!this.originalStyles.has(element)) {
                this.originalStyles.set(element, element.getAttribute('style') || '');
            }
            
            // החל CSS
            if (effect.css) {
                const currentStyle = element.getAttribute('style') || '';
                element.setAttribute('style', currentStyle + '; ' + effect.css);
            }
            
            // החל Hover
            if (effect.hover) {
                element.addEventListener('mouseenter', () => {
                    const currentStyle = element.getAttribute('style') || '';
                    element.setAttribute('data-original-style', currentStyle);
                    element.setAttribute('style', currentStyle + '; ' + effect.hover);
                });
                
                element.addEventListener('mouseleave', () => {
                    const originalStyle = element.getAttribute('data-original-style');
                    if (originalStyle) {
                        element.setAttribute('style', originalStyle);
                    }
                });
            }
            
            // החל Before/After
            if (effect.before || effect.after) {
                // יצירת pseudo elements דרך CSS class
                const className = `effi-effect-${effectKey}`;
                element.classList.add(className);
                
                if (!document.getElementById(`effi-pseudo-${effectKey}`)) {
                    const pseudoStyle = document.createElement('style');
                    pseudoStyle.id = `effi-pseudo-${effectKey}`;
                    let css = '';
                    
                    if (effect.before) {
                        css += `.${className}::before { ${effect.before} }`;
                    }
                    if (effect.after) {
                        css += `.${className}::after { ${effect.after} }`;
                    }
                    if (effect.hoverBefore) {
                        css += `.${className}:hover::before { ${effect.hoverBefore} }`;
                    }
                    
                    pseudoStyle.textContent = css;
                    document.head.appendChild(pseudoStyle);
                }
            }
            
            // הרץ סקריפט אם יש
            if (effect.script) {
                try {
                    const func = new Function('element', effect.script);
                    func(element);
                } catch (e) {
                    console.error('Error executing effect script:', e);
                }
            }
            
            // הוסף לרשימת אלמנטים מושפעים
            this.appliedElements.add(element);
            element.classList.add('effi-applied');
            
            this.showNotification(`אפקט "${effect.name}" הוחל בהצלחה`, 'success');
        }
    },

    // הכנסת רכיב HTML
    insertComponent: function(target, componentType) {
        const component = this.getComponentHTML(componentType);
        if (component && target) {
            target.insertAdjacentHTML('afterend', component);
            this.showNotification('רכיב נוסף בהצלחה', 'success');
        }
    },

    // קבלת HTML של רכיב
    getComponentHTML: function(type) {
        const components = {
            'heading': '<h2 class="effi-editable">כותרת חדשה</h2>',
            'paragraph': '<p class="effi-editable">פסקה חדשה. לחץ פעמיים לעריכה.</p>',
            'image': '<img src="https://via.placeholder.com/300x200" alt="תמונה" class="effi-editable" style="max-width: 100%;">',
            'button': '<button class="effi-btn effi-editable">כפתור חדש</button>',
            'link': '<a href="#" class="effi-editable" style="color: var(--primary);">קישור חדש</a>'
        };
        
        return components[type] || '';
    },

    // עריכה ישירה
    enableInlineEdit: function(element) {
        element.contentEditable = true;
        element.focus();
        element.classList.add('effi-editing');
        
        const finishEdit = () => {
            element.contentEditable = false;
            element.classList.remove('effi-editing');
        };
        
        element.addEventListener('blur', finishEdit);
        element.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                finishEdit();
            }
        });
    },

    // מודול עורך HTML משולב
    initHTMLEditor: function() {
        const self = this;
        
        // פונקציות עורך HTML
        this.htmlEditor = {
            ...this.htmlEditor,
            
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
    <link rel="stylesheet" href="effi_ui_engine.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
    </style>
</head>
<body>
    <h1>דף חדש</h1>
    <p>התחל לערוך כאן...</p>
    
    <script src="effi_ui_engine.js"></script>
</body>
</html>`,
                    created: new Date().toISOString(),
                    modified: new Date().toISOString()
                };
                
                self.htmlEditor.pages[pageId] = newPage;
                self.htmlEditor.currentPage = pageId;
                self.config.htmlPages = self.htmlEditor.pages;
                self.saveConfig();
                
                // טען בתצוגה מקדימה
                self.loadPagePreview(newPage);
                
                self.showNotification('דף חדש נוצר בהצלחה', 'success');
            },
            
            openEditor: function() {
                // פתח עורך HTML מתקדם בחלון חדש
                const editorWindow = window.open('', 'effi-html-editor', 'width=1200,height=800');
                
                if (self.htmlEditor.currentPage) {
                    const page = self.htmlEditor.pages[self.htmlEditor.currentPage];
                    editorWindow.document.write(page.html);
                    editorWindow.document.close();
                    
                    // הוסף כלי עריכה
                    editorWindow.document.body.contentEditable = true;
                    
                    // שמור שינויים
                    editorWindow.addEventListener('beforeunload', () => {
                        page.html = editorWindow.document.documentElement.outerHTML;
                        page.modified = new Date().toISOString();
                        self.saveConfig();
                    });
                } else {
                    editorWindow.document.write('<h1>אנא צור דף חדש תחילה</h1>');
                    editorWindow.document.close();
                }
            }
        };
    },

    // טעינת דף בתצוגה מקדימה
    loadPagePreview: function(page) {
        const preview = document.getElementById('effi-preview-frame');
        const doc = preview.contentDocument || preview.contentWindow.document;
        
        doc.open();
        doc.write(page.html);
        doc.close();
    },

    // הכנסת פריסה
    insertLayout: function(layoutKey) {
        const layout = this.toolbox.layouts[layoutKey];
        if (layout) {
            // בדוק אם יש עורך פתוח
            const preview = document.getElementById('effi-preview-frame');
            const doc = preview.contentDocument;
            
            if (doc && doc.body) {
                doc.body.insertAdjacentHTML('beforeend', layout.html);
                this.showNotification(`פריסת "${layout.name}" נוספה`, 'success');
            } else {
                // אם אין עורך פתוח, הוסף לדף הנוכחי
                document.body.insertAdjacentHTML('beforeend', layout.html);
            }
        }
    },

    // הכנסת רכיב טופס
    insertFormElement: function(formKey) {
        const formElement = this.toolbox.formElements[formKey];
        if (formElement) {
            const preview = document.getElementById('effi-preview-frame');
            const doc = preview.contentDocument;
            
            if (doc && doc.body) {
                doc.body.insertAdjacentHTML('beforeend', formElement.html);
                
                // הוסף CSS אם יש
                if (formElement.css) {
                    const style = doc.createElement('style');
                    style.textContent = formElement.css;
                    doc.head.appendChild(style);
                }
                
                this.showNotification(`רכיב "${formElement.name}" נוסף`, 'success');
            }
        }
    },

    // הכנסת רכיב אינטראקטיבי
    insertInteractive: function(interactiveKey) {
        const interactive = this.toolbox.interactive[interactiveKey];
        if (interactive) {
            const preview = document.getElementById('effi-preview-frame');
            const doc = preview.contentDocument;
            
            if (doc && doc.body) {
                // יצירת wrapper עם ID ייחודי
                const wrapperId = 'effi-interactive-' + Date.now();
                const wrapper = `<div id="${wrapperId}">${interactive.html}</div>`;
                doc.body.insertAdjacentHTML('beforeend', wrapper);
                
                // הוסף CSS אם יש
                if (interactive.css) {
                    const style = doc.createElement('style');
                    style.textContent = interactive.css;
                    doc.head.appendChild(style);
                }
                
                // הרץ סקריפט אם יש
                if (interactive.script) {
                    const script = doc.createElement('script');
                    script.textContent = `(function() {
                        const element = document.getElementById('${wrapperId}');
                        ${interactive.script}
                    })();`;
                    doc.body.appendChild(script);
                }
                
                this.showNotification(`רכיב "${interactive.name}" נוסף`, 'success');
            }
        }
    },

    // עדכון צבעים מותאמים אישית
    updateCustomColors: function() {
        const primary = document.getElementById('effi-primary-color').value;
        const secondary = document.getElementById('effi-secondary-color').value;
        
        document.documentElement.style.setProperty('--effi-primary', primary);
        document.documentElement.style.setProperty('--effi-secondary', secondary);
        document.documentElement.style.setProperty('--primary', primary);
        document.documentElement.style.setProperty('--secondary', secondary);
        
        this.showNotification('צבעים עודכנו', 'success');
    },

    // הוספת חוק זמן
    addTimeRule: function() {
        const time = prompt('הכנס שעה (לדוגמה: 18:00):');
        const profile = prompt('איזה פרופיל להפעיל? (default/dark/business/creative/neon)');
        
        if (time && profile && this.colorSchemes[profile]) {
            const rule = {
                id: Date.now(),
                time: time,
                profile: profile,
                active: true
            };
            
            this.config.timeRules = this.config.timeRules || [];
            this.config.timeRules.push(rule);
            this.saveConfig();
            
            this.updateTimeRulesDisplay();
            this.showNotification('חוק זמן נוסף בהצלחה', 'success');
        }
    },

    // עדכון תצוגת חוקי זמן
    updateTimeRulesDisplay: function() {
        const container = document.getElementById('effi-time-rules');
        if (!container) return;
        
        container.innerHTML = (this.config.timeRules || []).map(rule => `
            <div style="
                background: rgba(255,255,255,0.1);
                padding: 10px;
                margin: 5px 0;
                border-radius: 5px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            ">
                <span>⏰ ${rule.time} ← ${rule.profile}</span>
                <button onclick="EffiUI.removeTimeRule(${rule.id})" style="
                    background: var(--effi-danger);
                    color: white;
                    border: none;
                    padding: 5px 10px;
                    border-radius: 5px;
                    cursor: pointer;
                ">מחק</button>
            </div>
        `).join('');
    },

    // הסרת חוק זמן
    removeTimeRule: function(ruleId) {
        this.config.timeRules = this.config.timeRules.filter(rule => rule.id !== ruleId);
        this.saveConfig();
        this.updateTimeRulesDisplay();
        this.showNotification('חוק זמן הוסר', 'info');
    },

    // אתחול חוקי זמן
    initTimeRules: function() {
        setInterval(() => {
            const now = new Date();
            const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
            
            (this.config.timeRules || []).forEach(rule => {
                if (rule.active && rule.time === currentTime) {
                    this.applyProfile(rule.profile);
                }
            });
        }, 60000); // בדוק כל דקה
    },

    // החלת CSS מותאם אישית
    applyCustomCSS: function() {
        const customCSS = document.getElementById('effi-custom-css').value;
        
        let styleTag = document.getElementById('effi-custom-styles');
        if (!styleTag) {
            styleTag = document.createElement('style');
            styleTag.id = 'effi-custom-styles';
            document.head.appendChild(styleTag);
        }
        
        styleTag.textContent = customCSS;
        
        this.config.customCSS = customCSS;
        this.saveConfig();
        
        this.showNotification('CSS מותאם אישית הוחל', 'success');
    },

    // ייצוא הגדרות
    exportConfig: function() {
        const dataStr = JSON.stringify(this.config, null, 2);
        const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
        
        const exportLink = document.createElement('a');
        exportLink.setAttribute('href', dataUri);
        exportLink.setAttribute('download', 'effi-ui-config.json');
        exportLink.click();
        
        this.showNotification('הגדרות יוצאו בהצלחה', 'success');
    },

    // ייבוא הגדרות
    importConfig: function() {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.json';
        
        input.onchange = (e) => {
            const file = e.target.files[0];
            const reader = new FileReader();
            
            reader.onload = (event) => {
                try {
                    const imported = JSON.parse(event.target.result);
                    this.config = imported;
                    this.saveConfig();
                    location.reload();
                } catch (error) {
                    this.showNotification('שגיאה בייבוא הגדרות', 'error');
                }
            };
            
            reader.readAsText(file);
        };
        
        input.click();
    },

    // ניקוי כל הנתונים
    clearAllData: function() {
        if (confirm('האם אתה בטוח? פעולה זו תמחק את כל ההגדרות והדפים השמורים.')) {
            localStorage.removeItem('effi_ui_config');
            localStorage.removeItem('effi_html_pages');
            location.reload();
        }
    },

    // איפוס לברירת מחדל
    resetToDefaults: function() {
        if (confirm('האם לאפס את כל ההגדרות לברירת מחדל?')) {
            localStorage.removeItem('effi_ui_config');
            location.reload();
        }
    },

    // מצב כהה מהיר
    toggleDarkMode: function() {
        if (this.currentProfile === 'dark') {
            this.applyProfile('default');
        } else {
            this.applyProfile('dark');
        }
    },

    // הצגת תפריט הקשר
    showContextMenu: function(e) {
        const menu = document.getElementById('effi-context-menu');
        menu.style.display = 'block';
        menu.style.left = e.pageX + 'px';
        menu.style.top = e.pageY + 'px';
        
        this.contextTarget = e.target;
    },

    // עריכת אלמנט
    editElement: function() {
        if (this.contextTarget) {
            this.enableInlineEdit(this.contextTarget);
        }
    },

    // שכפול אלמנט
    duplicateElement: function() {
        if (this.contextTarget) {
            const clone = this.contextTarget.cloneNode(true);
            this.contextTarget.parentNode.insertBefore(clone, this.contextTarget.nextSibling);
            this.showNotification('אלמנט שוכפל', 'success');
        }
    },

    // מחיקת אלמנט
    deleteElement: function() {
        if (this.contextTarget && confirm('האם למחוק את האלמנט?')) {
            this.contextTarget.remove();
            this.showNotification('אלמנט נמחק', 'info');
        }
    },

    // בחינת אלמנט
    inspectElement: function() {
        if (this.contextTarget) {
            console.log('Element:', this.contextTarget);
            console.log('Styles:', window.getComputedStyle(this.contextTarget));
            this.showNotification('פרטי האלמנט נשלחו לקונסול', 'info');
        }
    },

    // ביטול פעולה
    undo: function() {
        // TODO: מימוש מערכת Undo/Redo מלאה
        this.showNotification('מערכת Undo בפיתוח', 'info');
    },

    // הצגת התראה
    showNotification: function(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `effi-notification ${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // אנימציית כניסה
        setTimeout(() => {
            notification.style.opacity = '1';
        }, 10);
        
        // הסרה אוטומטית
        setTimeout(() => {
            notification.style.animation = 'slideUp 0.3s ease-out';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    },

    // התקנת Service Worker
    setupServiceWorker: function() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/service-worker.js')
                .then(reg => console.log('Service Worker registered'))
                .catch(err => console.log('Service Worker registration failed'));
        }
    },

    // פונקציות עזר לטעינת המערכת
    loadExternalScript: function(src) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = src;
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
        });
    },

    // טעינה אוטומטית בעת טעינת הדף
    autoInit: function() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }
};

// הוספת סגנונות נוספות למובייל
const mobileStyles = `
    @media (max-width: 768px) {
        /* התאמות למובייל */
        #effi-ui-toggle {
            bottom: 20px;
            top: auto;
            left: 50%;
            transform: translateX(-50%);
            border-radius: 50px;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        #effi-ui-panel {
            width: 100vw;
            left: -100vw;
        }
        
        #effi-ui-panel.active {
            left: 0;
        }
        
        .effi-toolbox {
            grid-template-columns: 1fr;
        }
        
        .effi-html-grid {
            grid-template-columns: repeat(2, 1fr);
        }
        
        /* כפתורים גדולים יותר למגע */
        .effi-action-btn {
            padding: 15px 20px;
            font-size: 16px;
        }
        
        .effi-tool-item {
            padding: 20px;
        }
        
        /* תפריט הקשר למובייל */
        .effi-context-menu {
            font-size: 16px;
        }
        
        .effi-context-menu-item {
            padding: 15px 25px;
        }
    }
    
    /* תמיכה בתנועות מגע */
    @media (hover: none) {
        .effi-tool-item:active {
            transform: scale(0.95);
            background: rgba(255,255,255,0.3);
        }
        
        .effi-action-btn:active {
            transform: scale(0.95);
        }
    }
    
    /* אנימציות נוספות */
    @keyframes slideUp {
        to {
            opacity: 0;
            transform: translate(-50%, -150%);
        }
    }
    
    @keyframes effi-pulse {
        0% { box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(102, 126, 234, 0); }
        100% { box-shadow: 0 0 0 0 rgba(102, 126, 234, 0); }
    }
    
    /* Dark mode adjustments */
    @media (prefers-color-scheme: dark) {
        .effi-preview-frame {
            background: #1a1a1a;
        }
    }
`;

// הוספת הסגנונות למסמך
const additionalStyles = document.createElement('style');
additionalStyles.textContent = mobileStyles;
document.head.appendChild(additionalStyles);

// יצירת אובייקט גלובלי לקריאות חיצוניות
window.EffiUI = EffiUI;

// טעינה אוטומטית
EffiUI.autoInit();

// ייצוא למודולים
if (typeof module !== 'undefined' && module.exports) {
    module.exports = EffiUI;
}