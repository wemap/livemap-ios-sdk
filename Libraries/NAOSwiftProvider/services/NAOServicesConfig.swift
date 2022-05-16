//
//  NAOServicesConfig.swift
//  NAOSwiftProvider
//
//  Created by Pole Star on 20/10/2021.
//

import UIKit


import UIKit
import NAOSDKModule

public class NAOServicesConfig {
    
    required public init() {
    }
    
    static public func getSoftwareVersion() -> String {
        return NAOSDKModule.NAOServicesConfig.getSoftwareVersion()
    }
    
    static public func getRootURL() -> String {
        return NAOSDKModule.NAOServicesConfig.getRootURL()
    }
    
    static public func setRootURL(_ rootUrl: String) {
        NAOSDKModule.NAOServicesConfig.setRootURL(rootUrl)
    }
    
    static public func getPowerMode() -> DBTPOWERMODE {
        return NAOSDKModule.NAOServicesConfig.getPowerMode()
    }
    
    static public func synchronizeData(_ delegate: NAOSyncDelegate, with apiKey: String) {
        NAOSDKModule.NAOServicesConfig.synchronizeData(delegate, apiKey: apiKey)
    }
    
    static public func startLoggingMeasurements() {
        NAOSDKModule.NAOServicesConfig.startLoggingMeasurements()
    }
    
    static public func stopLoggingMeasurements() {
        NAOSDKModule.NAOServicesConfig.stopLoggingMeasurements()
    }
    
    static public func uploadNAOLogInfo() {
        NAOSDKModule.NAOServicesConfig.uploadNAOLogInfo()
    }
    
    static public func getLastKnowLocation() -> CLLocation {
        return NAOSDKModule.NAOServicesConfig.getLastKnowLocation()
    }
    
    static public func uploadNAOLogInfo(_ apikey: String, with callback: PSTICallback? = nil) {
        NAOSDKModule.NAOServicesConfig.uploadNAOLogInfo(apikey, callback: callback)
    }
    
    static public func enableOnSiteWakeUp() {
        NAOSDKModule.NAOServicesConfig.enableOnSiteWakeUp()
    }
    
    static public func disableOnSiteWakeUp() {
        NAOSDKModule.NAOServicesConfig.disableOnSiteWakeUp()
    }
    
    static public func getNaoContext() -> NaoContext {
        return NAOSDKModule.NAOServicesConfig.getNaoContext()
    }

    static public func getNaolog() -> String {
        return NAOSDKModule.NAOServicesConfig.getNaolog()
    }
    
    /**
     *@brief Function for setting the user tracking identifier with his consent
     *@param[in]    identifier      String word used as the used identifier
     *@param[in]    consent             YES if the user is consent otherwise NO
     *@return       YES if the identifier has been successful set otherwise NO
     */
    static public func setIdentifier(_ identifier: String, with userConsent: Bool) -> Bool {
        return NAOSDKModule.NAOServicesConfig.setIdentifier(identifier,  witUserConsent:userConsent)
    }
}
