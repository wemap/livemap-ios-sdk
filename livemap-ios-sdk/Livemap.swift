//
//  Livemap.swift
//  livemap-ios-sdk
//
//  Created by Bertrand Mathieu-Daudé on 21/02/2020.
//  Copyright © 2020 Bertrand Mathieu-Daudé. All rights reserved.
//

import Foundation
import WebKit

@objc public protocol wemapsdkViewDelegate : AnyObject {
    @objc optional func waitForReady(_ wemapController: wemapsdk)
    @objc optional func onEventOpen(_ wemapController: wemapsdk, event: WemapEvent)
    @objc optional func onPinpointOpen(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
    @objc optional func onEventClose(_ wemapController: wemapsdk)
    @objc optional func onPinpointClose(_ wemapController: wemapsdk)
    @objc optional func onGuidingStarted(_ wemapController: wemapsdk)
    @objc optional func onGuidingStopped(_ wemapController: wemapsdk)
    @objc optional func onUserLogin(_ wemapController: wemapsdk)
    @objc optional func onUserLogout(_ wemapController: wemapsdk)
    @objc optional func onUrlChange(_ wemapController: wemapsdk, previousUrl: String, nextUrl: String)
    @objc optional func onActionButtonClick(_ wemapController: wemapsdk, pinpoint: WemapPinpoint, actionType: String)
    @objc optional func onActionButtonClick(_ wemapController: wemapsdk, event: WemapEvent, actionType: String)
    @objc optional func onContentUpdated(_ wemapController: wemapsdk, events: [WemapEvent], contentUpdatedQuery: ContentUpdatedQuery)
    @objc optional func onContentUpdated(_ wemapController: wemapsdk, pinpoints: [WemapPinpoint], contentUpdatedQuery: ContentUpdatedQuery)

    // RG stuffs
    @objc optional func onBookEventClicked(_ wemapController: wemapsdk, event: WemapEvent)
    @objc optional func onGoToPinpointClicked(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
    
    @objc optional func onMapMoved(_ wemapController: wemapsdk, mapMoved: MapMoved)
    @objc optional func onMapClick(_ wemapController: wemapsdk, coordinates: Coordinates)
    @objc optional func onMapLongClick(_ wemapController: wemapsdk, coordinates: Coordinates)
}

public class wemapsdk: UIView, WKUIDelegate {
    public static let sharedInstance = wemapsdk(frame: CGRect.zero)

    private var configuration: wemapsdk_config!
    private var webView: WKWebView!
    private var arView: CustomARView!
    private let navigatorGeolocation = NavigatorGeolocation();
    
    public var currentUrl: String = ""
    private var nativeProviders: NativeProviders?
    
    private lazy var mapViewConfig: WKWebViewConfiguration = {
        let contentController = WKUserContentController()

        WebCommands.values.forEach { contentController.add(self, name: $0) }

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.userContentController = contentController
        return config
    }()

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            switch keyPath {
                case #keyPath(WKWebView.url):
                    let previousUrl: String = self.currentUrl
                    let nextUrl: String = String(describing: key)
                    onUrlChange(previousUrl: previousUrl, nextUrl: nextUrl);
                    self.currentUrl = nextUrl
                default:
                    print("keyPath: \(String(describing: keyPath)) change")
            }
        }
    }

    weak open var delegate: wemapsdkViewDelegate?

