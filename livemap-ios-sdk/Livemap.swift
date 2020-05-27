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

    // RG stuffs
    @objc optional func onBookEventClicked(_ wemapController: wemapsdk, event: WemapEvent)
    @objc optional func onGoToPinpointClicked(_ wemapController: wemapsdk, pinpoint: WemapPinpoint)
}

public class WemapEvent: NSObject {
    public var id:Int
    public var name: String;
    public var eventDescription: String;
    // public var pinpoint: WemapPinpoint;
    public var external_data: NSDictionary?

    init(_ json: NSDictionary) {
        self.id = json["id"] as! Int
        self.name = json["name"] as! String
        self.eventDescription = json["description"] as! String
        // self.pinpoint = json["pinpoint"] as! WemapPinpoint
        if let external_data = json["external_data"] {
            self.external_data = external_data as? NSDictionary
        } else {
            self.external_data = nil
        }
    }
}

public class WemapPinpoint: NSObject {
    public var id:Int
    public var longitude: Double
    public var latitude: Double
    // public var altitude: Double
    public var name: String
    // public var type: Int
    // public var category: Int
    public var pinpointDescription: String
    public var external_data: NSDictionary?

    init(_ json: NSDictionary) {
        self.id = json["id"] as! Int
        self.longitude = json["longitude"] as! Double
        self.latitude = json["latitude"] as! Double
        // self.altitude = json["altitude"] as! Double
        self.name = json["name"] as! String
        // self.type = json["type"] as! Int
        // self.category = json["category"] as! Int
        self.pinpointDescription = json["description"] as! String
        if let external_data = json["external_data"] {
            self.external_data = external_data as? NSDictionary
        } else {
            self.external_data = nil
        }
    }
}

public class wemapsdk: UIView {
    public static let sharedInstance = wemapsdk(frame: CGRect.zero)

    fileprivate static let baseURL = "https://livemap.getwemap.com/embed.html?"
    fileprivate var configuration: wemapsdk_config!
    fileprivate var webView: WKWebView!

    fileprivate lazy var mapViewConfig: WKWebViewConfiguration = {
        let contentController = WKUserContentController()

        WebCommands.values.forEach { contentController.add(self, name: $0) }

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        return config
    }()

    weak open var delegate: wemapsdkViewDelegate?

    override private init(frame: CGRect) {
        super.init(frame: frame)
        webView = WKWebView(frame: frame, configuration: mapViewConfig)
        webView.navigationDelegate = self

        configuration = wemapsdk_config(token: "", mapId: -1)
        self.addSubview(webView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        webView.frame = self.bounds
    }

    func onLoadingFinished() {
        delegate?.waitForReady!(self)
    }

    func onEventOpen(_ event: WemapEvent) {
        delegate?.onEventOpen!(self, event: event)
    }

    func onPinpointOpen(_ pinpoint: WemapPinpoint) {
        delegate?.onPinpointOpen!(self, pinpoint: pinpoint)
    }

    func onEventClose() {
        delegate?.onEventClose!(self)
    }

    func onPinpointClose() {
        delegate?.onPinpointClose!(self)
    }

    func onGuidingStart() {
        delegate?.onGuidingStarted!(self)
    }

    func onGuidingStopped() {
        delegate?.onGuidingStopped!(self)
    }

    // RG stuffs
    func onBookEventClicked(_ event: WemapEvent) {
        delegate?.onBookEventClicked!(self, event: event)
    }

    func onGoToPinpointClicked(_ pinpoint: WemapPinpoint) {
        delegate?.onGoToPinpointClicked!(self, pinpoint: pinpoint)
    }
}

extension wemapsdk: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        self.waitForReady()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
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

        webView.frame = self.bounds

        var urlStr = ""
        if (configuration.mapId == -1) {
            urlStr = "\(wemapsdk.baseURL)dist=ufe"
        } else {
            urlStr = "\(wemapsdk.baseURL)token=\(configuration.token)&emmid=\(configuration.mapId)&method=dom"
        }

