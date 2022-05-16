//
//  BeaconProximityProvider.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 16/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule



class BeaconProximityProvider: ServiceProvider, NAOBeaconProximityHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate {

    var beaconProximityHandler: NAOBeaconProximityHandle? = nil
    
    // Delegates
    public weak var delegate: BeaconProximityProviderDelegate?
    
     required public init(apikey: String) {
         super.init(apikey: apikey)
         
         self.beaconProximityHandler = NAOBeaconProximityHandle(key: apikey, delegate: self, sensorsDelegate: self)
         self.beaconProximityHandler?.synchronizeData(self)
     }
     
     override public func start() {
         if (!self.status){
             self.beaconProximityHandler?.start()
         }
         self.status = true
     }
     
     override public func stop() {
         if (self.status){
             self.beaconProximityHandler?.stop()
         }
         self.status = false
     }
     
    // MARK: - NAOBeaconProximityHandleDelegate
    public func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didBeaconProximityFailWithErrorCode("BeaconProximity fail: \(String(describing: message)) with error code \(errCode)")
            }
        }
    }

    public func didRangeBeacon(_ beaconPublicID: String!, withRssi rssi: Int32) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didRangeBeacon(beaconPublicID, withRssi: rssi)
            }
        }
    }
    
    public func didProximityChange(_ proximity: DBTBEACONSTATE, forBeacon beaconPublicID: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didProximityChange("\(proximity)", forBeacon: beaconPublicID)
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
        print("BeaconProximityProvider deinitialized")
    }
}