    override private init(frame: CGRect) {
        super.init(frame: frame)
        webView = WKWebView(frame: frame, configuration: mapViewConfig)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        navigatorGeolocation.setWebView(webView: webView);

        arView = CustomARView(frame: frame)
        arView.set(webMapView: webView)
        
        func onCameraAuthorizationDenied() -> Void {
            DispatchQueue.main.async {
                self.forceARViewMode(mode: ARViewMode.OFF)
                self.setPermissionsDenied(permissions: ["camera"])
                self.onStopCamera()
            }
        }
        
        arView.cameraView.onCameraAuthorizationStatusCheck = { status in
            if status == .denied { onCameraAuthorizationDenied() }
        }
        arView.cameraView.onCameraAuthorizationRequest = { granted in
            if granted == false { onCameraAuthorizationDenied() }
        }

        self.addSubview(arView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        webView.frame = self.bounds
        arView.frame = self.bounds
    }

    func onLoadingFinished() {
        delegate?.waitForReady?(self)
    }

    func onEventOpen(_ event: WemapEvent) {
        delegate?.onEventOpen?(self, event: event)
    }

    func onPinpointOpen(_ pinpoint: WemapPinpoint) {
        delegate?.onPinpointOpen?(self, pinpoint: pinpoint)
    }

    func onEventClose() {
        delegate?.onEventClose?(self)
    }

    func onPinpointClose() {
        delegate?.onPinpointClose?(self)
    }

    func onGuidingStart() {
        delegate?.onGuidingStarted?(self)
    }

    func onGuidingStopped() {
        delegate?.onGuidingStopped?(self)
    }

    // RG stuffs
    func onBookEventClicked(_ event: WemapEvent) {
        delegate?.onBookEventClicked?(self, event: event)
    }

    func onGoToPinpointClicked(_ pinpoint: WemapPinpoint) {
        delegate?.onGoToPinpointClicked?(self, pinpoint: pinpoint)
    }
    
    func onUserLogin() {
        delegate?.onUserLogin?(self)
    }
    
    func onUserLogout() {
        delegate?.onUserLogout?(self)
    }

    func onUrlChange(previousUrl: String, nextUrl: String) {
        delegate?.onUrlChange?(self, previousUrl: previousUrl, nextUrl: nextUrl)
    }
    
    func onActionButtonClick(pinpoint: WemapPinpoint, actionType: String) {
        delegate?.onActionButtonClick?(self, pinpoint: pinpoint, actionType: actionType)
    }
    
    func onActionButtonClick(event: WemapEvent, actionType: String) {
        delegate?.onActionButtonClick?(self, event: event, actionType: actionType)
    }
    
    func onMapMoved(mapMoved: MapMoved) {
        delegate?.onMapMoved?(self, mapMoved: mapMoved)
    }
    
    func onMapClick(coordinates: Coordinates) {
        delegate?.onMapClick?(self, coordinates: coordinates)
    }
    
    func onMapLongClick(coordinates: Coordinates) {
        delegate?.onMapLongClick?(self, coordinates: coordinates)
    }
    
    func onContentUpdated(pinpoints: [WemapPinpoint], contentUpdatedQuery: ContentUpdatedQuery) {
        delegate?.onContentUpdated?(self, pinpoints: pinpoints, contentUpdatedQuery: contentUpdatedQuery)
    }
    
    func onContentUpdated(events: [WemapEvent], contentUpdatedQuery: ContentUpdatedQuery) {
        delegate?.onContentUpdated?(self, events: events, contentUpdatedQuery: contentUpdatedQuery)
    }
}

extension wemapsdk: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.waitForReady()
        self.webView.evaluateJavaScript(navigatorGeolocation.getJavaScripToEvaluate());
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if(configuration.enablePolestar) {
            self.nativeProviders = NativeProviders()
            self.nativeProviders?.setWebView(webView: self.webView)
            self.nativeProviders?.bindPolestarProviderToJS()
        }
    }

    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("didFail")
    }
    
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
}

extension wemapsdk {
    public func configure(config: wemapsdk_config) -> wemapsdk {
        self.configuration = config
        return self
    }

    public func presentIn(view: UIView) -> wemapsdk {
        view.addSubview(self)
        self.frame = view.bounds

        arView.frame = self.bounds
        webView.frame = self.bounds
        
        loadMapUrl()

        return self
    }

