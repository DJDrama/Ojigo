//
//  WebBrowserview.swift
//  Ojigo
//
//  Created by dj on 2021/10/19.
//

import Foundation
import SwiftUI
import WebKit

struct WebBrowserView: UIViewRepresentable {
    
    var url: String
    
    init(url: String /*, isPresented: Binding<Bool> */){
        self.url = url
        // self._isPresented = isPresented
    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        //preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        // Here "iOSNative" is our interface name that we pushed to the website that is being loaded
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        
        // no zoom
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        
        configuration.defaultWebpagePreferences = preferences
        //configuration.preferences = preferences
        
        
        
        let wkWebView = WKWebView(frame: CGRect.zero, configuration: configuration)
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.scrollView.isScrollEnabled = true
        
        
        //getCurrentPosition
        
        // to prevent reload url when alert dialog event happens
        guard let url = URL(string: self.url) else { return wkWebView}
        let request = URLRequest(url: url)
        wkWebView.load(request)
        return wkWebView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // this may reload url when alert dialog event happens
//        guard let url = URL(string: self.url) else { return  }
//        let request = URLRequest(url: url)
//        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebBrowserView
        
        init(_ uiWebView: WebBrowserView) {
            self.parent = uiWebView
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Page loaded so no need to show loader anymore
            if let url = webView.url, url.absoluteString.range(of: "close") != nil {
                //self.navigationController?.popViewController(animated: true)
                //self.parent.isPresented.toggle()
            }
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        }
        
        // This function is essential for intercepting every navigation in the webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Suppose you don't want your user to go a restricted site
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                completionHandler()
            }))
            if let controller = topMostViewController() {
                controller.present(alertController, animated: true, completion: nil)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            alertController.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { (action) in completionHandler(true) })
            )
            alertController.addAction(
                UIAlertAction(title: "Cancel", style: .default, handler: { (action) in completionHandler(false) })
            )
            
            if let controller = topMostViewController() {
                controller.present(alertController, animated: true, completion: nil)
            }
            
        }
        
        private func topMostViewController() -> UIViewController? {
            guard let rootController = keyWindow()?.rootViewController else {
                return nil
            }
            return topMostViewController(for: rootController)
        }
        
        private func keyWindow() -> UIWindow? {
            return UIApplication.shared.connectedScenes
                .filter {$0.activationState == .foregroundActive}
                .compactMap {$0 as? UIWindowScene}
                .first?.windows.filter {$0.isKeyWindow}.first
        }
        
        private func topMostViewController(for controller: UIViewController) -> UIViewController {
            if let presentedController = controller.presentedViewController {
                return topMostViewController(for: presentedController)
            } else if let navigationController = controller as? UINavigationController {
                guard let topController = navigationController.topViewController else {
                    return navigationController
                }
                return topMostViewController(for: topController)
            } else if let tabController = controller as? UITabBarController {
                guard let topController = tabController.selectedViewController else {
                    return tabController
                }
                return topMostViewController(for: topController)
            }
            return controller
        }
        
    }
}
extension WebBrowserView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("INVOKE CALLED")
    }
    
}
