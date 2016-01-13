//
//  ViewController.swift
//  Vehicle-Instruments
//
//  Created by Manuel Stampfl on 30.12.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, OBDIIDelegate, CLLocationManagerDelegate, SettingsTableViewControllerDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var rpmLabel: UILabel!
    @IBOutlet weak var gpsSpeedLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var mafLabel: UILabel!
    
    let obd = OBDII(messageBuffer: [
        try! OBDIIPID.createMessageForIdentifier(OBDIIEngineLoadValue),
        try! OBDIIPID.createMessageForIdentifier(OBDIIEngineCoolantTemperature),
        try! OBDIIPID.createMessageForIdentifier(OBDIIRPM),
        try! OBDIIPID.createMessageForIdentifier(OBDIISpeed),
        try! OBDIIPID.createMessageForIdentifier(OBDIIMAF)
    ])
    
    let gps = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize UI
        self.setSpeedValue(0.0)
        self.setRPMValue(0.0)
        self.setGPSValue(0.0)
        self.setLoadValue(0.0)
        self.setPowerValue(0.0)
        self.setTempValue(0.0)
        self.setMAFValue(0.0)
        
        // Set delegates
        self.obd.delegate = self
        self.gps.delegate = self
        
        // Initialize GPS
        self.gps.activityType = .AutomotiveNavigation
        self.gps.desiredAccuracy = kCLLocationAccuracyBest
        
        // Initialize OBD
        self.connectInOneSecond()
        
        // Setup application callbacks
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("applicationWillTerminate"), name: UIApplicationWillTerminateNotification, object: nil)
        center.addObserver(self, selector: Selector("applicationDidEnterBackground"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: Selector("applicationWillEnterForeground"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        setStatusText("Connecting ...")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.gps.requestWhenInUseAuthorization()
        } else {
            self.gps.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ctrl = (segue.destinationViewController as? UINavigationController)?.topViewController as? SettingsTableViewController {
            ctrl.delegate = self
        }
    }
    
    func hideStatusText() {
        self.statusLabel.hidden = true
    }
    
    // MARK: - Setter functions
    func setStatusText(text: String) {
        self.statusLabel.hidden = false
        self.statusLabel.text = "Status: " + text
    }
    
    func setSpeedValue(value: Double) {
        self.speedLabel.text = String(format: "%.0f", value)
    }
    
    func setRPMValue(value: Double) {
        self.rpmLabel.text = String(format: "%.0f", value)
    }
    
    func setGPSValue(value: Double) {
        self.gpsSpeedLabel.text = String(format: "%.0f", value)
    }
    
    func setLoadValue(value: Double) {
        self.loadLabel.text = String(format: "%.0f %%", value)
    }
    
    func setPowerValue(value: Double) {
        self.powerLabel.text = String(format: "%.0f PS", value)
    }
    
    func setTempValue(value: Double) {
        self.tempLabel.text = String(format: "%.0f °C", value)
    }
    
    func setMAFValue(value: Double) {
        self.mafLabel.text = String(format: "%.1f g/s", value)
    }
    
    // MARK: - Notification methods
    func applicationWillTerminate() {
        self.obd.close()
    }
    
    func applicationDidEnterBackground() {
        self.obd.close()
    }
    
    func applicationWillEnterForeground() {
        self.obd.open()
    }
    
    // MARK: - Timer methods
    func connectInOneSecond() {
        self.setStatusText("Connecting in 1 second")
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self.obd, selector: Selector("open"), userInfo: nil, repeats: false)
    }
    
    // MARK: - OBDIIDelegate
    func didConnect(obd: OBDII) {
        self.setStatusText("Connected")
    }
    
    func didDisconnect(obd: OBDII) {
        self.connectInOneSecond()
    }
    
    func cantConnect(obd: OBDII) {
        self.connectInOneSecond()
    }
    
    func didReceivedOBDValue(obd: OBDII, identifier: String, value: Double) {
        self.hideStatusText()
        
        // Process OBD data
        [
            OBDIIEngineLoadValue: self.setLoadValue,
            OBDIIEngineCoolantTemperature: self.setTempValue,
            OBDIIRPM: self.setRPMValue,
            OBDIISpeed: self.setSpeedValue,
            OBDIIMAF: {
                self.setMAFValue($0)
                
                // Source1 https://www.scantool.net/forum/index.php?topic=6439.msg23763#msg23763
                // Source2 https://thoughtdraw.wordpress.com/2011/02/20/derive-engine-power-using-obd-data/
                
                // 15.2 == Stoichiometric ratio for diesel (14.7 for gas)
                // 46.0 == Net calorific value for diesel (43.0 for gas)
                // 0.33 == Thermal loss etc.
                // 1.34 == kW to PS ratio
                self.setPowerValue($0/15.2 * 46.0 * 0.33 * 1.34)
            }
        ][identifier]?(value)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.gps.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let speed = locations.last?.speed {
            self.setGPSValue(speed >= 0 ? speed * 3.6 : 0.0)
        }
    }
    
    func settingsClose(controller: SettingsTableViewController, changesToSettings: Bool) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        if changesToSettings {
            obd.close()
            obd.open()
        }
    }
}