    public func loadMapUrl() {
        var urlComps = URLComponents(string: configuration.livemapRootUrl)!
        var queryItems: [URLQueryItem] = []
        
        if (configuration.ufe) {
            queryItems.append(URLQueryItem(name: "dist", value: "ufe"))
            queryItems.append(URLQueryItem(name: "arviewenabled", value: "true"))
            queryItems.append(URLQueryItem(name: "routingtype", value: "osrm"))
            queryItems.append(URLQueryItem(name: "routingmode", value: "walking"))
            queryItems.append(URLQueryItem(name: "routingurl", value: "https://routingdev.maaap.it"))
            queryItems.append(URLQueryItem(name: "homecontrol", value: "false"))
            queryItems.append(URLQueryItem(name: "clicktofullscreen", value: "false"))
        } else {
            queryItems.append(URLQueryItem(name: "token", value: configuration.token))
            queryItems.append(URLQueryItem(name: "emmid", value: "\(configuration.emmid)"))
            queryItems.append(URLQueryItem(name: "clicktofullscreen", value: "false"))

            if let maxBoundsString: String = configuration.maxbounds?.toUrlParameter() {
                queryItems.append(URLQueryItem(name: "maxbounds", value: maxBoundsString))
            }

            if let introcardString: String = configuration.introcard?.toJsonString() {
                queryItems.append(URLQueryItem(name: "introcard", value: introcardString))
            }
        }
        
        urlComps.queryItems = queryItems
        let url = urlComps.url!

        webView.load(
            URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        )

        if (self.currentUrl == "") {
            self.currentUrl = url.absoluteString;
        }
    }
}

extension wemapsdk: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //debugPrint("\(#function) :::: message [\(message.name)] :::: with body: \n\(message.body)\n<<<")

        guard let command = WebCommands(rawValue: message.name) else { return }
        switch command {

        case .onLoadingFinished:
            self.attachHandlers()
            onLoadingFinished()

        case .onStartCamera:
            // debugPrint("ENABLE_CAMERA")
            startCamera()

        case .onStopCamera:
            // debugPrint("DISABLE_CAMERA")
            stopCamera()

        case .onEventOpen:
            // debugPrint("EVENT_OPEN")
            guard let json = message.body as? [String: Any] else { return }
            let eventData = (json["data"] as? NSDictionary)!
            let event = WemapEvent(eventData)
            onEventOpen(event)

        case .onPinpointOpen:
            // debugPrint("PINPOINT_OPEN")
            guard let json = message.body as? [String: Any] else { return }
            let pinpointData = (json["data"] as? NSDictionary)!
            let pinpoint = WemapPinpoint(pinpointData)
            onPinpointOpen(pinpoint)

        case .onEventClose:
            // debugPrint("EVENT_CLOSE")
            onEventClose()

        case .onPinpointClose:
            // debugPrint("PINPOINT_CLOSE")
            onPinpointClose()

        case .onGuidingStarted:
            // debugPrint("GUIDING_STARTED")
            onGuidingStart()

        case .onGuidingStopped:
            // debugPrint("GUIDING_STOPPED")
            onGuidingStopped()

        case .onBookEventClicked:
            // debugPrint("ON_BOOK_EVENT_CLICKED")
            guard let json = message.body as? [String: Any] else { return }
            let eventData = (json["data"] as? NSDictionary)!
            let event = WemapEvent(eventData)
            onBookEventClicked(event)

        case .onGoToPinpointClicked:
            // debugPrint("ON_GO_TO_PINPOINT_CLICKED")
            guard let json = message.body as? [String: Any] else { return }
            let pinpointData = (json["data"] as? NSDictionary)!
            let pinpoint = WemapPinpoint(pinpointData)
            onGoToPinpointClicked(pinpoint)
            
        case .onActionButtonClick:
            guard let json = message.body as? [String: Any] else { return }
            let itemType = (json["itemType"] as? String)!
            let actionType = (json["actionType"] as? String)!
            switch itemType {
            case "pinpoint":
                let pinpoint = WemapPinpoint((json["item"] as? NSDictionary)!)
                onActionButtonClick(pinpoint: pinpoint, actionType: actionType)
            case "event":
                let event = WemapEvent((json["item"] as? NSDictionary)!)
                onActionButtonClick(event: event, actionType: actionType)
            default:
                print("Unknow itemType: \(itemType)")
            }

        case .log:
            debugPrint("Log From webview: \(message.body)")
            
        case .onUserLogin:
            // debugPrint("USER_LOGIN")
            onUserLogin()
            
        case .onUserLogout:
            // debugPrint("USER_LOGOUT")
            onUserLogout()

        case .onLivemapMoved:
            if let json = message.body as? NSDictionary {
                onMapMoved(mapMoved: MapMoved.fromDictionary(json))
            }

        case .onMapClick:
            if let json = message.body as? NSDictionary {
                onMapClick(coordinates: Coordinates.fromDictionary(json))
            }
       
        case .onMapLongClick:
            if let json = message.body as? NSDictionary {
                onMapLongClick(coordinates: Coordinates.fromDictionary(json))
            }
            
        case .onContentUpdated:
            if let json = message.body as? NSDictionary {
                let type = json["type"] as! String
                let contentUpdatedQuery = ContentUpdatedQuery.fromDictionary(json["query"] as! NSDictionary)

                switch type {
                case "pinpoints":
                    let pinpoints = (json["items"] as! [NSDictionary]).map { WemapPinpoint($0) }
                    onContentUpdated(pinpoints: pinpoints, contentUpdatedQuery: contentUpdatedQuery)
                case "events":
                    let events = (json["items"] as! [NSDictionary]).map { WemapEvent($0) }
                    onContentUpdated(events: events, contentUpdatedQuery: contentUpdatedQuery)
                default:
                    print("Unknow itemType: \(type)")
                }
            }
            

        default:
            debugPrint("WARNING: Not supported message: \(message.name)")
        }
    }
}

