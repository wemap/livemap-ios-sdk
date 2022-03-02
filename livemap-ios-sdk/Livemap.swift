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

    // RG stuffs
    @objc optional func onBookEventClicked(_ wemapController: wemapsdk, event: WemapEvent)
    @objc optional func onGoToPinpointClicked(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
    
    @objc optional func onMapMoved(_ wemapController: wemapsdk, json: NSDictionary)
    @objc optional func onMapClick(_ wemapController: wemapsdk, json: NSDictionary)
    @objc optional func onMapLongClick(_ wemapController: wemapsdk, json: NSDictionary)
}

/// Create a Wemap Event
public class WemapEvent: NSObject {
    public let id:Int
    public let name: String;
    public let eventDescription: String;
    public let pinpoint: WemapPinpoint?;
    public let external_data: NSDictionary?

    /// - Parameter json: { id, name, description, external_data }
    public init(_ json: NSDictionary) {
        self.id = json["id"] as! Int
        self.name = json["name"] as! String
        self.eventDescription = json["description"] as! String
        // self.pinpoint = json["point"] as? WemapPinpoint ?? nil // pareil que:
        self.pinpoint = WemapPinpoint(json["point"] as! NSDictionary)
        if let external_data = json["external_data"] {
            self.external_data = external_data as? NSDictionary
        } else {
            self.external_data = nil
        }
    }
}

/// Create a Wemap Pinpoint
public class WemapPinpoint: NSObject {
    public let data:NSDictionary
    public let id:Int
    public let longitude: Double
    public let latitude: Double
    public let name: String
    public let pinpointDescription: String
    public let external_data: NSDictionary?
    // public var type: Int
    // public var category: Int

    /// - Parameter json: { id, longitude, latitude, name, description, external_data }
    public init(_ json: NSDictionary) {
        self.data = json
        self.id = json["id"] as! Int
        self.longitude = json["longitude"] as! Double
        self.latitude = json["latitude"] as! Double
        self.name = json["name"] as! String
        self.pinpointDescription = json["description"] as! String
        if let external_data = json["external_data"] {
            self.external_data = external_data as? NSDictionary
        } else {
            self.external_data = nil
        }
    }
    
    public func toJson() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self.data, options: [])
        } catch {
            return nil
        }
    }

    public func toJsonString() -> String {
        return String(data: self.toJson()!, encoding: String.Encoding.ascii)!
    }
}

public class wemapsdk: UIView, WKUIDelegate {
    public static let sharedInstance = wemapsdk(frame: CGRect.zero)

    private var configuration: wemapsdk_config!
    private var webView: WKWebView!
    private var arView: CustomARView!
    private var currentUrl: String = ""

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

        arView = CustomARView(frame: frame)
        arView.set(webMapView: webView)

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
    
    // Objective C uses a NSDictionary
    func onMapMoved(parsedStruct: MapMoved) {
        if let json = MapMoved.toNSDictionary(parsedStruct: parsedStruct) {
            delegate?.onMapMoved?(self, json: json)
        }
    }
    
    func onMapClick(parsedStruct: Coordinates) {
        if let json = Coordinates.toNSDictionary(parsedStruct: parsedStruct) {
            delegate?.onMapClick?(self, json: json)
        }
    }
    
    func onMapLongClick(parsedStruct: Coordinates) {
        if let json = Coordinates.toNSDictionary(parsedStruct: parsedStruct) {
            delegate?.onMapLongClick?(self, json: json)
        }
    }
}

