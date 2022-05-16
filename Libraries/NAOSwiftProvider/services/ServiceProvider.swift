//
//  ServiceProvider.swift
//  NaoSdkSwiftApiClient
//
//  Created by Pole Star on 15/01/2020.
//  Copyright © 2020 Pole Star. All rights reserved.
//

import UIKit
import NAOSDKModule

public class ServiceProvider: NSObject {
    
    var apikey: String
    var status: Bool

    required public init(apikey: String) {
        self.status = false
        self.apikey = apikey
    }
    
    lazy var getKey: () -> String = {
        return self.apikey
    }
    
    public func start() {}
    
    public func  stop() {}
    
}