extension wemapsdk {

    public func waitForReady() {
        let script = """
            let promise = window.livemap.waitForReady();
            promise.then(() => {
                window.webkit.messageHandlers.onLoadingFinished.postMessage({type: 'livemapReady'});
            });
        """
        webView.evaluateJavaScript(script)
    }


    private func attachHandlers() {
        let script = """
            const isReady = window.livemap.waitForReady()
            isReady.then(livemap => {

                const onEventOpenCallback = event => { window.webkit.messageHandlers.onEventOpen.postMessage({type: 'eventOpen', data: event.event});
                };

                const onPinpointOpenCallback = pinpoint => { window.webkit.messageHandlers.onPinpointOpen.postMessage({type: 'openPinpoint', data: pinpoint.pinpoint});
                };

                const onEventCloseCallback = () => { window.webkit.messageHandlers.onEventClose.postMessage({type: 'eventClose'});
                };

                const onPinpointCloseCallback = () => { window.webkit.messageHandlers.onPinpointClose.postMessage({type: 'pinpointClose'});
                };

                const onGuidingStartedCallback = () => { window.webkit.messageHandlers.onGuidingStarted.postMessage({type: 'guidingStarted'});
                };

                const onGuidingStoppedCallback = () => { window.webkit.messageHandlers.onGuidingStopped.postMessage({type: 'guidingStopped'});
                };

                const onUserLoginCallback = () => { window.webkit.messageHandlers.onUserLogin.postMessage({type: 'userLogin'});
                };

                const onUserLogoutCallback = () => { window.webkit.messageHandlers.onUserLogout.postMessage({type: 'userLogout'});
                };
        
                const onActionButtonClickCallback = (json) => {
                    window.webkit.messageHandlers.onActionButtonClick.postMessage(json);
                };
        
                const onContentUpdatedCallback = (json) => {
                    window.webkit.messageHandlers.onContentUpdated.postMessage(json);
                };

                // AR
                const onStartCameraCallback = () => { window.webkit.messageHandlers.onStartCamera.postMessage({type: 'cameraStarted'});
                };

                const onStopCameraCallback = () => { window.webkit.messageHandlers.onStopCamera.postMessage({type: 'cameraStoped'});
                };

                // RG stuffs
                let handler;
                const onGoToPinpointClickedCallback = pinpoint => { window.webkit.messageHandlers.onGoToPinpointClicked.postMessage({type: 'goToPinpointClicked', data: pinpoint.pinpoint});
                };

                const attachGoToPinpointClick = pinpoint => {
                    const itineraryButton = document.getElementsByClassName('wemap-navigation-button')[0];
                    if (itineraryButton) {
                        handler = () => onGoToPinpointClickedCallback(pinpoint);
                        itineraryButton.addEventListener('click', handler, {once: true});
                    }
                };

                const detachGoToPinpointClick = () => {
                    const itineraryButton = document.getElementsByClassName('wemap-navigation-button')[0];
                    if (itineraryButton) {
                        itineraryButton.removeEventListener('click', handler);
                    }
                };

                let bookEventHandler;
                const onBookEventClickedCallback = event => { window.webkit.messageHandlers.onBookEventClicked.postMessage({type: 'bookEventClicked', data: event.event});
                };

                const attachBookEventClick = event => {
                    const bookEventButton = document.getElementsByClassName('wemap-template-button agenda')[0];
                    if (bookEventButton) {
                        bookEventHandler = () => onBookEventClickedCallback(event);
                        bookEventButton.addEventListener('click', bookEventHandler);
                    }
                };

                const detachBookEventClick = () => {
                    const bookEventButton = document.getElementsByClassName('wemap-template-button agenda')[0];
                    if (bookEventButton) {
                        bookEventButton.removeEventListener('click', bookEventHandler);
                        }
                };

                const onLivemapMovedCallback = (json) => {
                    window.webkit.messageHandlers.onLivemapMoved.postMessage(json);
                };

                const onMapClickCallback = (json) => {
                    window.webkit.messageHandlers.onMapClick.postMessage(json);
                };

                const onMapLongClickCallback = (json) => {
                    window.webkit.messageHandlers.onMapLongClick.postMessage(json);
                };

                promise = window.livemap.addEventListener('eventOpen', onEventOpenCallback);
                promise = window.livemap.addEventListener('pinpointOpen', onPinpointOpenCallback);
                promise = window.livemap.addEventListener('eventClose', onEventCloseCallback);
                promise = window.livemap.addEventListener('pinpointClose', onPinpointCloseCallback);
                promise = window.livemap.addEventListener('guidingStarted', onGuidingStartedCallback);
                promise = window.livemap.addEventListener('guidingStopped', onGuidingStoppedCallback);
                promise = window.livemap.addEventListener('userLogin', onUserLoginCallback);
                promise = window.livemap.addEventListener('userLogout', onUserLogoutCallback);
                promise = window.livemap.addEventListener('livemapMoved', onLivemapMovedCallback);
                promise = window.livemap.addEventListener('mapClick', onMapClickCallback);
                promise = window.livemap.addEventListener('mapLongClick', onMapLongClickCallback);
                promise = window.livemap.addEventListener('actionButtonClick', onActionButtonClickCallback);
                promise = window.livemap.addEventListener('contentUpdated', onContentUpdatedCallback);

                // attach start/stopCamera handler
                try {
                    window.WemapSDK = {};
                    window.WemapSDK.enableCameraNative = onStartCameraCallback;
                    window.WemapSDK.disableCameraNative = onStopCameraCallback
                } catch (e) {
                    window.webkit.messageHandlers.log.postMessage(e.message);
                }

                // RG stuffs

                // onGoToPinpointClickedCallback
                window.livemap.addEventListener('pinpointOpen', attachGoToPinpointClick);
                window.livemap.addEventListener('pinpointClose', detachGoToPinpointClick);

                // onBookEventClickedCallback
                window.livemap.addEventListener('eventOpen', attachBookEventClick);
                window.livemap.addEventListener('eventClose', detachBookEventClick);
            });
        """
        
        webView.evaluateJavaScript(script,
                                   completionHandler: { res, error in
                                    if let res = res {
                                        // debugPrint(res)
                                    }
                                    if let error = error {
                                        // debugPrint(error)
                                    }
        })
    }
    
