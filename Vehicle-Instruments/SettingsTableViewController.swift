//
//  SettingsTableViewController.swift
//  Vehicle-Instruments
//
//  Created by Manuel Stampfl on 11.01.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import UIKit

@objc protocol SettingsTableViewControllerDelegate {
    func settingsClose(controller: SettingsTableViewController, changesToSettings: Bool)
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var ipAdressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    weak var delegate: SettingsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ipAdressTextField.text = "\(Settings.ip)"
        self.portTextField.text = "\(Settings.port)"
    }

    
    @IBAction func onDone(sender: AnyObject) {
        guard let ipString = self.ipAdressTextField.text else {
            return self.showAlert("Error",
                text: "Invalid")
        }
        
        guard let portString = self.portTextField.text else {
            return self.showAlert("Error",
                text: "Invalid")
        }
        
    
        if ipString.isEmpty || portString.isEmpty {
            return self.showAlert("Error",
                text: "Invalid IP or port")
        }
        
        guard let port = UInt32(portString) else {
            return self.showAlert("Error",
                text: "Port is not an integer")
        }
        
        // Check changes
        var changes = false
        if port != Settings.port
            || ipString != Settings.ip {
            changes = true
        }
        
        // Store to settings
        Settings.ip = ipString
        Settings.port = port
        
        // Notify delegate
        self.delegate?.settingsClose(self,
            changesToSettings: changes)
    }
    
    private func showAlert(title: String, text: String) {
        let ctrl = UIAlertController(title: title,
            message: text,
            preferredStyle: .Alert)
        ctrl.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        self.presentViewController(ctrl,
            animated: true,
            completion: nil)
    }

}
