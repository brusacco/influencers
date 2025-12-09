/**
 * Script de automatización para TikTok con técnicas avanzadas de evasión
 * 
 * Uso:
 *   node test.js                    - Modo normal: va primero a la página principal
 *   node test.js --direct           - Modo directo: va directamente al perfil
 *   node test.js --skip-front       - Igual que --direct
 *   node test.js --profile=username - Especificar otro perfil (default: enlatitud25)
 *   node test.js --direct --profile=username - Combinar ambos parámetros
 */

const { chromium } = require('playwright');
const path = require('path');
const os = require('os');

(async () => {
    // Parsear argumentos de línea de comandos
    const args = process.argv.slice(2);
    const skipFrontPage = args.includes('--direct') || args.includes('--skip-front');
    const profileUsername = args.find(arg => arg.startsWith('--profile='))?.split('=')[1] || 'enlatitud25';

    console.log('═══════════════════════════════════════════════════════');
    if (skipFrontPage) {
        console.log('🚀 Modo: DIRECTO (saltando página principal)');
    } else {
        console.log('🌐 Modo: NORMAL (navegando primero a página principal)');
    }
    console.log(`👤 Perfil objetivo: @${profileUsername}`);
    console.log('═══════════════════════════════════════════════════════');

    // Crear un directorio de perfil persistente para simular un navegador real
    const userDataDir = path.join(os.tmpdir(), 'playwright-chrome-profile-' + Date.now());

    // Técnica avanzada: Usar perfil persistente con cookies y estado real
    const browser = await chromium.launchPersistentContext(userDataDir, {
        headless: false,
        channel: 'chrome', // Usar Chrome instalado en el sistema si está disponible
        args: [
            '--disable-blink-features=AutomationControlled',
            '--disable-dev-shm-usage',
            '--no-first-run',
            '--no-default-browser-check',
            '--disable-infobars',
            '--disable-popup-blocking',
            '--disable-translate',
            '--disable-background-timer-throttling',
            '--disable-backgrounding-occluded-windows',
            '--disable-renderer-backgrounding',
            '--disable-features=TranslateUI,BlinkGenPropertyTrees',
            '--disable-ipc-flooding-protection',
            '--enable-features=NetworkService,NetworkServiceInProcess',
            '--force-color-profile=srgb',
            '--metrics-recording-only',
            '--use-mock-keychain',
            '--start-maximized',
            '--window-size=1920,1080',
            '--disable-extensions-except',
            '--disable-extensions',
            '--disable-component-extensions-with-background-pages',
            '--disable-default-apps',
            '--mute-audio',
            '--no-pings',
            '--disable-notifications',
            '--disable-save-password-bubble',
        ],
        viewport: { width: 1920, height: 1080 },
        // User-Agent más actualizado y específico
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        locale: 'es-PY',
        timezoneId: 'America/Asuncion',
        permissions: ['geolocation', 'notifications'],
        geolocation: { latitude: -25.2637, longitude: -57.5759 }, // Asunción, Paraguay
        colorScheme: 'light',
        // Headers más completos y realistas para TikTok
        extraHTTPHeaders: {
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'es-PY,es;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br, zstd',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'Sec-Ch-Ua-Mobile': '?0',
            'Sec-Ch-Ua-Platform': '"macOS"',
            'Cache-Control': 'max-age=0',
            'DNT': '1',
            'Referer': 'https://www.google.com/',
        },
        // Mantener cookies y estado entre navegaciones (sesión persistente)
        ignoreHTTPSErrors: false,
        javaScriptEnabled: true,
    });

    const page = browser.pages()[0] || await browser.newPage();

    // Script avanzado de evasión mejorado para evitar captchas
    await page.addInitScript(`
        // ============================================
        // OBJETIVO: SIMULACIÓN COMPLETA DE NAVEGADOR REAL
        // ============================================
        
        // ========== 1. navigator.webdriver = undefined ==========
        // Eliminar webdriver completamente y de forma persistente
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
            configurable: true,
            enumerable: false
        });
        
        // Eliminar todas las referencias a webdriver
        delete window.navigator.__proto__.webdriver;
        delete window.navigator.webdriver;
        
        // Prevenir re-definición
        const originalDefineProperty = Object.defineProperty;
        Object.defineProperty = function(obj, prop, descriptor) {
            if (prop === 'webdriver' && obj === navigator) {
                return obj;
            }
            return originalDefineProperty.apply(this, arguments);
        };
        
        // 2. Ocultar indicadores de automatización de Playwright
        Object.defineProperty(window, 'navigator', {
            value: new Proxy(navigator, {
                has: (target, key) => (key === 'webdriver' ? false : key in target),
                get: (target, key) => {
                    if (key === 'webdriver') return undefined;
                    const value = target[key];
                    return typeof value === 'function' ? value.bind(target) : value;
                }
            })
        });
        
        // ========== 5. Chrome Runtime Correcto ==========
        // Chrome runtime completo y realista con todas las propiedades esperadas
        if (!window.chrome) {
            window.chrome = {};
        }
        
        // chrome.runtime completo
        window.chrome.runtime = {
            onConnect: {
                addListener: function() {},
                removeListener: function() {},
                hasListener: function() { return false; }
            },
            onMessage: {
                addListener: function() {},
                removeListener: function() {},
                hasListener: function() { return false; }
            },
            connect: function() { return { postMessage: function() {}, disconnect: function() {} }; },
            sendMessage: function() {},
            getURL: function(path) { return 'chrome-extension://' + path; },
            id: 'abcdefghijklmnopqrstuvwxyz123456'
        };
        
        // chrome.loadTimes - tiempos de carga realistas
        const pageLoadStart = performance.timing.navigationStart || Date.now();
        window.chrome.loadTimes = function() {
            const now = Date.now() / 1000;
            const loadStart = pageLoadStart / 1000;
            const loadDuration = now - loadStart;
            
            return {
                commitLoadTime: loadStart + loadDuration * 0.1,
                connectionInfo: 'http/1.1',
                finishDocumentLoadTime: loadStart + loadDuration * 0.6,
                finishLoadTime: loadStart + loadDuration * 0.8,
                firstPaintAfterLoadTime: 0,
                firstPaintTime: loadStart + loadDuration * 0.4,
                navigationType: document.referrer ? 'Other' : 'Other',
                npnNegotiatedProtocol: 'unknown',
                requestTime: loadStart,
                startLoadTime: loadStart,
                wasAlternateProtocolAvailable: false,
                wasFetchedViaSpdy: false,
                wasNpnNegotiated: false
            };
        };
        
        // chrome.csi - Client Side Information
        window.chrome.csi = function() {
            const timing = performance.timing;
            return {
                startE: timing.navigationStart,
                onloadT: timing.loadEventEnd - timing.navigationStart,
                pageT: timing.loadEventEnd - timing.navigationStart,
                tran: 15
            };
        };
        
        // chrome.app - Chrome Apps API
        window.chrome.app = {
            isInstalled: false,
            InstallState: {
                DISABLED: 'disabled',
                INSTALLED: 'installed',
                NOT_INSTALLED: 'not_installed'
            },
            RunningState: {
                CANNOT_RUN: 'cannot_run',
                READY_TO_RUN: 'ready_to_run',
                RUNNING: 'running'
            },
            getDetails: function() { return null; },
            getIsInstalled: function() { return false; },
            install: function() {},
            running: {
                onLaunched: { addListener: function() {} },
                onRestarted: { addListener: function() {} },
                onTerminated: { addListener: function() {} }
            }
        };
        
        // chrome.runtime.id debe estar disponible
        Object.defineProperty(window.chrome.runtime, 'id', {
            value: 'abcdefghijklmnopqrstuvwxyz123456',
            writable: false,
            configurable: false
        });
        
        // ========== 6. Permisos Correctos ==========
        // Permisos API realista con todos los permisos comunes
        const originalQuery = window.navigator.permissions.query;
        const originalPermissions = window.navigator.permissions;
        
        window.navigator.permissions.query = function(parameters) {
            const permissionName = parameters.name;
            
            // Mapeo de permisos comunes
            const permissionStates = {
                'notifications': Notification.permission || 'default',
                'geolocation': 'prompt',
                'camera': 'prompt',
                'microphone': 'prompt',
                'persistent-storage': 'granted',
                'push': Notification.permission || 'default',
                'midi': 'granted',
                'clipboard-read': 'prompt',
                'clipboard-write': 'granted'
            };
            
            if (permissionStates.hasOwnProperty(permissionName)) {
                return Promise.resolve({
                    state: permissionStates[permissionName],
                    onchange: null
                });
            }
            
            // Para otros permisos, usar la implementación original
            return originalQuery.call(this, parameters);
        };
        
        // Mantener otros métodos de Permissions API
        Object.defineProperty(window.navigator.permissions, 'query', {
            value: window.navigator.permissions.query,
            writable: false,
            configurable: true
        });
        
        // ========== 4. Plugins y MimeTypes Creíbles ==========
        // Plugins realistas de Chrome con estructura completa y MimeTypes correctos
        const createPlugin = (name, filename, mimeTypes) => {
            const plugin = {
                description: '',
                filename: filename,
                length: mimeTypes.length,
                name: name
            };
            
            // Agregar MimeTypes como propiedades indexadas
            mimeTypes.forEach((mimeType, index) => {
                plugin[index] = mimeType;
            });
            
            // Métodos estándar de PluginArray
            plugin.item = function(index) {
                return this[index] || null;
            };
            plugin.namedItem = function(name) {
                for (let i = 0; i < this.length; i++) {
                    if (this[i] && this[i].type === name) {
                        return this[i];
                    }
                }
                return null;
            };
            
            return plugin;
        };
        
        const createMimeType = (type, suffixes, description) => {
            return {
                type: type,
                suffixes: suffixes,
                description: description,
                enabledPlugin: null
            };
        };
        
        Object.defineProperty(navigator, 'plugins', {
            get: () => {
                const plugins = [
                    createPlugin('Chrome PDF Plugin', 'internal-pdf-viewer', [
                        createMimeType('application/x-google-chrome-pdf', 'pdf', 'Portable Document Format')
                    ]),
                    createPlugin('Chrome PDF Viewer', 'mhjfbmdgcfjbbpaeojofohoefgiehjai', [
                        createMimeType('application/pdf', 'pdf', '')
                    ]),
                    createPlugin('Native Client', 'internal-nacl-plugin', [
                        createMimeType('application/x-nacl', '', 'Native Client Executable'),
                        createMimeType('application/x-pnacl', '', 'Portable Native Client Executable')
                    ])
                ];
                
                // Métodos de PluginArray
                plugins.item = function(index) {
                    return this[index] || null;
                };
                plugins.namedItem = function(name) {
                    for (let i = 0; i < this.length; i++) {
                        if (this[i] && this[i].name === name) {
                            return this[i];
                        }
                    }
                    return null;
                };
                plugins.refresh = function() {};
                
                return plugins;
            },
            configurable: true,
            enumerable: true
        });
        
        // MimeTypes array también debe ser consistente
        Object.defineProperty(navigator, 'mimeTypes', {
            get: () => {
                const mimeTypes = [];
                navigator.plugins.forEach(plugin => {
                    for (let i = 0; i < plugin.length; i++) {
                        mimeTypes.push(plugin[i]);
                    }
                });
                
                mimeTypes.item = function(index) {
                    return this[index] || null;
                };
                mimeTypes.namedItem = function(name) {
                    for (let i = 0; i < this.length; i++) {
                        if (this[i] && this[i].type === name) {
                            return this[i];
                        }
                    }
                    return null;
                };
                
                return mimeTypes;
            },
            configurable: true,
            enumerable: true
        });
        
        // 6. Languages realistas (Paraguay)
        Object.defineProperty(navigator, 'languages', {
            get: () => ['es-PY', 'es', 'en'],
            configurable: true
        });
        
        // ========== 2. Canvas Realista con Fingerprint Noise ==========
        // Canvas fingerprinting evasion mejorado con noise sutil y consistente
        const getImageData = CanvasRenderingContext2D.prototype.getImageData;
        const getImageDataOriginal = getImageData;
        
        // Generar un seed único para este contexto (consistente pero único)
        const canvasSeed = Math.random() * 0.0001;
        
        CanvasRenderingContext2D.prototype.getImageData = function() {
            const imageData = getImageDataOriginal.apply(this, arguments);
            
            // Aplicar noise sutil y consistente (no completamente aleatorio)
            const noiseAmount = 0.5 + canvasSeed;
            for (let i = 0; i < imageData.data.length; i += 4) {
                // Modificar solo ligeramente los valores RGB
                const noise = Math.sin(i * 0.01) * noiseAmount;
                imageData.data[i] = Math.max(0, Math.min(255, imageData.data[i] + noise));     // R
                imageData.data[i + 1] = Math.max(0, Math.min(255, imageData.data[i + 1] + noise * 0.8)); // G
                imageData.data[i + 2] = Math.max(0, Math.min(255, imageData.data[i + 2] + noise * 0.6)); // B
                // Alpha no se modifica para mantener transparencia
            }
            return imageData;
        };
        
        // También modificar toDataURL y toBlob para consistencia
        const toDataURL = CanvasRenderingContext2D.prototype.toDataURL;
        CanvasRenderingContext2D.prototype.toDataURL = function() {
            const result = toDataURL.apply(this, arguments);
            // El noise ya está aplicado en getImageData, esto es solo para consistencia
            return result;
        };
        
        // ========== 3. WebGL Real con Fingerprint Evasion ==========
        // WebGL fingerprinting evasion mejorado - valores realistas de GPU Mac
        const getParameter = WebGLRenderingContext.prototype.getParameter;
        const getParameterOriginal = getParameter;
        
        // Valores realistas para Mac con Intel GPU
        const webglVendor = 'Intel Inc.';
        const webglRenderer = 'Intel Iris OpenGL Engine';
        const webglVersion = 'WebGL 2.0';
        const webglShadingLanguageVersion = 'WebGL GLSL ES 3.00';
        
        WebGLRenderingContext.prototype.getParameter = function(parameter) {
            // UNMASKED_VENDOR_WEBGL (0x9245 = 37445)
            if (parameter === 0x9245 || parameter === 37445) {
                return webglVendor;
            }
            // UNMASKED_RENDERER_WEBGL (0x9246 = 37446)
            if (parameter === 0x9246 || parameter === 37446) {
                return webglRenderer;
            }
            // VENDOR (0x1F00 = 7936)
            if (parameter === 0x1F00 || parameter === 7936) {
                return webglVendor;
            }
            // RENDERER (0x1F01 = 7937)
            if (parameter === 0x1F01 || parameter === 7937) {
                return webglRenderer;
            }
            // VERSION (0x1F02 = 7938)
            if (parameter === 0x1F02 || parameter === 7938) {
                return webglVersion;
            }
            // SHADING_LANGUAGE_VERSION (0x8B8C = 35724)
            if (parameter === 0x8B8C || parameter === 35724) {
                return webglShadingLanguageVersion;
            }
            
            // Para otros parámetros, aplicar noise sutil si es numérico
            const result = getParameterOriginal.apply(this, arguments);
            if (typeof result === 'number' && result > 0) {
                // Aplicar variación mínima (0.1% de noise)
                return result * (1 + (Math.random() - 0.5) * 0.001);
            }
            return result;
        };
        
        // También interceptar getExtension para WebGL2
        if (window.WebGL2RenderingContext) {
            const getParameter2 = WebGL2RenderingContext.prototype.getParameter;
            WebGL2RenderingContext.prototype.getParameter = WebGLRenderingContext.prototype.getParameter;
        }
        
        // 9. AudioContext fingerprinting evasion mejorado
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        if (AudioContext) {
            const originalCreateAnalyser = AudioContext.prototype.createAnalyser;
            AudioContext.prototype.createAnalyser = function() {
                const analyser = originalCreateAnalyser.apply(this, arguments);
                const originalGetFloatFrequencyData = analyser.getFloatFrequencyData;
                analyser.getFloatFrequencyData = function(array) {
                    originalGetFloatFrequencyData.apply(this, arguments);
                    const noise = Math.random() * 0.0001;
                    for (let i = 0; i < array.length; i++) {
                        array[i] += noise;
                    }
                };
                return analyser;
            };
        }
        
        // 10. Battery API
        if (navigator.getBattery) {
            navigator.getBattery = () => Promise.resolve({
                charging: true,
                chargingTime: 0,
                dischargingTime: Infinity,
                level: 0.85 + Math.random() * 0.15,
            });
        }
        
        // 11. Hardware concurrency (CPU cores)
        Object.defineProperty(navigator, 'hardwareConcurrency', {
            get: () => 8,
            configurable: true
        });
        
        // 12. Device memory
        Object.defineProperty(navigator, 'deviceMemory', {
            get: () => 8,
            configurable: true
        });
        
        // 13. Platform
        Object.defineProperty(navigator, 'platform', {
            get: () => 'MacIntel',
            configurable: true
        });
        
        // 14. Vendor
        Object.defineProperty(navigator, 'vendor', {
            get: () => 'Google Inc.',
            configurable: true
        });
        
        // 15. Max touch points
        Object.defineProperty(navigator, 'maxTouchPoints', {
            get: () => 0,
            configurable: true
        });
        
        // 16. Connection API
        Object.defineProperty(navigator, 'connection', {
            get: () => ({
                effectiveType: '4g',
                rtt: 50,
                downlink: 10,
                saveData: false,
                onchange: null,
                addEventListener: () => {},
                removeEventListener: () => {},
                dispatchEvent: () => true
            }),
            configurable: true
        });
        
        // 17. Notification
        const Notification = window.Notification;
        if (Notification) {
            Object.defineProperty(Notification, 'permission', {
                get: () => 'default',
                configurable: true
            });
        }
        
        // 18. Override toString methods
        window.navigator.webdriver.toString = () => '[object Navigator]';
        
        // 19. Remove automation indicators específicos de Playwright
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Array;
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Promise;
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Symbol;
        delete window.__playwright;
        delete window.__pw_manual;
        delete window.__pw_original;
        
        // 20. Fingerprinting de pantalla
        Object.defineProperty(screen, 'availWidth', {
            get: () => 1920,
            configurable: true
        });
        Object.defineProperty(screen, 'availHeight', {
            get: () => 1080,
            configurable: true
        });
        Object.defineProperty(screen, 'width', {
            get: () => 1920,
            configurable: true
        });
        Object.defineProperty(screen, 'height', {
            get: () => 1080,
            configurable: true
        });
        
        // 21. Performance API - hacer que parezca más real
        const originalNow = performance.now;
        let baseTime = Date.now() - Math.random() * 1000;
        performance.now = function() {
            return originalNow.call(performance) + (Date.now() - baseTime);
        };
        
        // 22. Ocultar indicadores de headless
        Object.defineProperty(navigator, 'userAgent', {
            get: () => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            configurable: true
        });
        
        // 23. Propiedades adicionales para TikTok
        Object.defineProperty(navigator, 'doNotTrack', {
            get: () => '1',
            configurable: true
        });
        
        // 24. MediaDevices API
        if (navigator.mediaDevices) {
            Object.defineProperty(navigator.mediaDevices, 'enumerateDevices', {
                value: async function() {
                    return [
                        {
                            deviceId: 'default',
                            kind: 'audioinput',
                            label: 'Default - Built-in Microphone',
                            groupId: 'group1'
                        },
                        {
                            deviceId: 'default',
                            kind: 'audiooutput',
                            label: 'Default - Built-in Output',
                            groupId: 'group1'
                        },
                        {
                            deviceId: 'default',
                            kind: 'videoinput',
                            label: 'FaceTime HD Camera',
                            groupId: 'group1'
                        }
                    ];
                },
                configurable: true
            });
        }
        
        // ========== 7. IP Leak WebRTC Real - Prevención Completa ==========
        // Prevenir completamente las fugas de IP a través de WebRTC (crítico para TikTok)
        const originalRTCPeerConnection = window.RTCPeerConnection || 
                                         window.webkitRTCPeerConnection || 
                                         window.mozRTCPeerConnection;
        
        if (originalRTCPeerConnection) {
            const RTCPeerConnectionWrapper = function(...args) {
                const pc = new originalRTCPeerConnection(...args);
                
                // Función para limpiar SDP de información de IP
                const cleanSDP = (sdp) => {
                    if (!sdp) return sdp;
                    
                    // Eliminar todas las líneas de candidatos (contienen IPs)
                    sdp = sdp.replace(/a=candidate.*\r\n/g, '');
                    
                    // Eliminar información de host (c=IN IP4/IP6)
                    sdp = sdp.replace(/c=IN IP4 [0-9.]+/g, 'c=IN IP4 0.0.0.0');
                    sdp = sdp.replace(/c=IN IP6 [0-9a-f:]+/g, 'c=IN IP6 ::');
                    
                    // Eliminar información de conexión
                    sdp = sdp.replace(/a=rtcp:[0-9]+ IN IP4 [0-9.]+/g, 'a=rtcp:9 IN IP4 0.0.0.0');
                    sdp = sdp.replace(/a=rtcp:[0-9]+ IN IP6 [0-9a-f:]+/g, 'a=rtcp:9 IN IP6 ::');
                    
                    // Eliminar información de ICE
                    sdp = sdp.replace(/a=ice-ufrag:.*\r\n/g, '');
                    sdp = sdp.replace(/a=ice-pwd:.*\r\n/g, '');
                    
                    return sdp;
                };
                
                // Interceptar createOffer
                const originalCreateOffer = pc.createOffer.bind(pc);
                pc.createOffer = function(...args) {
                    return originalCreateOffer.apply(this, args).then(offer => {
                        if (offer && offer.sdp) {
                            offer.sdp = cleanSDP(offer.sdp);
                        }
                        return offer;
                    }).catch(err => {
                        console.error('createOffer error:', err);
                        throw err;
                    });
                };
                
                // Interceptar createAnswer
                const originalCreateAnswer = pc.createAnswer.bind(pc);
                pc.createAnswer = function(...args) {
                    return originalCreateAnswer.apply(this, args).then(answer => {
                        if (answer && answer.sdp) {
                            answer.sdp = cleanSDP(answer.sdp);
                        }
                        return answer;
                    }).catch(err => {
                        console.error('createAnswer error:', err);
                        throw err;
                    });
                };
                
                // Interceptar setLocalDescription
                const originalSetLocalDescription = pc.setLocalDescription.bind(pc);
                pc.setLocalDescription = function(description) {
                    if (description && description.sdp) {
                        description.sdp = cleanSDP(description.sdp);
                    }
                    return originalSetLocalDescription.call(this, description);
                };
                
                // Interceptar setRemoteDescription
                const originalSetRemoteDescription = pc.setRemoteDescription.bind(pc);
                pc.setRemoteDescription = function(description) {
                    if (description && description.sdp) {
                        description.sdp = cleanSDP(description.sdp);
                    }
                    return originalSetRemoteDescription.call(this, description);
                };
                
                // Prevenir que getStats revele información de IP
                const originalGetStats = pc.getStats.bind(pc);
                pc.getStats = function(selector, successCallback, failureCallback) {
                    return originalGetStats.call(this, selector).then(stats => {
                        // Filtrar estadísticas que puedan revelar IPs
                        const filteredStats = new Map();
                        stats.forEach((stat, id) => {
                            const report = {};
                            stat.names().forEach(name => {
                                const value = stat.stat(name);
                                // Excluir campos relacionados con IPs
                                if (!['localCandidateId', 'remoteCandidateId', 'candidateType', 
                                      'ip', 'address', 'port', 'relatedAddress', 'relatedPort'].includes(name)) {
                                    report[name] = value;
                                }
                            });
                            filteredStats.set(id, report);
                        });
                        return filteredStats;
                    });
                };
                
                // Interceptar addIceCandidate para prevenir leaks
                const originalAddIceCandidate = pc.addIceCandidate.bind(pc);
                pc.addIceCandidate = function(candidate) {
                    // Modificar candidato para ocultar IP si existe
                    if (candidate && candidate.candidate) {
                        candidate.candidate = candidate.candidate.replace(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/g, '0.0.0.0');
                        candidate.candidate = candidate.candidate.replace(/[0-9a-f:]+::[0-9a-f:]+/g, '::');
                    }
                    return originalAddIceCandidate.call(this, candidate);
                };
                
                return pc;
            };
            
            // Copiar propiedades del prototipo original
            RTCPeerConnectionWrapper.prototype = originalRTCPeerConnection.prototype;
            RTCPeerConnectionWrapper.prototype.constructor = RTCPeerConnectionWrapper;
            
            // Reemplazar constructores
            window.RTCPeerConnection = RTCPeerConnectionWrapper;
            if (window.webkitRTCPeerConnection) {
                window.webkitRTCPeerConnection = RTCPeerConnectionWrapper;
            }
            if (window.mozRTCPeerConnection) {
                window.mozRTCPeerConnection = RTCPeerConnectionWrapper;
            }
        }
        
        // También prevenir acceso directo a getLocalStreams/getRemoteStreams que pueden revelar IPs
        if (window.MediaStreamTrack && window.MediaStreamTrack.prototype) {
            const originalGetSettings = window.MediaStreamTrack.prototype.getSettings;
            if (originalGetSettings) {
                window.MediaStreamTrack.prototype.getSettings = function() {
                    const settings = originalGetSettings.call(this);
                    // Eliminar información de dispositivo que pueda ser única
                    if (settings.deviceId) {
                        settings.deviceId = 'default';
                    }
                    return settings;
                };
            }
        }
        
        // ========== 8. Prevenir detección de automation mediante window properties ==========
        Object.defineProperty(window, 'outerHeight', {
            get: () => 1080,
            configurable: true
        });
        Object.defineProperty(window, 'outerWidth', {
            get: () => 1920,
            configurable: true
        });
        
        // ========== 9. Técnica específica para TikTok: ocultar automation en document ==========
        Object.defineProperty(document, '$cdc_asdjflasutopfhvcZLmcfl_', {
            get: () => undefined,
            configurable: true
        });
        Object.defineProperty(document, '$chrome_asyncScriptInfo', {
            get: () => undefined,
            configurable: true
        });
        
        // 29. Prevenir detección mediante timing attacks
        const originalSetTimeout = window.setTimeout;
        const originalSetInterval = window.setInterval;
        window.setTimeout = function(...args) {
            if (args[1] && args[1] < 4) {
                args[1] = 4 + Math.random() * 2;
            }
            return originalSetTimeout.apply(this, args);
        };
        window.setInterval = function(...args) {
            if (args[1] && args[1] < 4) {
                args[1] = 4 + Math.random() * 2;
            }
            return originalSetInterval.apply(this, args);
        };
        
        // 30. Ocultar propiedades de Playwright/Puppeteer
        Object.keys(window).forEach(key => {
            if (key.includes('__playwright') || key.includes('__pw') || key.includes('__puppeteer')) {
                delete window[key];
            }
        });
        
        // 31. Fingerprinting de fonts más realista
        const originalOffsetWidth = Object.getOwnPropertyDescriptor(HTMLElement.prototype, 'offsetWidth').get;
        Object.defineProperty(HTMLElement.prototype, 'offsetWidth', {
            get: function() {
                const width = originalOffsetWidth.call(this);
                return width + (Math.random() < 0.1 ? Math.random() * 0.1 : 0);
            },
            configurable: true
        });
        
        // 32. Prevenir detección mediante Object.getOwnPropertyNames
        const originalGetOwnPropertyNames = Object.getOwnPropertyNames;
        Object.getOwnPropertyNames = function(obj) {
            const names = originalGetOwnPropertyNames(obj);
            return names.filter(name => !name.includes('__playwright') && !name.includes('__pw'));
        };
        
        // 33. Técnica avanzada: modificar toString para ocultar automation
        Function.prototype.toString = new Proxy(Function.prototype.toString, {
            apply: function(target, thisArg, argumentsList) {
                const str = target.apply(thisArg, argumentsList);
                if (str.includes('native code') || str.includes('[native code]')) {
                    return str;
                }
                if (str.includes('playwright') || str.includes('puppeteer') || str.includes('webdriver')) {
                    return 'function() { [native code] }';
                }
                return str;
            }
        });
        
        // 34. Prevenir detección mediante hasOwnProperty
        const originalHasOwnProperty = Object.prototype.hasOwnProperty;
        Object.prototype.hasOwnProperty = function(prop) {
            if (prop === 'webdriver' || prop.includes('__playwright') || prop.includes('__pw')) {
                return false;
            }
            return originalHasOwnProperty.call(this, prop);
        };
        
        // ========== 10. Técnica específica TikTok: modificar navigator properties dinámicamente ==========
        setInterval(() => {
            if (navigator.webdriver !== undefined) {
                Object.defineProperty(navigator, 'webdriver', {
                    get: () => undefined,
                    configurable: true
                });
            }
        }, 100);
        
        // ============================================
        // RESUMEN DE OBJETIVOS IMPLEMENTADOS:
        // ============================================
        // ✅ 1. WebGL Real - Implementado con valores realistas de GPU Mac
        // ✅ 2. Canvas Realista - Implementado con fingerprint noise sutil y consistente
        // ✅ 3. Plugins y MimeTypes Creíbles - Implementado con estructura completa de Chrome
        // ✅ 4. navigator.webdriver = undefined - Implementado con protección persistente
        // ✅ 5. Chrome Runtime Correcto - Implementado con todas las propiedades esperadas
        // ✅ 6. Permisos Correctos - Implementado con mapeo completo de permisos
        // ✅ 7. Delays Humanos - Implementado en route handler y funciones de comportamiento
        // ✅ 8. Interacción Humana (scroll/mouse) - Implementado con curvas Bezier y variaciones
        // ✅ 9. Fingerprint Noise - Implementado en Canvas, WebGL y AudioContext
        // ✅ 10. IP Leak WebRTC Real - Implementado con prevención completa de leaks
        // ============================================
    `);

    let dataObtained = false;

    // Interceptar requests para modificar headers y agregar delays humanos
    let requestCount = 0;
    await page.route('**/*', async (route) => {
        requestCount++;

        // Delay variable entre requests para simular comportamiento humano
        // Los primeros requests son más rápidos, luego se vuelven más lentos
        if (requestCount > 1) {
            const delay = requestCount < 5 ?
                Math.random() * 50 : // Primeros requests rápidos
                Math.random() * 200 + 100; // Requests posteriores más lentos
            await new Promise(resolve => setTimeout(resolve, delay));
        }

        const headers = {
            ...route.request().headers(),
            'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"macOS"',
        };

        // Agregar referer realista para requests internos
        if (route.request().url().includes('tiktok.com') && !headers['Referer']) {
            headers['Referer'] = 'https://www.tiktok.com/';
        }

        route.continue({ headers });
    });

    // Interceptar la API real ANTES de navegar
    page.on('response', async (response) => {
        if (dataObtained) return; // Ya obtuvimos los datos, ignorar más respuestas

        const url = response.url();
        if (url.includes('/api/post/item_list')) {
            try {
                const data = await response.json();
                console.log('✅ API encontrada:', url);
                console.log(JSON.stringify(data, null, 2));

                // Marcar que obtuvimos los datos y cerrar
                dataObtained = true;
                console.log('✅ Datos obtenidos exitosamente. Cerrando navegador...');
                await browser.close();
                process.exit(0);
            } catch (e) {
                console.log('⚠️ Respuesta no JSON:', url);
            }
        }
    });

    // Función avanzada para simular movimiento de mouse humano (curva bezier mejorada)
    const simulateHumanMouseMove = async (fromX, fromY, toX, toY, speed = 'normal') => {
        // Velocidades variables: slow, normal, fast
        const speedMultipliers = { slow: 1.5, normal: 1.0, fast: 0.7 };
        const multiplier = speedMultipliers[speed] || 1.0;

        // Número de pasos variable según distancia y velocidad
        const distance = Math.sqrt(Math.pow(toX - fromX, 2) + Math.pow(toY - fromY, 2));
        const baseSteps = Math.max(15, Math.min(50, Math.floor(distance / 10)));
        const steps = Math.floor(baseSteps * multiplier) + Math.floor(Math.random() * 10);

        // Punto de control aleatorio para curva bezier más natural
        const controlX = (fromX + toX) / 2 + (Math.random() - 0.5) * distance * 0.3;
        const controlY = (fromY + toY) / 2 + (Math.random() - 0.5) * distance * 0.3;

        for (let i = 0; i <= steps; i++) {
            const t = i / steps;
            // Curva bezier cuadrática con punto de control
            const x = Math.pow(1 - t, 2) * fromX + 2 * (1 - t) * t * controlX + Math.pow(t, 2) * toX;
            const y = Math.pow(1 - t, 2) * fromY + 2 * (1 - t) * t * controlY + Math.pow(t, 2) * toY;

            await page.mouse.move(Math.round(x), Math.round(y), { steps: 1 });

            // Delay variable con micro-pausas ocasionales
            const delay = 8 + Math.random() * 15;
            if (Math.random() < 0.1) {
                // Micro-pausa ocasional (humano pensando)
                await page.waitForTimeout(delay + 50 + Math.random() * 100);
            } else {
                await page.waitForTimeout(delay);
            }
        }
    };

    // Función para simular scroll humano con variaciones naturales
    const humanScroll = async (direction = 'down', amount = 300) => {
        const scrollSteps = 5 + Math.floor(Math.random() * 5);
        const stepAmount = amount / scrollSteps;

        for (let i = 0; i < scrollSteps; i++) {
            const currentAmount = stepAmount + (Math.random() - 0.5) * stepAmount * 0.3;
            await page.mouse.wheel(0, direction === 'down' ? currentAmount : -currentAmount);

            // Delay variable entre scrolls (más lento al inicio y final)
            const progress = i / scrollSteps;
            const delay = progress < 0.2 || progress > 0.8 ?
                150 + Math.random() * 200 : // Más lento al inicio/final
                50 + Math.random() * 100;   // Más rápido en el medio
            await page.waitForTimeout(delay);
        }
    };

    // Función para simular pausa de lectura humana
    const humanPause = async (baseTime = 2000) => {
        // Distribución de tiempos más realista (algunas pausas largas ocasionales)
        const pauseTime = Math.random() < 0.2 ?
            baseTime * 2 + Math.random() * baseTime * 2 : // Pausa larga ocasional
            baseTime + Math.random() * baseTime; // Pausa normal
        await page.waitForTimeout(pauseTime);
    };

    // Obtener viewport size (necesario para ambos modos)
    const viewport = page.viewportSize();

    // PASO 1: Navegar primero a la página principal de TikTok (solo si no está en modo directo)
    if (!skipFrontPage) {
        console.log('🌐 Navegando a la página principal de TikTok...');
        await page.goto('https://www.tiktok.com', {
            waitUntil: 'domcontentloaded',
            timeout: 30000
        });

        // Esperar a que cargue la página principal
        console.log('⏳ Esperando a que cargue la página principal...');
        await page.waitForTimeout(3000 + Math.random() * 2000);

        // Simular comportamiento humano en la página principal
        console.log('🖱️ Simulando comportamiento humano en la página principal...');

        // Movimiento inicial del mouse en la página principal
        await simulateHumanMouseMove(
            viewport.width / 2,
            viewport.height / 2,
            100 + Math.random() * 200,
            100 + Math.random() * 200
        );

        // Scroll humano en la página principal con nueva función mejorada
        console.log('📜 Haciendo scroll en la página principal...');
        for (let i = 0; i < 3; i++) {
            const scrollAmount = 300 + Math.random() * 400;
            await humanScroll('down', scrollAmount);

            // Pequeño movimiento de mouse durante scroll con velocidad variable
            const currentX = 100 + Math.random() * 500;
            const currentY = 100 + Math.random() * 500;
            const speed = Math.random() < 0.3 ? 'slow' : Math.random() < 0.7 ? 'normal' : 'fast';
            await simulateHumanMouseMove(
                currentX,
                currentY,
                currentX + (Math.random() - 0.5) * 100,
                currentY + (Math.random() - 0.5) * 100,
                speed
            );

            // Pausa variable entre scrolls
            await humanPause(1000);
        }

        // Simular pausa de lectura en la página principal
        console.log('⏸️ Simulando lectura en la página principal...');
        await humanPause(2000);
    }

    // PASO 2: Navegar al perfil específico
    console.log(`👤 Navegando al perfil @${profileUsername}...`);
    await page.goto(`https://www.tiktok.com/@${profileUsername}`, {
        waitUntil: 'domcontentloaded',
        timeout: 30000
    });

    // Esperar a que cargue el perfil
    console.log('⏳ Esperando a que cargue el perfil...');
    await page.waitForTimeout(3000 + Math.random() * 2000);

    // Simular comportamiento humano en el perfil
    console.log('🖱️ Simulando comportamiento humano en el perfil...');

    // Movimiento inicial del mouse en el perfil
    await simulateHumanMouseMove(
        viewport.width / 2,
        viewport.height / 2,
        100 + Math.random() * 200,
        100 + Math.random() * 200
    );

    // Scroll humano con variaciones en el perfil usando función mejorada
    console.log('📜 Haciendo scroll en el perfil...');
    for (let i = 0; i < 5; i++) {
        const scrollAmount = 300 + Math.random() * 400;
        await humanScroll('down', scrollAmount);

        // Movimiento de mouse durante scroll con velocidad variable
        const currentX = 100 + Math.random() * 500;
        const currentY = 100 + Math.random() * 500;
        const speed = Math.random() < 0.3 ? 'slow' : Math.random() < 0.7 ? 'normal' : 'fast';
        await simulateHumanMouseMove(
            currentX,
            currentY,
            currentX + (Math.random() - 0.5) * 100,
            currentY + (Math.random() - 0.5) * 100,
            speed
        );

        // Pausa variable entre scrolls
        await humanPause(800);
    }

    // Simular pausa de lectura en el perfil
    await humanPause(2000);

    // Scroll adicional en el perfil con función mejorada
    await humanScroll('down', 500);
    await humanPause(1500);

    // Esperar más tiempo para capturar todas las respuestas
    console.log('⏳ Esperando respuestas de API...');

    // Esperar hasta 45 segundos para obtener los datos (más tiempo para TikTok)
    const maxWaitTime = 45000;
    const startTime = Date.now();

    while (!dataObtained && (Date.now() - startTime) < maxWaitTime) {
        // Continuar haciendo scroll humano para activar más requests
        await humanScroll('down', 200 + Math.random() * 200);

        // Movimiento ocasional de mouse
        if (Math.random() < 0.3) {
            const currentX = 100 + Math.random() * 500;
            const currentY = 100 + Math.random() * 500;
            await simulateHumanMouseMove(
                currentX,
                currentY,
                currentX + (Math.random() - 0.5) * 50,
                currentY + (Math.random() - 0.5) * 50,
                'normal'
            );
        }

        // Pausa variable entre acciones
        await humanPause(500 + Math.random() * 1000);
    }

    // Si no se obtuvieron datos, cerrar igual
    if (!dataObtained) {
        console.log('⚠️ No se obtuvieron datos de la API después de 30 segundos.');
        console.log('Cerrando navegador...');
        await browser.close();
        process.exit(1);
    }

})();
