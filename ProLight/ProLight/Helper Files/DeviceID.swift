//
//  DeviceID.swift
//  ProLight
//
//  Created by Paul on 3/18/17.
//  Copyright © 2017 Studio4Designsoftware. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        
//MARK: Device Simulator
        case "x86_64": return "Simulator"
            
        
//MARK: iPod Touch
        case "iPod4,1":                                  return "iPod Touch 4th gen"
        case "iPod5,1":                                  return "iPod Touch 5th gen"
        case "iPod7,1":                                  return "iPod Touch 6st gen"
        case "iPod9,1":                                  return "iPod Touch 7th gen"
            
//MARK: iPhones
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":      return "iPhone 4"
        case "iPhone4,1":                                return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                   return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                   return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                   return "iPhone 5s"
        case "iPhone7,2":                                return "iPhone 6"
        case "iPhone7,1":                                return "iPhone 6 Plus"
        case "iPhone8,1":                                return "iPhone 6s"
        case "iPhone8,2":                                return "iPhone 6s Plus"
        case "iPhone8,4":                                return "iPhone SE (2016)"
        case "iPhone9,1", "iPhone9,3":                   return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                   return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                 return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                 return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                 return "iPhone X"
        case "iPhone11,8":                               return "iPhone Xr"
        case "iPhone11,2":                               return "iPhone Xs"
        case "iPhone11,4", "iPhone11,6":                 return "iPhone Xs Max"
        case "iPhone12,1":                               return "iPhone 11"
        case "iPhone12,3":                               return "iPhone 11 Pro"
        case "iPhone12,5":                               return "iPhone 11 Pro Max"
        case "iPhone12,8":                               return "iPhone SE 2nd Gen"
        case "iPhone13,1":                               return "iPhone 12 Mini"
        case "iPhone13,2":                               return "iPhone 12"
        case "iPhone13,3":                               return "iPhone 12 Pro"
        case "iPhone13,4":                               return "iPhone 12 Pro Max"
        case "iPhone14,2":                               return "iPhone 13 Pro"
        case "iPhone14,3":                               return "iPhone 13 Pro Max"
        case "iPhone14,4":                               return "iPhone 13 Mini"
        case "iPhone14,5":                               return "iPhone 13"
        case "iPhone14,6":                               return "iPhone SE 3rd Gen"
        case "iPhone14,7":                               return "iPhone 14"
        case "iPhone14,8":                               return "iPhone 14 Plus"
        case "iPhone15,2":                               return "iPhone 14 Pro"
        case "iPhone15,3":                               return "iPhone 14 Pro Max"
        
//MARK: iPads
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2nd gen"
        case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3rd gen"
        case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4th gen"
        case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air 1st gen"
        case "iPad5,3", "iPad5,4":                       return "iPad Air 2nd gen"
        case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2nd gen"
        case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3rd gen"
        case "iPad5,1", "iPad5,2":                       return "iPad Mini 4th gen"
        case "iPad6,3", "iPad6,4":                       return "iPad Pro 9.7''"
        case "iPad6,7", "iPad6,8":                       return "iPad Pro 12.9'' 1st gen"
        case "iPad6,11", "iPad6,12":                     return "iPad 5th gen (2017) "
        case "iPad7.3", "iPad7,4":                       return "iPad Pro 10.5''"
        case "iPad7,1", "iPad7,2":                       return "iPad Pro 12.9'' 2nd gen"
        case "iPad7,5", "iPad7,6":                       return "iPad 6st gen (2018)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro 11'' (2018)"
        case "iPad8,5", "iPad8,7", "iPad8.8":            return "iPad Pro 12.9'' 3rd gen"
        case "iPad11,3", "iPad11,4":                     return "iPad Air 3rd gen"
        case "iPad11,1", "iPad11,2":                     return "iPad Mini 5th gen"
        case "iPad7,11", "iPad7,12":                     return "iPad 7th gen (2019)"
        case "iPad8,9", "iPad8,10":                      return "iPad Pro 11'' (2020)"
        case "iPad8,11", "iPad8,12":                     return "iPad Pro 12.9'' 4th gen"
        case "iPad11,6", "iPad11,7":                     return "iPad 8th gen (2020)"
        case "iPad13,1", "iPad13,2":                     return "iPad Air 4th gen"
        case "iPad12,1", "iPad12,2":                     return "iPad 9th gen (2021)"
        case "iPad14,1", "iPad14,2":                     return "iPad Mini 6th gen"
        case "iPad13,16", "iPad13,17":                   return "iPad Air 5th gen"
            
        default:                                         return identifier
        }
    }
    
    /*
    func getWatchModel() -> String {
        
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = CChar()
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let model = String(cString: &machine, encoding: String.Encoding.utf8)
        
        switch model {
        
//MARK: Watch Simulator
        case "x86_64": return "Watch Simulator"
            
            
//MARK: Apple Watches
        case "": return ""
        case "Watch1,1":     return "Apple Watch 38mm"
        case "Watch1,2":     return "Apple Watch 42mm"
        case "Watch2,6":     return "Apple Watch Series 1 38mm"
        case "Watch2,7":     return "Apple Watch Series 1 42mm"
        case "Watch2,3":     return "Apple Watch Series 2 38mm"
        case "Watch2,4":     return "Apple Watch Series 2 42mm"
        case "Watch3,1":     return "Apple Watch Series 3 38mm Cellular"
        case "Watch3,2":     return "Apple Watch Series 3 42mm Cellular"
        case "Watch3,3":     return "Apple Watch Series 3 38mm"
        case "Watch3,4":     return "Apple Watch Series 3 42mm"
        case "Watch4,1":     return "Apple Watch Series 4 40mm"
        case "Watch4,2":     return "Apple Watch Series 4 44mm"
        case "Watch4,3":     return "Apple Watch Series 4 40mm Cellular"
        case "Watch4,4":     return "Apple Watch Series 4 44mm Cellular"
        case "Watch5,1":     return "Apple Watch Series 5 40mm"
        case "Watch5,2":     return "Apple Watch Series 5 44mm"
        case "Watch5,3":     return "Apple Watch Series 5 40mm Cellular"
        case "Watch5,4":     return "Apple Watch Series 5 44mm Cellular"
        case "Watch5,9":     return "Apple Watch SE (GPS)"
        case "Watch6,1":     return "Apple Watch Series 6 40mm"
        case "Watch6,2":     return "Apple Watch Series 6 44mm"
        case "Watch6.3":     return "Apple Watch Series 6 40mm Cellular"
        case "Watch6,4":     return "Apple Watch Series 6 44mm Cellular"
        case "Watch6,6":     return "Apple Watch Series 7 40mm"
        case "Watch6,7":     return "Apple Watch Series 7 44mm"
        case "Watch6.8":     return "Apple Watch Series 7 40mm Cellular"
        case "Watch6,9":     return "Apple Watch Series 7 44mm Cellular"
        default:             return model!
        }
    }
     */
}