    internal func onStartCamera () -> Void {
        webView.evaluateJavaScript("window.WemapSDK.enableCameraNative()")
    }

    internal func onStopCamera () -> Void {
        self.webView.evaluateJavaScript("window.WemapSDK.disableCameraNative()")
    }
    
    internal func setPermissionsDenied (permissions: [String]) -> Void {
        let jsonPermissions = "[ \(permissions.map({"'\($0)'"}).joined(separator: ",")) ]"
        self.webView.evaluateJavaScript("window.livemap.setPermissionsDenied(\(jsonPermissions))")
    }
    
    internal func forceARViewMode (mode: ARViewMode) -> Void {
        self.webView.evaluateJavaScript("window.livemap.forceARViewMode('\(mode)')")
    }

    /// Open an event on the map. This can only be used for maps which use events.
    /// - Parameter id: event id
    public func openEvent(WemapEventId id:Int) {
        let script = "promise = window.livemap.openEvent(\(id));"
        webView.evaluateJavaScript(script)
    }

    /// Close the current opened event. Go to the search view.
    public func closeEvent() {
        let script = "promise = window.livemap.closeEvent();"
        webView.evaluateJavaScript(script)
    }

    /// Open a pinpoint on the map.
    /// - Parameter id: id of the pinpoint to open
    public func openPinpoint(WemapPinpointId id:Int) {
        let script = "promise = window.livemap.openPinpoint(\(id));"
        webView.evaluateJavaScript(script)
    }

