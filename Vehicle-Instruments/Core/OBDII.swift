//
//  OBD-II.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 02.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation
import CoreFoundation

@objc protocol OBDIIDelegate {
    func didConnect(obd: OBDII)
    func didDisconnect(obd: OBDII)
    func cantConnect(obd: OBDII)
    func didReceivedOBDValue(obd: OBDII, identifier: String, value: Double)
    
    optional func didReceivedData(obd: OBDII, string: String)
    optional func obdReadyStateChanged(obd: OBDII, readyState: Bool)
    
}

class OBDII : NSObject, NSStreamDelegate {
    weak var delegate: OBDIIDelegate?
    
    let serverAddress = "192.168.0.10"
    let serverPort: UInt32 = 35000
    
    //let serverAddress = "localhost"
    //let serverPort: UInt32 = 3000
  
    private var inStream: NSInputStream?
    private var outStream: NSOutputStream?
    private var messageBuffer: [String]
    private var messageOffset = 0
    
    init(messageBuffer: [String]) {
        self.messageBuffer = messageBuffer
    }
    
    private var isOBDReady = false {
        didSet {
            self.delegate?.obdReadyStateChanged?(self, readyState: isOBDReady)
            
            if isOBDReady {
                self.processBuffer()
            }
        }
    }
    
    func open() {
        self.close()
        
        var cfIStream: Unmanaged<CFReadStream>?
        var cfOStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, self.serverAddress, self.serverPort, &cfIStream, &cfOStream)
        
        self.inStream = cfIStream!.takeRetainedValue()
        self.outStream = cfOStream!.takeRetainedValue()
        
        self.inStream?.delegate = self
        self.outStream?.delegate = self
        
        self.inStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inStream?.open()
        self.outStream?.open()
    }
    
    func close() {
        self.inStream?.close()
        self.outStream?.close()
    }
    
    func write(var data: String) -> Bool {
        if data.isEmpty || self.outStream ==  nil {
            return false
        }
        
        if self.outStream!.streamStatus != NSStreamStatus.Open || !self.outStream!.hasSpaceAvailable {
            return false
        }
 
        data.append(Character("\r"))
        let length = data.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        if self.outStream!.write(data, maxLength: length) != length {
            return false
        }
        
        self.isOBDReady = false
        return true
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream == self.outStream {
            return
        }
        
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            self.delegate?.didConnect(self)
            startProcessing()
            break
        case NSStreamEvent.HasBytesAvailable:
            self.processInputStreamData()
            break
        case NSStreamEvent.EndEncountered:
            self.delegate?.didDisconnect(self)
            break
        case NSStreamEvent.ErrorOccurred:
            self.delegate?.cantConnect(self)
            break
        default:
            break
        }
    }

    func processInputStreamData() {
        guard let stream = self.inStream else {
            return
        }
        
        var buffer = [UInt8](count: 1024, repeatedValue: 0)
        let length = stream.read(&buffer, maxLength: buffer.count)
        if length == -1 || length == 0 {
            self.delegate?.didDisconnect(self)
            return
        } else {
            let readedString = NSString(bytes: &buffer, length: length, encoding: NSASCIIStringEncoding)! as String
            self.delegate?.didReceivedData?(self, string: readedString)
            self.processInputData(readedString)
        }
    }
    
    func processInputData(data: String) {
        let tokens = data.split("\r")
        if tokens.last?.characters.last == ">" {
            isOBDReady = true
        }
        
        
        for token in tokens {
            if let obd = try? OBDIIPID.parseMessage(token) {
                self.delegate?.didReceivedOBDValue(self, identifier: obd.0, value: obd.1)
            }
        }
        
        NSLog("DATA: \(data.split("\r\n"))")
    }
    
    func startProcessing() {
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("initializeProcessor"), userInfo: nil, repeats: false)
    }
    
    func initializeProcessor() {
        self.write("AT Z")
    }
    
    func processBuffer() {
        if messageOffset >= messageBuffer.count {
            messageOffset = 0
        }
        
        if self.write(messageBuffer[messageOffset]) {
            messageOffset++
        }
    }
}
