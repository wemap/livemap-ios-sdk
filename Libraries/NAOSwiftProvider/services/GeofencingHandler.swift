//
//  GeofencingHandler.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 15/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule

public class GeofencingHandler: ServiceProvider, NAOGeofenceHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate{
    
    var geofencingHandler: NAOGeofencingHandle? = nil
    
    // GeofencingHandlerDelegate
    public weak var delegate: GeofencingHandlerDelegate?
    
    required public init(apikey: String) {
        super.init(apikey: apikey)
        
        self.geofencingHandler = NAOGeofencingHandle(key: apikey, delegate: self, sensorsDelegate: self)
        self.geofencingHandler?.synchronizeData(self)
    }
    
    override public func start() {
        if (!self.status){
            self.geofencingHandler?.start()
        }
        self.status = true
    }
    
    override public func stop() {
        if (self.status){
            self.geofencingHandler?.stop()
        }
        self.status = false
    }
    
    // MARK: - NAOGeofenceHandleDelegate
    public func didEnterGeofence(_ regionId: Int32, andName regionName: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didEnterGeofence(regionId,andName:regionName )
            }
        }
    }
    
    public func didExitGeofence(_ regionId: Int32, andName regionName: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didExitGeofence(regionId,andName:regionName)
            }
        }
    }
    
    public func didFire(_ alert: NaoAlert!) {
        let alertContent = alert.content
        if !alertContent!.isEmpty {
            DispatchQueue.main.async {
                if let delegate = self.delegate {
                    delegate.didFire("Alert received: \(String(describing: alert.content))")
                }
            }
        }
    }
    
    public func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didGeofencingFailWithErrorCode("NAOGeofencingHandle fails: \(String(describing: message)) with error code \(errCode)")
            }
        }
    }
    
    // MARK: - NAOSensorsDelegate
    
    public func requiresWifiOn() {
        //Post the requiresWifiOn notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.requiresWifiOn()
            }
        }
    }
    
    public func requiresBLEOn() {
        //Post the requiresBLEOn notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.requiresBLEOn()
            }
        }
    }
    
    public func requiresLocationOn() {
        //Post the requiresLocationOn notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.requiresLocationOn()
            }
        }
    }
    
    public func requiresCompassCalibration() {
        //Post the requiresCompassCalibration notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.requiresCompassCalibration()
            }
        }
    }
    
     // MARK: - NAOSyncDelegate --
    
    public func didSynchronizationSuccess() {
        //Post the didSynchronizationSuccess notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didSynchronizationSuccess()
            }
        }
    }
    
    public func didSynchronizationFailure(_ errorCode: DBNAOERRORCODE, msg message: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didSynchronizationFailure("The synchronization fail: \(String(describing: message)) with error code \(errorCode)")
            }
        }
    }
    
    deinit {
        print("GeofencingHandler deinitialized")
    }
}