    /// Close the current opened pinpoint. Go to the search view.
    public func closePinpoint() {
        let script = "promise = window.livemap.closePinpoint();"
        webView.evaluateJavaScript(script)
    }
    
    /// Populates the map with given pinpoints.
    /// - Parameter pinpoints: pinpoints to populate the map.
    // WemapPinpoints pinpoints: [WemapPinpoint]
    public func setPinpoints(WemapPinpoints pinpoints: [WemapPinpoint]) {
        let pinpointsStrings = pinpoints.map { $0.toJsonString() }.joined(separator: ", ")
        let script = "promise = window.livemap.setPinpoints([\(pinpointsStrings)]);"
        webView.evaluateJavaScript(script)
    }

    private func startCamera() {
        arView.set(isHidden: false)
    }

    private func stopCamera() {
        arView.set(isHidden: true)
    }

    /// Update search filters (dates, tags, text).
    /// - Parameters:
    ///   - WemapFilters: Filters to set. See [WemapFilters](./structs/WemapFilters.md "structure WemapLocation").
    public func setFilters(WemapFilters: WemapFilters) {
        let jsonEncoder = JSONEncoder()
        let jsonData = (try? jsonEncoder.encode(WemapFilters))!
        let jsonString = String(data: jsonData, encoding: .utf8)

        if let jsonFilters = jsonString {
            let script = "promise = window.livemap.setFilters(\(jsonFilters));"
            webView.evaluateJavaScript(script)
        }
    }

