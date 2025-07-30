//
//  SVGWebView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 29/04/25.
//


import SwiftUI
import WebKit
import Alamofire

struct SVGWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.isUserInteractionEnabled = false
        context.coordinator.loadSVG(into: webView, from: url)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if url != context.coordinator.currentURL {
            context.coordinator.loadSVG(into: uiView, from: url)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SVGWebView
        var currentURL: URL?
        
        init(_ parent: SVGWebView) {
            self.parent = parent
        }
        
        func loadSVG(into webView: WKWebView, from url: URL) {
            currentURL = url
            DispatchQueue.main.async { [weak self] in
                self?.parent.isLoading = true
            }
            
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            
            AF.request(request)
                .validate()
                .responseString { [weak self] response in
                    switch response.result {
                    case .success(let svg):
                        let trimmed = svg.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            print("⚠️ Empty SVG content — keep loading active")
                            return
                        }
                        
                        let html = self?.buildHTML(from: trimmed)
                        
                        // ✅ Save HTML to disk
                        self?.saveHTMLToDisk(html ?? "", for: url)
                        
                        DispatchQueue.main.async {
                            webView.loadHTMLString(html ?? "", baseURL: nil)
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to load from network: \(error.localizedDescription)")
                        if let savedHTML = self?.loadHTMLFromDisk(for: url) {
                            print("📦 Loaded SVG from file cache")
                            DispatchQueue.main.async {
                                webView.loadHTMLString(savedHTML, baseURL: nil)
                            }
                        } else {
                            print("❌ No saved file found for offline use")
                        }
                    }
                }
        }
        
        // ✅ Only stop loading if WebView confirms it finished
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WKWebView finished rendering SVG")
            if NetworkMonitor.shared.isNetworkAvailable() {
                parent.isLoading = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    self.parent.isLoading = false
                })
            }
        }
        
        func buildHTML(from svg: String) -> String {
            return """
                    <html>
                    <head>
                    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0">
                    <style>
                    body { margin:0; display:flex; align-items:center; justify-content:center; background:transparent; }
                    svg { width:100%; height:100%; }
                    </style>
                    </head>
                    <body>\(svg)</body>
                    </html>
                    """
        }
        
        private func htmlFilePath(for url: URL) -> URL? {
            let fileName = url.lastPathComponent + ".html"
            if   let documents = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                return documents.appendingPathComponent(fileName) }
            else {
                return nil
            }
        }
        
        private func saveHTMLToDisk(_ html: String, for url: URL) {
            if  let fileURL = htmlFilePath(for: url) {
                do {
                    try html.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("✅ HTML saved to disk at: \(fileURL.lastPathComponent)")
                } catch {
                    print("❌ Failed to save HTML: \(error)")
                }
            }
        }
        
        private func loadHTMLFromDisk(for url: URL) -> String? {
            if  let fileURL = htmlFilePath(for: url)  {
                do {
                    let html = try String(contentsOf: fileURL, encoding: .utf8)
                    return html
                } catch {
                    print("❌ Failed to read HTML from disk: \(error)")
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
