//
//  PolestarLocationProvider.swift
//  livemap-ios-sdk
//
//  Created by Thibault Capelli on 23/05/2022.
//

import CoreLocation

class PolestarLocationProvider: LocationProvider, LocationProviderDelegate {
    internal var didLocationChangeCallback: ((_ coordinates: PolestarCoordinates) -> Void)? = nil;
    
    required init(apikey: String) {
        super.init(apikey: apikey)
    }
    
    override func didLocationChange(_ location: CLLocation!) {
        let coordinates = PolestarCoordinates(lat: location.coordinate.latitude, lng: location.coordinate.longitude, alt: location.altitude, accuracy: location.horizontalAccuracy, time: Int(location.timestamp.timeIntervalSince1970 * 1000), bearing: location.course);

        if let didLocationChangeCallback = self.didLocationChangeCallback {
            didLocationChangeCallback(coordinates);
        }
    }
    
    func didApikeyReceived(_ apikey: String!) {}
    
    func didLocationStatusChanged(_ status: String!) {}
    
    override func didEnterSite(_ name: String!) {}
    
    override func didExitSite(_ name: String!) {}
    
    func didLocationFailWithErrorCode(_ message: String!) {}
    
    func didSynchronizationFailure(_ message: String!) {}
    
}
