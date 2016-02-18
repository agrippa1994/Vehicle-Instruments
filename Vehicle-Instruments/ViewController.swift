//
//  ViewController.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 30.12.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import UIKit
import BDCamera

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, OBDIIDelegate, SettingsTableViewControllerDelegate {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var rpmLabel: UILabel!
    @IBOutlet weak var gpsSpeedLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var mafLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    // MARK: - Fields
    var camera: BDStillImageCamera?
    var lastOBDOperation: NSTimeInterval = NSDate().timeIntervalSince1970
    let gps = GPS()
    
    let obd = OBDII(messageBuffer: [
        try! OBDIIPID.createMessageForIdentifier(OBDIIEngineLoadValue),
        try! OBDIIPID.createMessageForIdentifier(OBDIIEngineCoolantTemperature),
        try! OBDIIPID.createMessageForIdentifier(OBDIIRPM),
        try! OBDIIPID.createMessageForIdentifier(OBDIISpeed),
        try! OBDIIPID.createMessageForIdentifier(OBDIIMAF)
    ])
    
    var speed: Double = 0.0 {
        didSet {
            self.speedLabel.text = String(format: "%.0f", speed)
        }
    }
    
    var rpm: Double = 0.0 {
        didSet {
            self.rpmLabel.text = String(format: "%.0f", rpm)
        }
    }
    
    var gpsSpeed: Double = 0.0 {
        didSet {
            self.gpsSpeedLabel.text = String(format: "%.0f", gpsSpeed)
        }
    }
    var load: Double = 0.0 {
        didSet {
            self.loadLabel.text = String(format: "%.0f %%", load)
        }
    }
    
    var power: Double = 0.0 {
        didSet {
            self.powerLabel.text = String(format: "%.0f PS", power)
        }
    }
    
    var temperature: Double = 0.0 {
        didSet {
            self.tempLabel.text = String(format: "%.0f °C", temperature)
        }
    }
    
    var maf: Double = 0.0 {
        didSet {
            self.mafLabel.text = String(format: "%.1f g/s", maf)
        }
    }
    
    var duration: Double = 0.0 {
        didSet {
            self.durationLabel.text = String(format: "%.0f ms", duration)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startCamera()
        
        // Set delegates
        self.obd.delegate = self

        // Setup application callbacks
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("applicationWillTerminate"), name: UIApplicationWillTerminateNotification, object: nil)
        center.addObserver(self, selector: Selector("applicationDidEnterBackground"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: Selector("applicationWillEnterForeground"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: Selector("orientationChanged"), name: UIDeviceOrientationDidChangeNotification, object: nil)
        setStatusText("Connecting ...")
        
        // Setup observers
        self.gps.speedSignal.observeNext { [weak self] speed in
            self?.gpsSpeed = speed
        }
        
        self.gps.authorizationSignal.observeNext { [weak self] auth in
            if auth == .AuthorizedWhenInUse {
                self?.gps.start()
            } else {
                self?.gps.stop()
            }
        }
       
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
 
        // Initialize OBD if neccessary
        if !self.obd.isConnected() {
            self.connectInOneSecond()
        }
        
        self.gps.request()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ctrl = segue.destinationViewController as? UINavigationController {
            ctrl.popoverPresentationController!.delegate = self
        }
        if let ctrl = (segue.destinationViewController as? UINavigationController)?.topViewController as? SettingsTableViewController {
            ctrl.delegate = self
        }
    }
    
    func hideStatusText() {
        self.statusLabel.hidden = true
    }
    
    func updateCameraRotation() {
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft:
            self.camera?.previewLayer.connection.videoOrientation = .LandscapeLeft
        case .LandscapeRight:
            self.camera?.previewLayer.connection.videoOrientation = .LandscapeRight
        default:
            break
        }
    }
    
    // MARK: - Setter functions
    func setStatusText(text: String) {
        self.statusLabel.hidden = false
        self.statusLabel.text = "Status: " + text
    }
    
    // MARK: - Notification methods
    func applicationWillTerminate() {
        self.obd.close()
        self.stopCamera()
    }
    
    func applicationDidEnterBackground() {
        self.obd.close()
        self.stopCamera()
    }
    
    func applicationWillEnterForeground() {
        self.startCamera()
        self.obd.open()
    }
    
    func orientationChanged() {
        self.updateCameraRotation()
    }
    
    // MARK: - Timer methods
    func connectInOneSecond() {
        self.setStatusText("Connecting in 1 second")
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self.obd, selector: Selector("open"), userInfo: nil, repeats: false)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .OverFullScreen
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .OverFullScreen
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
        
        let currentOBDOperation = NSDate().timeIntervalSince1970
        duration = (currentOBDOperation - lastOBDOperation) * 1000.0
        lastOBDOperation = currentOBDOperation
        
        // Process OBD data
        [
            OBDIIEngineLoadValue: { self.load = $0 },
            OBDIIEngineCoolantTemperature: { self.temperature = $0 },
            OBDIIRPM: { self.rpm = $0 },
            OBDIISpeed: { self.speed = $0 * Settings.speedFactor },
            OBDIIMAF: {
                self.maf = $0
                
                // Source1 https://www.scantool.net/forum/index.php?topic=6439.msg23763#msg23763
                // Source2 https://thoughtdraw.wordpress.com/2011/02/20/derive-engine-power-using-obd-data/
                
                // 15.2 == Stoichiometric ratio for diesel (14.7 for gas)
                // 46.0 == Net calorific value for diesel (43.0 for gas)
                // 0.33 == Thermal loss etc.
                // 1.34 == kW to PS ratio
                let hp = $0/Settings.stoichiometricRatio * 46.0 * Settings.efficiency * 1.34
                self.power = hp > Settings.maxHP ? Settings.maxHP : hp
            }
        ][identifier]?(value)
    }
    
    // MARK: - SettingsTableViewControllerDelegate
    func settingsClose(controller: SettingsTableViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func settingsCancel(controller: SettingsTableViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Methods
    func startCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) {
            if $0 {
                dispatch_async(dispatch_get_main_queue()) {
                    if self.camera == nil {
                        self.camera = BDStillImageCamera(previewView: self.view)
                    }
                    self.camera!.startCameraCapture()
                }
            }
        }
    }
    
    func stopCamera() {
        self.camera?.stopCameraCapture()
    }
    
}

