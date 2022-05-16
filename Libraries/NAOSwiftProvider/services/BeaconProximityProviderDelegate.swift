//
//  BeaconProximityProviderDelegate.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 31/03/2020.
//

import Foundation
import UIKit
import NAOSDKModule


public protocol BeaconProximityProviderDelegate: AnyObject{
    
    // MARK: - NAOBeaconProximityHandleDelegate
    func didRangeBeacon(_ beaconPublicID: String!, withRssi rssi: Int32)

    func didProximityChange(_ proximity: String!, forBeacon beaconPublicID: String!)

    func didBeaconProximityFailWithErrorCode(_ message: String!)

    // MARK: - NAOSensorsDelegate
    func requiresWifiOn()

    func requiresBLEOn()

    func requiresLocationOn()

    func requiresCompassCalibration()

    // MARK: - NAOSyncDelegate --

    func didSynchronizationSuccess()

    func didSynchronizationFailure(_ message: String!)
}
