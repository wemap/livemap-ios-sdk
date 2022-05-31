//
//  NativeProviders.swift
//  livemap-ios-sdk
//
//  Created by Thibault Capelli on 23/05/2022.
//

import Foundation
import WebKit

internal class NativeProviders: NSObject, WKScriptMessageHandler {
    var webView: WKWebView!
    
    var polestarLocationProviderApiKey: String?
    var polestarLocationProvider: PolestarLocationProvider?
    
    override init() {
        super.init()
    }
    
    func setWebView(webView: WKWebView) {
        self.webView = webView

        self.webView.configuration.userContentController.add(self, name: "setPolestarLocationProviderApiKey");
        self.webView.configuration.userContentController.add(self, name: "startPolestarLocationProvider");
        self.webView.configuration.userContentController.add(self, name: "stopPolestarLocationProvider");
    }
    
    func setNativeProvidersJSObject() {
        self.webView.evaluateJavaScript("window.__nativeProviders = {}")
    }
    
    func bindPolestarProviderToJS() {
        let script = """
            window.__nativeProviders.getPoleStarProvider = () => ({
                setApiKey: (apiKey) => window.webkit.messageHandlers.setPolestarLocationProviderApiKey.postMessage(apiKey),
                checkAvailability: () => true,
                start: () => window.webkit.messageHandlers.startPolestarLocationProvider.postMessage(''),
                stop: () => window.webkit.messageHandlers.stopPolestarLocationProvider.postMessage('')
            });
        """;

        self.webView.evaluateJavaScript(script)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "setPolestarLocationProviderApiKey") {
            if let apiKey = message.body as? String {
                self.polestarLocationProviderApiKey = apiKey
            }
        }

        if (message.name == "startPolestarLocationProvider") {
            if let polestarLocationProviderApiKey = self.polestarLocationProviderApiKey {
                self.polestarLocationProvider = PolestarLocationProvider(apikey: polestarLocationProviderApiKey);
            }
            
            if let polestarLocationProvider = self.polestarLocationProvider {
                polestarLocationProvider.didLocationChangeCallback = { coordinates in
                    self.providePolestarLocation(coordinates: coordinates);
                }
            }
            
            self.polestarLocationProvider?.start();
        }

        if (message.name == "stopPolestarLocationProvider") {
            self.polestarLocationProvider?.stop()
        }
    }
    
    private func providePolestarLocation(coordinates: PolestarCoordinates) {
        let script = "promise = window.__nativeJsProviders.polestar.callbackPosition('\(coordinates.toJsonString())');"
        self.webView.evaluateJavaScript(script)
    }
}
