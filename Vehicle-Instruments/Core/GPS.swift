//
//  GPS.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 18.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CoreLocation
import enum Result.NoError

class GPS : NSObject, CLLocationManagerDelegate {
  
    private var manager = CLLocationManager()
    
    let (speedSignal, speedObserver) = Signal<Double, NoError>.pipe()
    let (authorizationSignal, authorizationObserver) = Signal<CLAuthorizationStatus, NoError>.pipe()

    override init() {
        super.init()
        
        manager.delegate = self
        manager.activityType = .AutomotiveNavigation
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func request() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            start()
        }
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        authorizationObserver.sendNext(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let speed = locations.last?.speed {
            speedObserver.sendNext(speed >= 0 ? speed * 3.6 : 0.0)
        }
    }
}