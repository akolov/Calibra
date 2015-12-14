//
//  Device.swift
//  Calibra
//
//  Created by Alexander Kolov on 12/14/15.
//  Copyright © 2015 Alexander Kolov. All rights reserved.
//

import Foundation

struct Device {

    static var platformName: String? = {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let model = IORegistryEntryCreateCFProperty(service, "model", kCFAllocatorDefault, 0).takeRetainedValue() as? NSData {
            let bytes = UnsafePointer<CChar>(model.bytes)
            modelIdentifier = String.fromCString(bytes)
        }
        IOObjectRelease(service)
        return modelIdentifier
    }()

}