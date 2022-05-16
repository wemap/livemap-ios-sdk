//
//  AnalyticsProvider.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 16/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule

public class AnalyticsProvider: ServiceProvider, NAOAnalyticsHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate {
    
    var analyticHandler: NAOAnalyticsHandle? = nil

    public weak var delegate: AnalyticsProviderDelegate?
    
     required public init(apikey: String) {
         super.init(apikey: apikey)
         
         self.analyticHandler = NAOAnalyticsHandle(key: apikey, delegate: self, sensorsDelegate: self)
         self.analyticHandler?.synchronizeData(self)
     }
     
     override public func start() {
         if (!self.status){
             self.analyticHandler?.start()
         }
         self.status = true
     }
     
     override public func stop() {
         if (self.status){
             self.analyticHandler?.stop()
         }
         self.status = false
     }
     
    // MARK: - NAOAnalyticsHandleDelegate
    public func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
         DispatchQueue.main.async {
             if let delegate = self.delegate {
                 delegate.didAnalyticsFailWithErrorCode("Analytics fails: \(String(describing: message)) with error code \(errCode)")
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
         print("AnalyticsProvider deinitialized")
     }
}
