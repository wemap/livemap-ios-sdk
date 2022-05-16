//
//  LocationProvider.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 15/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule

public class LocationProvider: ServiceProvider, NAOLocationHandleDelegate, NAOSyncDelegate, NAOSensorsDelegate {
    
    
    var locationHandle: NAOLocationHandle? = nil
    
    // LocationProviderDelegate
    public weak var delegate: LocationProviderDelegate?
    
    required public init(apikey: String) {
        super.init(apikey: apikey)
        
        self.locationHandle = NAOLocationHandle(key: apikey, delegate: self, sensorsDelegate: self)
        self.locationHandle?.synchronizeData(self)
    }
    
    override public func start() {
        if (!self.status){
            self.locationHandle?.start()
        }
        delegate?.didApikeyReceived (apikey)
    }
    
    override public func stop() {
        if (self.status){
            self.locationHandle?.stop()
        }
        self.status = false
    }
    
    /*
        @brief Restarting the location service.
        @param[in]  void
        @return True if the service has successful restarted, and false otherwise
     */
    public func restart () -> Bool? {
        return self.locationHandle?.restart()
    }
    
    public func synchronizeData (delegate: NAOSyncDelegate) {
        self.locationHandle?.synchronizeData(delegate)
    }

    public func synchronizeData (delegate: NAOSyncDelegate, with autoSync: Bool) {
        self.locationHandle?.synchronizeData(delegate, withAutoSync: autoSync)
    }

    public func synchronizeData (delegate: NAOSyncDelegate, for sites:[NSArray]) {
        self.locationHandle?.synchronizeData(delegate, forSites: sites)
    }
    
    /*
        @brief Setting the power mode getter.
        @param[in]  power mode
        @return void
     */
    public func setPowerMode (power: DBTPOWERMODE) {
        self.locationHandle?.setPowerMode(power);
    }

    /*
        @brief The power mode getter.
        @param[in]  void
        @return It returns the power mode of the service handle
     */
    public func getPowerMode () -> DBTPOWERMODE? {
        return self.locationHandle?.getPowerMode();
    }


    /*
        @brief Sets maximum number of calibration requests.
        @detail In some venues, magnetic interferences can cause frequent device compass decalibration. This method provides a way to reduce notification spam to the user.
        @param[in] max Maximum number of calibration requests to be issued. Default is -1, which is infinity. Set it to 0 to always ignore the notification.
        @return void
     */
    public func setCompassCalibrationScreenShowedMaxNumber(max_cal: Int32) {
        self.locationHandle?.setCompassCalibrationScreenShowedMaxNumber(max_cal)
    }
    /*
        @brief Sets minimum interval between calibration requests.
        @detail Provides a way to control how often the end user will be prompted about compass calibration.
        @param[in] nSec    Minimum time interval between two calibration requests, in seconds. Default is 1800 seconds (30 minutes).
     */
    public func setTimeMinBetweenCompassCalibrationScreen (to nSec: Int32) {
        self.locationHandle?.setTimeMinBetweenCompassCalibrationScreen(nSec)
    }

    /*
        @brief: Resets the number of times the calibration has been displayed.
        @param [in] None
        @return void
     */
    public func resetCompassCalibrationScreenShowed(){
        self.locationHandle?.resetCompassCalibrationScreenShowed()
    }

    public func getLastKnownLocation() -> CLLocation? {
        return self.locationHandle?.getLastKnownLocation()
    }
    
    // MARK: - NAOLocationHandleDelegate --
     
    public func didEnterSite (_ name: String){
        //Post the didEnterSite notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didEnterSite(name)
            }
        }
    }


    public func didExitSite (_ name: String){
        //Post the didExitSite notification
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didExitSite(name)
            }
        }
    }

    public func didLocationChange(_ location: CLLocation!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didLocationChange(location)
            }
        }
    }

    public func didLocationStatusChanged(_ status: DBTNAOFIXSTATUS) {
        var statusMessage = ""
        switch (status) {
            case DBTNAOFIXSTATUS.NAO_FIX_UNAVAILABLE:
                statusMessage = "LOCATION STATUS: FIX_UNAVAILABLE"
                break;
            case DBTNAOFIXSTATUS.NAO_FIX_AVAILABLE:
                statusMessage = "LOCATION STATUS: UNAVAILABLE"
                break;
            case DBTNAOFIXSTATUS.NAO_TEMPORARY_UNAVAILABLE:
                statusMessage = "LOCATION STATUS: TEMPORARY_UNAVAILABLE"
                break;
            case DBTNAOFIXSTATUS.NAO_OUT_OF_SERVICE:
                statusMessage = "LOCATION STATUS: OUT_OF_SERVICE"
                break;
            default:
                statusMessage = "LOCATION STATUS: UNKNOWN"
                break;
        }
        
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didLocationStatusChanged(statusMessage)
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
    
    public func didFailWithErrorCode(_ errCode: DBNAOERRORCODE, andMessage message: String!) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didLocationFailWithErrorCode("NAOLocationHandle fails: \(String(describing: message)) with error code \(errCode)")
            }
        }
    }

    deinit {
        print("LocationProvider deinitialized")
    }
}