extension wemapsdk: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        self.waitForReady()
    }

    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("didFail")
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
        var urlStr = configuration.livemapRootUrl + "/dom.html?"
        if (configuration.ufe) {
            urlStr += "dist=ufe&arviewenabled=true&routingtype=osrm&routingmode=walking&routingurl=https://routingdev.maaap.it&homecontrol=false&clicktofullscreen=false"
        } else {
            urlStr += "token=\(configuration.token)&emmid=\(configuration.emmid)&clicktofullscreen=false"

            if (configuration.maxbounds != nil)
            {
                if let box: String = wemapsdk_config.maxBoundsToUrl(maxbounds: configuration.maxbounds) {
                    // without encoding, URL() becomes nil during creation
                    urlStr += "&maxbounds=" + box.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                }
            }

            if (configuration.introcard != nil)
            {
                if let introcard: String = wemapsdk_config.introcardToUrl(introcard: configuration.introcard) {
                    // without encoding, URL() becomes nil during creation
                    urlStr += "&introcard=" + introcard.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                }
            }

            if (configuration.urlParameters != nil)
            {
                urlStr += "&" + configuration.urlParameters!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            }
        }
        webView.load(
            URLRequest(url: URL(string: urlStr)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        )

        if (self.currentUrl == "") {
            self.currentUrl = urlStr;
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

        case .log:
            debugPrint("Log From webview: \(message.body)")
            
        case .onUserLogin:
            // debugPrint("USER_LOGIN")
            onUserLogin()
            
        case .onUserLogout:
            // debugPrint("USER_LOGOUT")
            onUserLogout()

        case .onLivemapMoved:
            // https://stackoverflow.com/questions/64992931/how-do-i-convert-a-wkscriptmessage-body-to-a-struct
            if let bodyDict = message.body as? NSDictionary {
                if let parsedStruct: MapMoved = MapMoved.map(dict: bodyDict) {
                    onMapMoved(parsedStruct: parsedStruct)
                }
            }

        case .onMapClick:
            if let bodyDict = message.body as? NSDictionary {
                if let parsedStruct: Coordinates = Coordinates.map(dict: bodyDict) {
                    onMapClick(parsedStruct: parsedStruct)
                }
            }
       
        case .onMapLongClick:
            if let bodyDict = message.body as? NSDictionary {
                if let parsedStruct: Coordinates = Coordinates.map(dict: bodyDict) {
                    onMapLongClick(parsedStruct: parsedStruct)
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
        token: String?, mapId: Int? = nil, livemapRootUrl: String? = nil, maxbounds: BoundingBox? = nil,
        introcard: IntroCardParameter? = nil,
        urlParameters: [String]? = nil
    ) {
        self.token = token ?? ""
        if let mapId = mapId {
            self.emmid = mapId
        } else {
            self.emmid = -1
            self.ufe = true
        }
        self.livemapRootUrl = livemapRootUrl ?? wemapsdk_config.defaultLivemapRootUrl
        self.maxbounds = maxbounds ?? nil
        self.introcard = introcard ?? nil
        let join1 = urlParameters?.joined(separator: "&")
        self.urlParameters = join1 ?? nil
    }

    public static let defaultLivemapRootUrl = "https://livemap.getwemap.com"

    public static func boundingBoxFromNSDictionary(dict: NSDictionary) -> BoundingBox? {
        return BoundingBox.map(dict: dict)
    }

    public static func maxBoundsFromUrl(maxbounds: String) -> BoundingBox? {
        if let parsedStruct: MaxBoundsSnippet = MaxBoundsSnippet.map(string: maxbounds) {
            let result: BoundingBox = BoundingBox(
                northEast: Coordinates(latitude: parsedStruct._northEast?.lat, longitude: parsedStruct._northEast?.lng, altitude: nil),
                southWest: Coordinates(latitude: parsedStruct._southWest?.lat, longitude: parsedStruct._southWest?.lng, altitude: nil)
            )
            return result
        }
        return nil
    }

    public static func maxBoundsToUrl(maxbounds: BoundingBox?) -> String? {
        if (maxbounds == nil) {
            return nil
        }
        let maxbounds2: BoundingBox = maxbounds!
        let result: MaxBoundsSnippet = MaxBoundsSnippet(
            _northEast: MaxBoundsSnippetCoords(lat: maxbounds2.northEast?.latitude, lng: maxbounds2.northEast?.longitude),
            _southWest: MaxBoundsSnippetCoords(lat: maxbounds2.southWest?.latitude, lng: maxbounds2.southWest?.longitude)
        )
        return MaxBoundsSnippet.toJsonString(parsedStruct: result)
    }

    public static func introcardToUrl(introcard: IntroCardParameter?) -> String? {
        if (introcard == nil) {
            return nil
        }
        return IntroCardParameter.toJsonString(parsedStruct: introcard!)
    }

    public let token: String
    public let emmid: Int
    public var ufe: Bool = false
    public let livemapRootUrl: String
    public let maxbounds: BoundingBox?
    public let introcard: IntroCardParameter?
    public let urlParameters: String?
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
                         onMapLongClick.rawValue]
}
