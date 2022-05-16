//
//  TrackingProviderDelegate.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 19/10/2021.
//

import Foundation
import UIKit
import NAOSDKModule

public protocol TrackingProviderDelegate: AnyObject{
    // Classes that adopt this protocol MUST define
    // this method -- it is called when the location has changed
    
    // MARK: - NAOSensorsDelegate
    func requiresWifiOn()
    
    func requiresBLEOn()
    
    func requiresLocationOn()
    
    func requiresCompassCalibration()

     // MARK: - NAOSyncDelegate --
    
    func didFailWithErrorCode(_ message: String!)
    
    func didSynchronizationSuccess()
    
    func didSynchronizationFailure(_ message: String!)

}