    /// Start navigation to a pinpoint. The navigation will start with the user location.
    /// - Parameters:
    ///   - id: Id of the destination pinpoint.
    ///   - location: For relative navigation only. Navigation start location. See [WemapLocation](./classes/WemapLocation.md "structure WemapLocation").
    ///   - heading: For relative navigation only. Navigation start heading (in degrees).
    public func navigateToPinpoint(WemapPinpointId id:Int,
                                   location: WemapLocation? = nil,
                                   heading: Int? = nil) {
        self.openPinpoint(WemapPinpointId:id)
        let script = "promise = window.livemap.navigateToPinpoint(\(id));"
        webView.evaluateJavaScript(script)
    }

    /// Stop the currently running navigation.
    public func stopNavigation() {
        let script = "promise = window.livemap.stopNavigation();"
        webView.evaluateJavaScript(script)
    }

    /// Sign in to the UFE with a Wemap token.
    public func signInByToken(accessToken: String) {
        let script = "promise = window.livemap.signInByToken('\(accessToken)');";
        webView.evaluateJavaScript(script)
    }

    /// Activate the bar with several rows of content (of events, pinpoints, list, etc).
    public func enableSidebar() {
        let script = "promise = window.livemap.enableSidebar();"
        webView.evaluateJavaScript(script)
    }

    /// Deactivate the bar with several rows of content (of events, pinpoints, list, etc).
    public func disableSidebar() {
        let script = "promise = window.livemap.disableSidebar();"
        webView.evaluateJavaScript(script)
    }

    /// Sign out the current user.
    public func signOut() {
        let script = "promise = window.livemap.signOut();"
        webView.evaluateJavaScript(script)
    }

    /// Define one or more lists to be displayed on the map in addition of the current pinpoints of the map.
    /// - Parameters:
    ///   - sourceLists: list of sources
    public func setSourceLists(sourceLists: Array<Int>) {
        let script = "promise = window.livemap.setSourceLists(\(sourceLists));"
        webView.evaluateJavaScript(script)
    }

    /// Center the map on the user's location.
    public func aroundMe() {
        let script = "promise = window.livemap.aroundMe();";
        webView.evaluateJavaScript(script)
    }

    /// Disable analytics tracking
    public func disableAnalytics() {
        let script = "promise = window.livemap.disableAnalytics();"
        webView.evaluateJavaScript(script)
    }

    /// Enable analytics tracking
    public func enableAnalytics() {
        let script = "promise = window.livemap.enableAnalytics();"
        webView.evaluateJavaScript(script)
    }
    
    @available(iOS 14.0, *)
    /// Draw a polyline on the map between multiple coordinates.
    /// You can either draw a raw array of coordinates or use our itinerary service to draw a route between multiple points.
    /// - Parameters:
    ///   - coordinatesList: id of lists to be added to the map.
    ///   - options: the polyline options. Please refer to the [JS documentation](/docs/javascript/livemap#livemapdrawpolyline) to check its default values.
    ///   - completion: the completion handler which return the id of the created polyline.
    public func drawPolyline(coordinatesList: [Coordinates], options: PolylineOptions? = nil, completion: ((String)->())? = nil) {
        let coordinatesListString = "[ \(coordinatesList.map({ $0.toJsonString() }).joined(separator: ",")) ]"
        
        let script = """
            return window.livemap.drawPolyline(\(coordinatesListString), \(options?.toJsonString() ?? "undefined")).then(({id}) => id);
        """
                
        webView.callAsyncJavaScript(script, in: nil, in: .page, completionHandler: { result in
            switch result {
            case let .failure(error):
                debugPrint("failure \(error)")
            case let .success(result):
                completion?(result as! String)
            }
        })
    }
    
    /// Remove a polyline from the map.
    /// - Parameter id: id of polyline.
    public func removePolyline(id: String) {
        let script = "promise = window.livemap.removePolyline('\(id)');"
        webView.evaluateJavaScript(script)
    }
    
    /// Center the map on the given position.
    /// - Parameter center: the new center.
    public func setCenter(center: Coordinates) {
        let centerString = center.toJsonString()
        let script = "promise = window.livemap.setCenter(\(centerString));"
        webView.evaluateJavaScript(script)
    }
    