        webView.load(
            URLRequest(url: URL(string: urlStr)!))

        return self
    }
}

extension wemapsdk: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // debugPrint("\(#function) :::: message [\(message.name)] :::: with body: \n\(message.body)\n<<<")

        guard let command = WebCommands(rawValue: message.name) else { return }
        switch command {

        case .onLoadingFinished:
            self.attachHandlers()
            onLoadingFinished()

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

        default:
            debugPrint("WARNING: Not supported message: \(message.name)")
        }
    }
}

extension wemapsdk {

    func waitForReady() {
        let script = """
            let promise = window.livemap.waitForReady();
            promise.then(() => {
                window.webkit.messageHandlers.onLoadingFinished.postMessage({type: 'livemapReady'});
            });
        """
        webView.evaluateJavaScript(script)
    }


    func attachHandlers() {
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

                promise = window.livemap.addEventListener('eventOpen', onEventOpenCallback);
                promise = window.livemap.addEventListener('pinpointOpen', onPinpointOpenCallback);
                promise = window.livemap.addEventListener('eventClose', onEventCloseCallback);
                promise = window.livemap.addEventListener('pinpointClose', onPinpointCloseCallback);
                promise = window.livemap.addEventListener('guidingStarted', onGuidingStartedCallback);
                promise = window.livemap.addEventListener('guidingStopped', onGuidingStoppedCallback);

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

    public func openEvent(WemapEventId id:Int) {
        let script = "promise = window.livemap.openEvent(\(id));"
        webView.evaluateJavaScript(script)
    }

    public func closeEvent() {
        let script = "promise = window.livemap.closeEvent();"
        webView.evaluateJavaScript(script)
    }

    public func openPinpoint(WemapPinpointId id:Int) {
        let script = "promise = window.livemap.openPinpoint(\(id));"
        webView.evaluateJavaScript(script)
    }

    public func closePinpoint() {
        let script = "promise = window.livemap.closePinpoint();"
        webView.evaluateJavaScript(script)
    }

    public func setFilters(WemapFilters: WemapFilters) {
        let jsonEncoder = JSONEncoder()
        let jsonData = (try? jsonEncoder.encode(WemapFilters))!
        let jsonString = String(data: jsonData, encoding: .utf8)

        if let jsonFilters = jsonString {
            let script = "promise = window.livemap.setFilters(\(jsonFilters));"
            webView.evaluateJavaScript(script)
        }
    }

    public func navigateToPinpoint(WemapPinpointId id:Int,
                                   location: WemapLocation? = nil,
                                   heading: Int? = nil) {
        let script = "promise = window.livemap.navigateToPinpoint(\(id));"
        webView.evaluateJavaScript(script)
    }

    public func stopNavigation() {
        let script = "promise = window.livemap.stopNavigation();"
        webView.evaluateJavaScript(script)
    }
}

public struct WemapFilters: Codable {
    let tags: Array<String>?
    let query: String?
    let startDate: String?
    let endDate: String?

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

public struct WemapLocation: Codable {
    let longitude: Double?
    let latitude: Double?

    public init(longitude: Double,
                latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

public struct wemapsdk_config {
    public init(token: String, mapId: Int) {
        self.token = token
        self.mapId = mapId
    }

    public let token: String
    public let mapId: Int
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

    // RG stuffs
    case onBookEventClicked
    case onGoToPinpointClicked

    static let values = [parametersLoaded.rawValue,
                         onLoadingFinished.rawValue,
                         onEventOpen.rawValue,
                         onPinpointOpen.rawValue,
                         onEventClose.rawValue,
                         onPinpointClose.rawValue,
                         onGuidingStarted.rawValue,
                         onGuidingStopped.rawValue,
                         onBookEventClicked.rawValue,
                         onGoToPinpointClicked.rawValue]
}
