//
//  BeaconReportingProviderDelegate.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 31/03/2020.
//

import Foundation
import UIKit
import NAOSDKModule

public protocol BeaconReportingProviderDelegate: AnyObject{
    // MARK: - NAOBeaconReportingHandleDelegate
    func didBeaconReportingFailWithErrorCode(_ message: String!)
    
    // MARK: - NAOSensorsDelegate
    func requiresWifiOn()

    func requiresBLEOn()

    func requiresLocationOn()

    func requiresCompassCalibration()

     // MARK: - NAOSyncDelegate --

    func didSynchronizationSuccess()
    
    func didSynchronizationFailure(_ message: String!)
}

