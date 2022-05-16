//
//  GeofencingHandlerDelegate.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 31/03/2020.
//

import Foundation
import UIKit
import NAOSDKModule

public protocol GeofencingHandlerDelegate: AnyObject{
    
    // MARK: - NAOGeofenceHandleDelegate
    func didEnterGeofence(_ regionId: Int32, andName regionName: String!)
    
    func didExitGeofence(_ regionId: Int32, andName regionName: String!)
    
    func didFire(_ message: String!)
    
    func didGeofencingFailWithErrorCode(_ message: String!)
    
    // MARK: - NAOSensorsDelegate
    func requiresWifiOn()

    func requiresBLEOn()

    func requiresLocationOn()

    func requiresCompassCalibration()

     // MARK: - NAOSyncDelegate --

    func didSynchronizationSuccess()
    
    func didSynchronizationFailure(_ message: String!)
}
