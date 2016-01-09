//
//  OBDIIPIDTable.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 13.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation

let OBDIIEngineLoadValue = "Engine Load Value"
let OBDIIEngineCoolantTemperature = "Engine Coolant Temperature"
let OBDIIThrottleValue = "Trottle Value"
let OBDIIRPM = "RPM"
let OBDIISpeed = "Speed"
let OBDIIMAF = "MAF"

enum OBDIIPIDException: ErrorType {
    case InvalidData
    case InvalidResponseLength
    case InvalidHeader
    case UnknownIdentifier
    case PIDNotKnown
}

struct OBDIIPIDEntry {
    let mode: UInt8
    let pid: UInt8
    let responseLength: Int
    let identifier: String
    let processOBDValue: [UInt8] -> Double
    
    func createMessage() -> String {
        return String(format: "%02X %02X 1", arguments: [mode, pid])
    }
    
    func parseMessage(data: String) throws -> Double {
        let tokens = data.characters.split(" ").map(String.init)
        var data = [UInt8]()
        
        for token in tokens {
            guard let byte = UInt8(token, radix: 16) else {
                throw OBDIIPIDException.InvalidData
            }
            
            data += [byte]
        }
        
        if data.count != (self.responseLength + 2) {
            throw OBDIIPIDException.InvalidResponseLength
        }
        
        if data[0] < 0x40 || data[0] - 0x40 != self.mode {
            throw OBDIIPIDException.InvalidHeader
        }
        
        if data[1] != self.pid {
            throw OBDIIPIDException.InvalidHeader
        }
        
        let processData = data[2..<data.count]
        return self.processOBDValue(Array(processData))
    }
}

class OBDIIPID {
    static let pidTable = [
        OBDIIPIDEntry(mode: 0x01, pid: 0x04, responseLength: 1, identifier: OBDIIEngineLoadValue) { data in
            return (Double(data[0]) * 100.0) / 255.0
        },
        
        OBDIIPIDEntry(mode: 0x01, pid: 0x05, responseLength: 1, identifier: OBDIIEngineCoolantTemperature) { data in
            return Double(data[0]) - 40.0
        },
        
        OBDIIPIDEntry(mode: 0x01, pid: 0x11, responseLength: 2, identifier: OBDIIThrottleValue) { data in
            return ((Double(data[0]) * 256.0) + Double(data[1])) / 4.0
        },
        
        OBDIIPIDEntry(mode: 0x01, pid: 0x0C, responseLength: 2, identifier: OBDIIRPM) { data in
            return ((Double(data[0]) * 256.0) + Double(data[1])) / 4.0
        },
        
        OBDIIPIDEntry(mode: 0x01, pid: 0x0D, responseLength: 1, identifier: OBDIISpeed) { data in
            return Double(data[0])
        },
        
        OBDIIPIDEntry(mode: 0x01, pid: 0x10, responseLength: 2, identifier: OBDIIMAF) { data in
            return ((Double(data[0]) * 256.0) + Double(data[1])) / 100.0
        }
    ]
    
    class func createMessageForIdentifier(identifier: String) throws -> String {
        for entry in self.pidTable {
            if entry.identifier == identifier {
                return entry.createMessage()
            }
        }
        
        throw OBDIIPIDException.UnknownIdentifier
    }
    
    class func parseMessage(string: String) throws -> (String, Double) {
        for entry in self.pidTable {
            if let value = try? entry.parseMessage(string) {
                return (entry.identifier, value)
            }
        }
        
        throw OBDIIPIDException.PIDNotKnown
    }
}
