//
//  Settings.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 11.01.16.
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
    
    class var stoichiometricRatio: Double {
        get { return Double(read("stoichiometricRatio", def: NSNumber(double: 15.2)).doubleValue) }
        set { write("stoichiometricRatio", val: NSNumber(double: newValue)) }
    }
    
    class var efficiency: Double {
        get { return Double(read("efficiency", def: NSNumber(double: 0.33)).doubleValue) }
        set { write("efficiency", val: NSNumber(double: newValue)) }
    }
    
    class var speedFactor: Double {
        get { return Double(read("speedFactor", def: NSNumber(double: 1.0)).doubleValue) }
        set { write("speedFactor", val: NSNumber(double: newValue)) }
    }
}