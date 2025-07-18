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
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        context.coordinator.loadSVG(into: webView, from: url)   // initial load
        webView.isUserInteractionEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Reload **only** if the caller supplies a new URL
        if url != context.coordinator.currentURL {
            context.coordinator.loadSVG(into: uiView, from: url)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SVGWebView
        var currentURL: URL?
        init(_ parent: SVGWebView) { self.parent = parent }
        
        // Centralised loader
        func loadSVG(into webView: WKWebView, from url: URL) {
            currentURL = url
            DispatchQueue.main.async { [weak self] in
                self?.parent.isLoading = true
            }
            
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad  // Use cache if available
            
            AF.request(request)
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success(let svg):
                        let html = """
                        <html><head><meta name="viewport" content="width=device-width,\
                        height=device-height,initial-scale=1.0"><style>body{margin:0;\
                        display:flex;align-items:center;justify-content:center;\
                        background:transparent;}svg{width:100%;height:100%;}</style>\
                        </head><body>\(svg)</body></html>
                        """
                        DispatchQueue.main.async {
                            webView.loadHTMLString(html, baseURL: nil)
                        }
                    case .failure(let error):
                        print("Failed to load SVG: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.parent.isLoading = false
                        }
                    }
                }
        }
        
        // Stop the spinner when the page finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}
