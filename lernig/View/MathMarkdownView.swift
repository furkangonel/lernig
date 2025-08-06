//
//  MathMarkdownView.swift
//  lernig
//
//  Created by Furkan Gönel on 5.08.2025.
//


import SwiftUI
import WebKit

struct MathMarkdownView: UIViewRepresentable {
    let content: String
    @Binding var contentHeight: CGFloat

    
    // Binding olmadan kullanım için convenience init
    init(content: String) {
        self.content = content
        self._contentHeight = .constant(300) // Default height
    }
    
    // Binding ile kullanım için
    init(content: String, height: Binding<CGFloat>) {
        self.content = content
        self._contentHeight = height
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "heightUpdate")
        userContentController.add(context.coordinator, name: "consoleLog")
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let processedContent = processContent(content)
        let htmlContent = createHTML(with: processedContent)
        
        print("🔍 Loading MathMarkdownView with content length: \(content.count)")
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MathMarkdownView
        
        init(_ parent: MathMarkdownView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView navigation finished")
            
            // Yüksekliği hesapla ve güncelle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                    if let height = result as? CGFloat, height > 0 {
                        DispatchQueue.main.async {
                            print("📏 Setting height to: \(height)")
                            self.parent.contentHeight = height
                        }
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightUpdate" {
                if let height = message.body as? CGFloat, height > 0 {
                    DispatchQueue.main.async {
                        print("📏 Height update from JS: \(height)")
                        self.parent.contentHeight = height
                    }
                }
            } else if message.name == "consoleLog" {
                print("🌐 WebView: \(message.body)")
            }
        }
    }
    
    private func processContent(_ rawContent: String) -> String {
        var processed = rawContent

        // **bold** → <strong>bold</strong>
        processed = processed.replacingOccurrences(
            of: #"\*\*(.*?)\*\*"#,
            with: "<strong>$1</strong>",
            options: .regularExpression
        )

        // ### heading → <h3>heading</h3>
        processed = replaceRegex(pattern: #"(?m)^### (.*?)$"#, in: processed, with: "<h3>$1</h3>")

        // ## heading → <h2>heading</h2>
        processed = replaceRegex(pattern: #"(?m)^## (.*?)$"#, in: processed, with: "<h2>$1</h2>")

        // Satır sonlarını <br> tag'ine çevir
        processed = processed.replacingOccurrences(of: "\n", with: "<br>")

        // Çift <br> taglerini paragraf ayırıcısı olarak kullan
        processed = processed.replacingOccurrences(of: "<br><br>", with: "</p><p>")

        // İçeriği paragraf ile sar
        processed = "<p>" + processed + "</p>"

        // Boş paragrafları temizle
        processed = processed.replacingOccurrences(of: "<p></p>", with: "")
        processed = processed.replacingOccurrences(of: "<p><br></p>", with: "")

        return processed
    }
    
    
    private func replaceRegex(pattern: String, in text: String, with template: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: template)
    }
    
    
    private func createHTML(with content: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
            
            <!-- MathJax Configuration -->
            <script>
            window.MathJax = {
                tex: {
                    inlineMath: [['$', '$'], ['\\\\(', '\\\\)']],
                    displayMath: [['$$', '$$'], ['\\\\[', '\\\\]']],
                    processEscapes: true,
                    processEnvironments: true
                },
                options: {
                    skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
                },
                startup: {
                    pageReady: () => {
                        return MathJax.startup.defaultPageReady().then(() => {
                            // MathJax tamamlandığında yüksekliği güncelle
                            setTimeout(updateHeight, 100);
                            setTimeout(updateHeight, 500);
                            setTimeout(updateHeight, 1000);
                        }).catch((err) => {
                            console.error('MathJax error:', err);
                        });
                    }
                }
            };
            
            function updateHeight() {
                const height = Math.max(
                    document.body.scrollHeight,
                    document.body.offsetHeight,
                    document.documentElement.clientHeight,
                    document.documentElement.scrollHeight,
                    document.documentElement.offsetHeight
                );
                
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.heightUpdate) {
                    window.webkit.messageHandlers.heightUpdate.postMessage(height);
                }
            }
            </script>
            
            <!-- MathJax Script -->
            <script type="text/javascript" id="MathJax-script" async
                src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
            </script>
            
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', Helvetica, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #1d1d1f;
                    margin: 0;
                    padding: 16px;
                    background-color: transparent;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                
                h1, h2, h3, h4, h5, h6 {
                    font-weight: 600;
                    margin-top: 24px;
                    margin-bottom: 12px;
                    color: #1d1d1f;
                }
                
                h1 { font-size: 24px; }
                h2 { font-size: 20px; }
                h3 { font-size: 18px; }
                
                p {
                    margin: 0 0 16px 0;
                    text-align: justify;
                }
                
                strong {
                    font-weight: 600;
                    color: #1d1d1f;
                }
                
                /* Liste stilleri */
                ul, ol {
                    margin: 12px 0;
                    padding-left: 20px;
                }
                
                li {
                    margin: 4px 0;
                }
                
                /* MathJax elementleri için stiller */
                mjx-container {
                    margin: 8px 0;
                    display: inline-block;
                }
                
                /* Blok seviyesi matematik için */
                mjx-container[display="true"] {
                    display: block;
                    text-align: center;
                    margin: 20px 0;
                }
                
                /* Kod blokları */
                code {
                    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
                    background-color: #f5f5f7;
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-size: 14px;
                }
                
                /* Dark mode desteği */
                @media (prefers-color-scheme: dark) {
                    body {
                        color: #f5f5f7;
                        background-color: transparent;
                    }
                    
                    h1, h2, h3, h4, h5, h6, strong {
                        color: #f5f5f7;
                    }
                    
                    code {
                        background-color: #2c2c2e;
                        color: #f5f5f7;
                    }
                }
                
                /* Responsive tasarım */
                @media (max-width: 480px) {
                    body {
                        font-size: 15px;
                        padding: 12px;
                    }
                    
                    h1 { font-size: 22px; }
                    h2 { font-size: 18px; }
                    h3 { font-size: 16px; }
                }
            </style>
        </head>
        <body>
            <div id="content">
                \(content)
            </div>
            
            <script>
                // Sayfa yüklendikten sonra yüksekliği güncelle
                window.addEventListener('load', function() {
                    updateHeight();
                    
                    // DOM değişikliklerini izle
                    const observer = new MutationObserver(function(mutations) {
                        let shouldUpdate = false;
                        mutations.forEach(function(mutation) {
                            if (mutation.type === 'childList' || mutation.type === 'characterData') {
                                shouldUpdate = true;
                            }
                        });
                        
                        if (shouldUpdate) {
                            setTimeout(updateHeight, 100);
                        }
                    });
                    
                    observer.observe(document.body, {
                        childList: true,
                        subtree: true,
                        characterData: true
                    });
                });
            </script>
        </body>
        </html>
        """
    }
}

// SwiftUI'de kullanım için wrapper view
struct AdaptiveMathMarkdownView: View {
    let content: String
    @State private var contentHeight: CGFloat = 300
    
    var body: some View {
            MathMarkdownView(content: content, height: $contentHeight)
                .frame(height: max(contentHeight, 100))
                .animation(.easeInOut(duration: 0.3), value: contentHeight)
   
    }
}


