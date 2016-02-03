//
//  SettingsTableViewController.swift
//  Vehicle-Instruments
//
//  Created by Manuel Stampfl on 11.01.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import UIKit

@objc protocol SettingsTableViewControllerDelegate {
    func settingsClose(controller: SettingsTableViewController)
    func settingsCancel(controller: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var ipAdressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var maxHPTextField: UITextField!
    @IBOutlet weak var stoichiometricRatioTextField: UITextField!
    @IBOutlet weak var efficiencyTextField: UITextField!
    @IBOutlet weak var speedFactorTextField: UITextField!
    
    weak var delegate: SettingsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ipAdressTextField.text = "\(Settings.ip)"
        self.portTextField.text = "\(Settings.port)"
        self.maxHPTextField.text = "\(Settings.maxHP)"
        self.stoichiometricRatioTextField.text = "\(Settings.stoichiometricRatio)"
        self.efficiencyTextField.text = "\(Settings.efficiency)"
        self.speedFactorTextField.text = "\(Settings.speedFactor)"
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.delegate?.settingsCancel(self)
    }
    
    @IBAction func onDone(sender: AnyObject) {
        do {
            Settings.ip = try self.ipAdressTextField.checkEmptiness()
            Settings.port = UInt32(try self.portTextField.validateIntegerInRange(1, max: 65535))
            Settings.maxHP = try self.maxHPTextField.validateDoubleInRange(0.0, max: 1100.0)
            Settings.stoichiometricRatio = try self.stoichiometricRatioTextField.validateDoubleInRange(1.0, max: 20.0)
            Settings.efficiency = try self.efficiencyTextField.validateDoubleInRange(0.1, max: 1.0)
            Settings.speedFactor = try self.speedFactorTextField.validateDoubleInRange(0.1, max: 2.0)
            
            self.delegate?.settingsClose(self)
        }
        catch TextFieldValidationException.TextNil {
            self.showAlert("Error", text: "Internal erro (TextNil")
        }
        catch TextFieldValidationException.TextEmpty {
            self.showAlert("Error", text: "Input must not be empty!")
        }
        catch TextFieldValidationException.TextIsNotType {
            self.showAlert("Error", text: "Input is invalid")
        }
        catch TextFieldValidationException.RangeMismatch {
            self.showAlert("Error", text: "Some data values might not be in allowed range")
        }
        catch {
            self.showAlert("Error", text: "Invalid error")
        }
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
