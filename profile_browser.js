/**
 * Script de automatización para TikTok - Solo captura item_list endpoint
 * Retorna JSON por stdout para ser usado desde Ruby/Rails
 * 
 * Uso:
 *   node profile_browser.js [--profile=username] [--direct] [--proxy-server=host] [--proxy-port=port] [--proxy-user=user]
 * 
 * Opciones de proxy:
 *   --proxy-server: Dirección del servidor proxy (ej: proxy.scrape.do)
 *   --proxy-port: Puerto del proxy (ej: 8080)
 *   --proxy-user: Usuario del proxy (ej: ed138ed418924138923ced2b81e04d53)
 * 
 * Retorna JSON por stdout y sale con código 0 si encuentra datos, 1 si no
 */

const { chromium } = require('playwright');
const path = require('path');
const os = require('os');

(async () => {
    try {
        // Parsear argumentos de línea de comandos
        const args = process.argv.slice(2);
        const skipFrontPage = args.includes('--direct') || args.includes('--skip-front');
        const profileUsername = args.find(arg => arg.startsWith('--profile='))?.split('=')[1] || 'enlatitud25';

        // Parsear argumentos de proxy
        const proxyServer = args.find(arg => arg.startsWith('--proxy-server='))?.split('=')[1];
        const proxyPort = args.find(arg => arg.startsWith('--proxy-port='))?.split('=')[1];
        const proxyUser = args.find(arg => arg.startsWith('--proxy-user='))?.split('=')[1];

        // Configurar proxy si se proporcionan los parámetros
        let proxyConfig = null;
        if (proxyServer && proxyPort) {
            proxyConfig = {
                server: `http://${proxyServer}:${proxyPort}`,
            };
            if (proxyUser) {
                proxyConfig.username = proxyUser;
                // Si el proxy requiere password, se puede agregar con --proxy-password
                const proxyPassword = args.find(arg => arg.startsWith('--proxy-password='))?.split('=')[1];
                if (proxyPassword) {
                    proxyConfig.password = proxyPassword;
                }
            }
        }

        // Crear un directorio de perfil persistente
        const userDataDir = path.join(os.tmpdir(), 'playwright-chrome-profile-' + Date.now());

        // Configurar browser con técnicas de evasión (igual que test.js)
        const browserOptions = {
            headless: false,
            channel: 'chrome',
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
            userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            locale: 'es-PY',
            timezoneId: 'America/Asuncion',
            permissions: ['geolocation', 'notifications'],
            geolocation: { latitude: -25.2637, longitude: -57.5759 },
            colorScheme: 'light',
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
            ignoreHTTPSErrors: false,
            javaScriptEnabled: true,
        };

        // Agregar configuración de proxy si está disponible
        if (proxyConfig) {
            browserOptions.proxy = proxyConfig;
        }

        const browser = await chromium.launchPersistentContext(userDataDir, browserOptions);

        const page = browser.pages()[0] || await browser.newPage();

        // Script avanzado de evasión COMPLETO (copiado de test.js)
        await page.addInitScript(`
        // ============================================
        // OBJETIVO: SIMULACIÓN COMPLETA DE NAVEGADOR REAL
        // ============================================
        
        // ========== 1. navigator.webdriver = undefined ==========
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
            configurable: true,
            enumerable: false
        });
        delete window.navigator.__proto__.webdriver;
        delete window.navigator.webdriver;

        const originalDefineProperty = Object.defineProperty;
        Object.defineProperty = function(obj, prop, descriptor) {
            if (prop === 'webdriver' && obj === navigator) {
                return obj;
            }
            return originalDefineProperty.apply(this, arguments);
        };

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
        if (!window.chrome) {
            window.chrome = {};
        }
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

        window.chrome.csi = function() {
            const timing = performance.timing;
            return {
                startE: timing.navigationStart,
                onloadT: timing.loadEventEnd - timing.navigationStart,
                pageT: timing.loadEventEnd - timing.navigationStart,
                tran: 15
            };
        };

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

        Object.defineProperty(window.chrome.runtime, 'id', {
            value: 'abcdefghijklmnopqrstuvwxyz123456',
            writable: false,
            configurable: false
        });
        
        // ========== 6. Permisos Correctos ==========
        const originalQuery = window.navigator.permissions.query;
        window.navigator.permissions.query = function(parameters) {
            const permissionName = parameters.name;
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
            return originalQuery.call(this, parameters);
        };

        Object.defineProperty(window.navigator.permissions, 'query', {
            value: window.navigator.permissions.query,
            writable: false,
            configurable: true
        });
        
        // ========== 4. Plugins y MimeTypes Creíbles ==========
        const createPlugin = (name, filename, mimeTypes) => {
            const plugin = {
                description: '',
                filename: filename,
                length: mimeTypes.length,
                name: name
            };
            mimeTypes.forEach((mimeType, index) => {
                plugin[index] = mimeType;
            });
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

        Object.defineProperty(navigator, 'languages', {
            get: () => ['es-PY', 'es', 'en'],
            configurable: true
        });
        
        // ========== 2. Canvas Realista con Fingerprint Noise ==========
        const getImageData = CanvasRenderingContext2D.prototype.getImageData;
        const getImageDataOriginal = getImageData;
        const canvasSeed = Math.random() * 0.0001;
        
        CanvasRenderingContext2D.prototype.getImageData = function() {
            const imageData = getImageDataOriginal.apply(this, arguments);
            const noiseAmount = 0.5 + canvasSeed;
            for (let i = 0; i < imageData.data.length; i += 4) {
                const noise = Math.sin(i * 0.01) * noiseAmount;
                imageData.data[i] = Math.max(0, Math.min(255, imageData.data[i] + noise));
                imageData.data[i + 1] = Math.max(0, Math.min(255, imageData.data[i + 1] + noise * 0.8));
                imageData.data[i + 2] = Math.max(0, Math.min(255, imageData.data[i + 2] + noise * 0.6));
            }
            return imageData;
        };

        const toDataURL = CanvasRenderingContext2D.prototype.toDataURL;
        CanvasRenderingContext2D.prototype.toDataURL = function() {
            const result = toDataURL.apply(this, arguments);
            return result;
        };
        
        // ========== 3. WebGL Real con Fingerprint Evasion ==========
        const getParameter = WebGLRenderingContext.prototype.getParameter;
        const getParameterOriginal = getParameter;
        const webglVendor = 'Intel Inc.';
        const webglRenderer = 'Intel Iris OpenGL Engine';
        const webglVersion = 'WebGL 2.0';
        const webglShadingLanguageVersion = 'WebGL GLSL ES 3.00';
        
        WebGLRenderingContext.prototype.getParameter = function(parameter) {
            if (parameter === 0x9245 || parameter === 37445) return webglVendor;
            if (parameter === 0x9246 || parameter === 37446) return webglRenderer;
            if (parameter === 0x1F00 || parameter === 7936) return webglVendor;
            if (parameter === 0x1F01 || parameter === 7937) return webglRenderer;
            if (parameter === 0x1F02 || parameter === 7938) return webglVersion;
            if (parameter === 0x8B8C || parameter === 35724) return webglShadingLanguageVersion;
            const result = getParameterOriginal.apply(this, arguments);
            if (typeof result === 'number' && result > 0) {
                return result * (1 + (Math.random() - 0.5) * 0.001);
            }
            return result;
        };

        if (window.WebGL2RenderingContext) {
            WebGL2RenderingContext.prototype.getParameter = WebGLRenderingContext.prototype.getParameter;
        }
        
        // 9. AudioContext fingerprinting evasion
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
        
        // 10-17. Otras propiedades
        if (navigator.getBattery) {
            navigator.getBattery = () => Promise.resolve({
                charging: true,
                chargingTime: 0,
                dischargingTime: Infinity,
                level: 0.85 + Math.random() * 0.15,
            });
        }

        Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8, configurable: true });
        Object.defineProperty(navigator, 'deviceMemory', { get: () => 8, configurable: true });
        Object.defineProperty(navigator, 'platform', { get: () => 'MacIntel', configurable: true });
        Object.defineProperty(navigator, 'vendor', { get: () => 'Google Inc.', configurable: true });
        Object.defineProperty(navigator, 'maxTouchPoints', { get: () => 0, configurable: true });
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

        const Notification = window.Notification;
        if (Notification) {
            Object.defineProperty(Notification, 'permission', {
                get: () => 'default',
                configurable: true
            });
        }

        window.navigator.webdriver.toString = () => '[object Navigator]';
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Array;
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Promise;
        delete window.cdc_adoQpoasnfa76pfcZLmcfl_Symbol;
        delete window.__playwright;
        delete window.__pw_manual;
        delete window.__pw_original;

        Object.defineProperty(screen, 'availWidth', { get: () => 1920, configurable: true });
        Object.defineProperty(screen, 'availHeight', { get: () => 1080, configurable: true });
        Object.defineProperty(screen, 'width', { get: () => 1920, configurable: true });
        Object.defineProperty(screen, 'height', { get: () => 1080, configurable: true });

        const originalNow = performance.now;
        let baseTime = Date.now() - Math.random() * 1000;
        performance.now = function() {
            return originalNow.call(performance) + (Date.now() - baseTime);
        };

        Object.defineProperty(navigator, 'userAgent', {
            get: () => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            configurable: true
        });

        Object.defineProperty(navigator, 'doNotTrack', { get: () => '1', configurable: true });

        if (navigator.mediaDevices) {
            Object.defineProperty(navigator.mediaDevices, 'enumerateDevices', {
                value: async function() {
                    return [
                        { deviceId: 'default', kind: 'audioinput', label: 'Default - Built-in Microphone', groupId: 'group1' },
                        { deviceId: 'default', kind: 'audiooutput', label: 'Default - Built-in Output', groupId: 'group1' },
                        { deviceId: 'default', kind: 'videoinput', label: 'FaceTime HD Camera', groupId: 'group1' }
                    ];
                },
                configurable: true
            });
        }
        
        // ========== 7. IP Leak WebRTC Real - Prevención Completa ==========
        const originalRTCPeerConnection = window.RTCPeerConnection || window.webkitRTCPeerConnection || window.mozRTCPeerConnection;
        
        if (originalRTCPeerConnection) {
            const RTCPeerConnectionWrapper = function(...args) {
                const pc = new originalRTCPeerConnection(...args);
                const cleanSDP = (sdp) => {
                    if (!sdp) return sdp;
                    sdp = sdp.replace(/a=candidate.*\r\n/g, '');
                    sdp = sdp.replace(/c=IN IP4 [0-9.]+/g, 'c=IN IP4 0.0.0.0');
                    sdp = sdp.replace(/c=IN IP6 [0-9a-f:]+/g, 'c=IN IP6 ::');
                    sdp = sdp.replace(/a=rtcp:[0-9]+ IN IP4 [0-9.]+/g, 'a=rtcp:9 IN IP4 0.0.0.0');
                    sdp = sdp.replace(/a=rtcp:[0-9]+ IN IP6 [0-9a-f:]+/g, 'a=rtcp:9 IN IP6 ::');
                    sdp = sdp.replace(/a=ice-ufrag:.*\r\n/g, '');
                    sdp = sdp.replace(/a=ice-pwd:.*\r\n/g, '');
                    return sdp;
                };
                
                const originalCreateOffer = pc.createOffer.bind(pc);
                pc.createOffer = function(...args) {
                    return originalCreateOffer.apply(this, args).then(offer => {
                        if (offer && offer.sdp) offer.sdp = cleanSDP(offer.sdp);
                        return offer;
                    });
                };
                
                const originalCreateAnswer = pc.createAnswer.bind(pc);
                pc.createAnswer = function(...args) {
                    return originalCreateAnswer.apply(this, args).then(answer => {
                        if (answer && answer.sdp) answer.sdp = cleanSDP(answer.sdp);
                        return answer;
                    });
                };
                
                const originalSetLocalDescription = pc.setLocalDescription.bind(pc);
                pc.setLocalDescription = function(description) {
                    if (description && description.sdp) description.sdp = cleanSDP(description.sdp);
                    return originalSetLocalDescription.call(this, description);
                };
                
                const originalSetRemoteDescription = pc.setRemoteDescription.bind(pc);
                pc.setRemoteDescription = function(description) {
                    if (description && description.sdp) description.sdp = cleanSDP(description.sdp);
                    return originalSetRemoteDescription.call(this, description);
                };
                
                const originalGetStats = pc.getStats.bind(pc);
                pc.getStats = function(selector, successCallback, failureCallback) {
                    return originalGetStats.call(this, selector).then(stats => {
                        const filteredStats = new Map();
                        stats.forEach((stat, id) => {
                            const report = {};
                            stat.names().forEach(name => {
                                const value = stat.stat(name);
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
                
                const originalAddIceCandidate = pc.addIceCandidate.bind(pc);
                pc.addIceCandidate = function(candidate) {
                    if (candidate && candidate.candidate) {
                        candidate.candidate = candidate.candidate.replace(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/g, '0.0.0.0');
                        candidate.candidate = candidate.candidate.replace(/[0-9a-f:]+::[0-9a-f:]+/g, '::');
                    }
                    return originalAddIceCandidate.call(this, candidate);
                };
                
                return pc;
            };
            
            RTCPeerConnectionWrapper.prototype = originalRTCPeerConnection.prototype;
            RTCPeerConnectionWrapper.prototype.constructor = RTCPeerConnectionWrapper;
            window.RTCPeerConnection = RTCPeerConnectionWrapper;
            if (window.webkitRTCPeerConnection) window.webkitRTCPeerConnection = RTCPeerConnectionWrapper;
            if (window.mozRTCPeerConnection) window.mozRTCPeerConnection = RTCPeerConnectionWrapper;
        }
        
        if (window.MediaStreamTrack && window.MediaStreamTrack.prototype) {
            const originalGetSettings = window.MediaStreamTrack.prototype.getSettings;
            if (originalGetSettings) {
                window.MediaStreamTrack.prototype.getSettings = function() {
                    const settings = originalGetSettings.call(this);
                    if (settings.deviceId) settings.deviceId = 'default';
                    return settings;
                };
            }
        }
        
        Object.defineProperty(window, 'outerHeight', { get: () => 1080, configurable: true });
        Object.defineProperty(window, 'outerWidth', { get: () => 1920, configurable: true });

        Object.defineProperty(document, '$cdc_asdjflasutopfhvcZLmcfl_', { get: () => undefined, configurable: true });
        Object.defineProperty(document, '$chrome_asyncScriptInfo', { get: () => undefined, configurable: true });

        const originalSetTimeout = window.setTimeout;
        const originalSetInterval = window.setInterval;
        window.setTimeout = function(...args) {
            if (args[1] && args[1] < 4) args[1] = 4 + Math.random() * 2;
            return originalSetTimeout.apply(this, args);
        };
        window.setInterval = function(...args) {
            if (args[1] && args[1] < 4) args[1] = 4 + Math.random() * 2;
            return originalSetInterval.apply(this, args);
        };

        Object.keys(window).forEach(key => {
            if (key.includes('__playwright') || key.includes('__pw') || key.includes('__puppeteer')) {
                delete window[key];
            }
        });

        const originalOffsetWidth = Object.getOwnPropertyDescriptor(HTMLElement.prototype, 'offsetWidth').get;
        Object.defineProperty(HTMLElement.prototype, 'offsetWidth', {
            get: function() {
                const width = originalOffsetWidth.call(this);
                return width + (Math.random() < 0.1 ? Math.random() * 0.1 : 0);
            },
            configurable: true
        });

        const originalGetOwnPropertyNames = Object.getOwnPropertyNames;
        Object.getOwnPropertyNames = function(obj) {
            const names = originalGetOwnPropertyNames(obj);
            return names.filter(name => !name.includes('__playwright') && !name.includes('__pw'));
        };

        Function.prototype.toString = new Proxy(Function.prototype.toString, {
            apply: function(target, thisArg, argumentsList) {
                const str = target.apply(thisArg, argumentsList);
                if (str.includes('native code') || str.includes('[native code]')) return str;
                if (str.includes('playwright') || str.includes('puppeteer') || str.includes('webdriver')) {
                    return 'function() { [native code] }';
                }
                return str;
            }
        });

        const originalHasOwnProperty = Object.prototype.hasOwnProperty;
        Object.prototype.hasOwnProperty = function(prop) {
            if (prop === 'webdriver' || prop.includes('__playwright') || prop.includes('__pw')) return false;
            return originalHasOwnProperty.call(this, prop);
        };

        setInterval(() => {
            if (navigator.webdriver !== undefined) {
                Object.defineProperty(navigator, 'webdriver', {
                    get: () => undefined,
                    configurable: true
                });
            }
        }, 100);
    `);

        let dataObtained = false;
        let browserClosing = false;

        // Interceptar requests para modificar headers y agregar delays humanos (igual que test.js)
        let requestCount = 0;
        await page.route('**/*', async (route) => {
            requestCount++;
            if (requestCount > 1) {
                const delay = requestCount < 5 ?
                    Math.random() * 50 :
                    Math.random() * 200 + 100;
                await new Promise(resolve => setTimeout(resolve, delay));
            }

            const headers = {
                ...route.request().headers(),
                'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
                'sec-ch-ua-mobile': '?0',
                'sec-ch-ua-platform': '"macOS"',
            };

            if (route.request().url().includes('tiktok.com') && !headers['Referer']) {
                headers['Referer'] = 'https://www.tiktok.com/';
            }

            route.continue({ headers });
        });

        // Interceptar SOLO el endpoint item_list
        page.on('response', async (response) => {
            if (dataObtained || browserClosing) return;

            const url = response.url();
            if (url.includes('item_list')) {
                try {
                    const data = await response.json();
                    if (data && (data.itemList || (data.statusCode === 0 && data.data && data.data.itemList))) {
                        dataObtained = true;
                        browserClosing = true;

                        // Retornar JSON por stdout (sin logs adicionales)
                        console.log(JSON.stringify(data, null, 2));

                        // Cerrar browser de manera segura
                        try {
                            await browser.close();
                        } catch (closeError) {
                            // Ignorar errores al cerrar
                        }

                        // Salir inmediatamente
                        process.exit(0);
                    }
                } catch (e) {
                    // No es JSON válido
                }
            }
        });

        // Función avanzada para simular movimiento de mouse humano (igual que test.js)
        const simulateHumanMouseMove = async (fromX, fromY, toX, toY, speed = 'normal') => {
            if (dataObtained || browserClosing) return;

            try {
                const speedMultipliers = { slow: 1.5, normal: 1.0, fast: 0.7 };
                const multiplier = speedMultipliers[speed] || 1.0;
                const distance = Math.sqrt(Math.pow(toX - fromX, 2) + Math.pow(toY - fromY, 2));
                const baseSteps = Math.max(15, Math.min(50, Math.floor(distance / 10)));
                const steps = Math.floor(baseSteps * multiplier) + Math.floor(Math.random() * 10);
                const controlX = (fromX + toX) / 2 + (Math.random() - 0.5) * distance * 0.3;
                const controlY = (fromY + toY) / 2 + (Math.random() - 0.5) * distance * 0.3;

                for (let i = 0; i <= steps; i++) {
                    if (dataObtained || browserClosing) return;

                    const t = i / steps;
                    const x = Math.pow(1 - t, 2) * fromX + 2 * (1 - t) * t * controlX + Math.pow(t, 2) * toX;
                    const y = Math.pow(1 - t, 2) * fromY + 2 * (1 - t) * t * controlY + Math.pow(t, 2) * toY;

                    try {
                        await page.mouse.move(Math.round(x), Math.round(y), { steps: 1 });
                    } catch (e) {
                        if (e.message.includes('closed') || e.message.includes('Target')) return;
                        throw e;
                    }

                    const delay = 8 + Math.random() * 15;
                    if (Math.random() < 0.1) {
                        await new Promise(resolve => setTimeout(resolve, delay + 50 + Math.random() * 100));
                    } else {
                        await new Promise(resolve => setTimeout(resolve, delay));
                    }
                }
            } catch (e) {
                if (e.message.includes('closed') || e.message.includes('Target')) return;
                throw e;
            }
        };

        // Función para scroll humano (igual que test.js)
        const humanScroll = async (direction = 'down', amount = 300) => {
            if (dataObtained || browserClosing) return;

            try {
                const scrollSteps = 5 + Math.floor(Math.random() * 5);
                const stepAmount = amount / scrollSteps;

                for (let i = 0; i < scrollSteps; i++) {
                    if (dataObtained || browserClosing) return;

                    const currentAmount = stepAmount + (Math.random() - 0.5) * stepAmount * 0.3;
                    const scrollDelta = direction === 'down' ? currentAmount : -currentAmount;

                    try {
                        await page.mouse.wheel(0, scrollDelta);
                    } catch (e) {
                        if (e.message.includes('closed') || e.message.includes('Target')) return;
                        throw e;
                    }

                    const progress = i / scrollSteps;
                    const delay = progress < 0.2 || progress > 0.8 ?
                        150 + Math.random() * 200 :
                        50 + Math.random() * 100;
                    await page.waitForTimeout(delay);
                }
            } catch (e) {
                if (e.message.includes('closed') || e.message.includes('Target')) return;
                throw e;
            }
        };

        // Función para pausa humana (igual que test.js)
        const humanPause = async (baseTime = 2000) => {
            if (dataObtained || browserClosing) return;

            try {
                const pauseTime = Math.random() < 0.2 ?
                    baseTime * 2 + Math.random() * baseTime * 2 :
                    baseTime + Math.random() * baseTime;
                await page.waitForTimeout(pauseTime);
            } catch (e) {
                if (e.message.includes('closed') || e.message.includes('Target')) return;
                throw e;
            }
        };

        const viewport = page.viewportSize();

        // Navegar según el modo (igual que test.js)
        if (!skipFrontPage) {
            await page.goto('https://www.tiktok.com', { waitUntil: 'domcontentloaded', timeout: 30000 });
            await humanPause(3000);

            await simulateHumanMouseMove(
                viewport.width / 2,
                viewport.height / 2,
                100 + Math.random() * 200,
                100 + Math.random() * 200
            );

            for (let i = 0; i < 3; i++) {
                await humanScroll('down', 300 + Math.random() * 400);
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
                await humanPause(1000);
            }
            await humanPause(2000);
        }

        // Navegar al perfil con detección de errores
        await page.goto(`https://www.tiktok.com/@${profileUsername}`, { waitUntil: 'domcontentloaded', timeout: 30000 });
        await humanPause(3000);

        // Verificar si hay mensaje de error en la página
        try {
            const pageContent = await page.content();
            const pageText = await page.textContent('body').catch(() => '');

            const hasError = pageText.includes('Something went wrong') ||
                pageText.includes('Sorry about that! Please try again later.') ||
                pageContent.includes('Something went wrong') ||
                pageContent.includes('Sorry about that! Please try again later.');

            if (hasError) {
                // Retornar JSON vacío y salir
                console.log(JSON.stringify({}, null, 2));
                try {
                    await browser.close();
                } catch (closeError) {
                    // Ignorar errores al cerrar
                }
                process.exit(0);
            }
        } catch (e) {
            // Si hay error al verificar, continuar normalmente
        }

        await simulateHumanMouseMove(
            viewport.width / 2,
            viewport.height / 2,
            100 + Math.random() * 200,
            100 + Math.random() * 200
        );

        // Scroll humano en el perfil (igual que test.js)
        for (let i = 0; i < 5; i++) {
            const scrollAmount = 300 + Math.random() * 400;
            await humanScroll('down', scrollAmount);

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
            await humanPause(800);
        }

        await humanPause(2000);
        await humanScroll('down', 500);
        await humanPause(1500);

        // Esperar hasta 45 segundos para obtener los datos
        const maxWaitTime = 45000;
        const startTime = Date.now();
        let lastErrorCheck = Date.now();
        const errorCheckInterval = 5000; // Verificar errores cada 5 segundos

        while (!dataObtained && !browserClosing && (Date.now() - startTime) < maxWaitTime) {
            if (dataObtained || browserClosing) break;

            // Verificar periódicamente si aparece el mensaje de error
            if (Date.now() - lastErrorCheck > errorCheckInterval) {
                try {
                    const pageText = await page.textContent('body').catch(() => '');
                    const hasError = pageText.includes('Something went wrong') ||
                        pageText.includes('Sorry about that! Please try again later.');

                    if (hasError) {
                        // Retornar JSON vacío y salir
                        console.log(JSON.stringify({}, null, 2));
                        browserClosing = true;
                        try {
                            await browser.close();
                        } catch (closeError) {
                            // Ignorar errores al cerrar
                        }
                        process.exit(0);
                    }
                } catch (e) {
                    // Ignorar errores al verificar
                }
                lastErrorCheck = Date.now();
            }

            await humanScroll('down', 200 + Math.random() * 200);

            if (dataObtained || browserClosing) break;

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

            if (dataObtained || browserClosing) break;

            await humanPause(500 + Math.random() * 1000);
        }

        // Si no se obtuvieron datos, cerrar y salir con error
        if (!dataObtained) {
            await browser.close();
            process.exit(1);
        }
    } catch (error) {
        // Capturar cualquier error no manejado
        console.error('Error:', error.message);
        if (error.stack) {
            console.error(error.stack);
        }
        // Asegurarse de cerrar el browser si está abierto
        try {
            if (typeof browser !== 'undefined' && browser) {
                await browser.close();
            }
        } catch (closeError) {
            // Ignorar errores al cerrar
        }
        process.exit(1);
    }
})();
