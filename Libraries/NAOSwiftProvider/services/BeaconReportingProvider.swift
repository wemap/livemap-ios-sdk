//
//  BeaconReportingProvider.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 16/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule

public class BeaconReportingProvider: ServiceProvider, NAOBeaconReportingHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate {
    
     var beaconReportingHandler: NAOBeaconReportingHandle? = nil
    
    // BeaconReportingProviderDelegate
    public weak var delegate: BeaconReportingProviderDelegate?
    
     required public init(apikey: String) {
         super.init(apikey: apikey)
         
         self.beaconReportingHandler = NAOBeaconReportingHandle(key: apikey, delegate: self, sensorsDelegate: self)
         self.beaconReportingHandler?.synchronizeData(self)
     }
     
     override public func start() {
         if (!self.status){
             self.beaconReportingHandler?.start()
         }
         self.status = true
     }
     
     override public func stop() {
         if (self.status){
             self.beaconReportingHandler?.stop()
         }
         self.status = false
     }
     
     // MARK: - NAOBeaconReportingHandleDelegate
     public func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
       DispatchQueue.main.async {
           if let delegate = self.delegate {
               delegate.didBeaconReportingFailWithErrorCode("BeaconReporting fail: \(String(describing: message)) with error code \(errCode)")
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
         print("BeaconReportingProvider deinitialized")
     }
}
