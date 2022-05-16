//
//  TrackingProvider.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 19/10/2021.
//

import UIKit


import UIKit
import NAOSDKModule

public class TrackingProvider: ServiceProvider, NAOTrackingHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate {
    
    
    var trackingHandle: NAOTrackingHandle? = nil
    
    // TrackingProviderDelegate
    public weak var delegate: TrackingProviderDelegate?
    
    required public init(apikey: String) {
        super.init(apikey: apikey)
        
        self.trackingHandle = NAOTrackingHandle(key: apikey, delegate: self, sensorsDelegate: self)
        self.trackingHandle?.synchronizeData(self)
    }
    
    override public func start() {
        if (!self.status){
            self.trackingHandle?.start()
        }
    }
    
    override public func stop() {
        if (self.status){
            self.trackingHandle?.stop()
        }
        self.status = false
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
    
    public func didFailWithErrorCode(_ errorCode: DBNAOERRORCODE, andMessage message: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didFailWithErrorCode("NAOTrackingHandle fails: \(String(describing: message)) with error code \(errorCode)")
            }
        }
    }
     
    public func synchronizeData (delegate: NAOSyncDelegate) {
        self.trackingHandle?.synchronizeData(delegate)
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
    
    deinit {
        print("TrackingProvider deinitialized")
    }
}
