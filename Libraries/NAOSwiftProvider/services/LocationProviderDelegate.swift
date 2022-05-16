//
//  LocationProviderDelegate.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 14/02/2020.
//
import Foundation
import UIKit
import NAOSDKModule

public protocol LocationProviderDelegate: AnyObject{
    // Classes that adopt this protocol MUST define
    // this method -- it is called when the location has changed
    func didLocationChange(_ location: CLLocation!)
    
    func didLocationStatusChanged(_ status: String!)
    
    func didEnterSite (_ name: String!)
    
    func didExitSite (_ name: String!)
    
    func didApikeyReceived (_ apikey: String!)
    
    func didLocationFailWithErrorCode(_ message: String!)
    
    // MARK: - NAOSensorsDelegate
    func requiresWifiOn()

    func requiresBLEOn()

    func requiresLocationOn()

    func requiresCompassCalibration()

     // MARK: - NAOSyncDelegate --

    func didSynchronizationSuccess()
    
    func didSynchronizationFailure(_ message: String!)
    
    
}
