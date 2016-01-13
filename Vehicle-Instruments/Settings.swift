//
//  Settings.swift
//  Vehicle-Instruments
//
//  Created by Manuel Stampfl on 11.01.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation

class Settings {
    private class func read<T>(key: String, def: T) -> T {
        if let v = NSUserDefaults.standardUserDefaults().objectForKey(key) where v is T {
            return v as! T
        }
        
        return def
    }
    
    private class func write(key: String, val: AnyObject) -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(val, forKey: key)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class var ip: String {
        get { return read("ip", def: "192.168.0.10") }
        set { write("ip", val: newValue) }
    }
    
    class var port: UInt32 {
        get { return UInt32(read("port", def: NSNumber(unsignedInt: 30000)).intValue) }
        set { write("port", val: NSNumber(unsignedInt: newValue)) }
    }
    
    class var maxHP: Double {
        get { return Double(read("maxHP", def: NSNumber(double: 150.0)).doubleValue) }
        set { write("maxHP", val: NSNumber(double: newValue)) }
    }
}