    /// Center the map on the given position and set the zoom level.
    /// - Parameters:
    ///   - center: the new center.
    ///   - zoom: the new zoom level.
    public func centerTo(center: Coordinates, zoom: Double) {
        let centerString = center.toJsonString()
        let script = "promise = window.livemap.centerTo(\(centerString), \(zoom));"
        webView.evaluateJavaScript(script)
    }
}

/// Create a map filter
public struct WemapFilters: Codable {
    let tags: Array<String>?
    let query: String?
    let startDate: String?
    let endDate: String?

    /// - Parameters:
    ///   - tags: The queried tags
    ///   - query: The queried keywords
    ///   - startDate: The start date as yyyy-mm-dd
    ///   - endDate: The end date as yyyy-mm-dd
    public init(tags: Array<String>? = nil,
                query: String? = nil,
                startDate: String? = nil,
                endDate: String? = nil ) {
        self.tags = tags
        self.query = query
        self.startDate = startDate
        self.endDate = endDate
    }
}

/// Create a Wemap location
public struct WemapLocation: Codable {
    private let longitude: Double?
    private let latitude: Double?


    /// - Parameters:
    ///   - longitude: The longitude
    ///   - latitude: The latitude
    public init(longitude: Double,
                latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public struct wemapsdk_config {
    public init(
        token: String?,
        mapId: Int? = nil,
        livemapRootUrl: String? = nil,
        maxbounds: BoundingBox? = nil,
        introcard: IntroCardParameter? = nil,
        urlParameters: [String]? = nil,
        enablePolestar: Bool = false
    ) {
        self.token = token ?? ""
        if let mapId = mapId {
            self.emmid = mapId
        } else {
            self.emmid = -1
            self.ufe = true
        }
        self.livemapRootUrl = (livemapRootUrl ?? wemapsdk_config.defaultLivemapRootUrl) + "/dom.html"
        self.maxbounds = maxbounds ?? nil
        self.introcard = introcard ?? nil
        self.urlParameters = urlParameters ?? nil
        self.enablePolestar = enablePolestar
    }

    public static let defaultLivemapRootUrl = "https://livemap.getwemap.com"
    public let token: String
    public let emmid: Int
    public var ufe: Bool = false
    public let livemapRootUrl: String
    public let maxbounds: BoundingBox?
    public let introcard: IntroCardParameter?
    public let urlParameters: [String]?
    public let enablePolestar: Bool
}

enum WebCommands: String {

    case parametersLoaded
    case onLoadingFinished
    case onEventOpen
    case onPinpointOpen
    case onEventClose
    case onPinpointClose
    case onGuidingStarted
    case onGuidingStopped
    case onStartCamera
    case onStopCamera
    case log
    case onUserLogin
    case onUserLogout
    case onActionButtonClick
    case onContentUpdated

    // RG stuffs
    case onBookEventClicked
    case onGoToPinpointClicked
    
    case onLivemapMoved
    case onMapClick
    case onMapLongClick

    static let values = [parametersLoaded.rawValue,
                         onLoadingFinished.rawValue,
                         onEventOpen.rawValue,
                         onPinpointOpen.rawValue,
                         onEventClose.rawValue,
                         onPinpointClose.rawValue,
                         onGuidingStarted.rawValue,
                         onGuidingStopped.rawValue,
                         onStartCamera.rawValue,
                         onStopCamera.rawValue,
                         log.rawValue,
                         onBookEventClicked.rawValue,
                         onGoToPinpointClicked.rawValue,
                         onUserLogin.rawValue,
                         onUserLogout.rawValue,
                         onLivemapMoved.rawValue,
                         onMapClick.rawValue,
                         onMapLongClick.rawValue,
                         onActionButtonClick.rawValue,
                         onContentUpdated.rawValue]
}
