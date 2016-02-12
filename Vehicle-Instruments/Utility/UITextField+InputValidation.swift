//
//  UITextField+InputValidation.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 03.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import UIKit

enum TextFieldValidationException : ErrorType {
    case TextNil
    case TextEmpty
    case TextIsNotType
    case RangeMismatch
}

extension UITextField {
    func validateString() throws -> String {
         if self.text == nil {
            throw TextFieldValidationException.TextNil
        }
        
        return self.text!
    }
    
    func checkEmptiness() throws -> String {
        if (try validateString()).isEmpty {
            throw TextFieldValidationException.TextEmpty
        }
        return self.text!
    }
    
    func validateInteger() throws -> Int {
        let string = try checkEmptiness()
        guard let value = Int(string) else {
            throw TextFieldValidationException.TextIsNotType
        }
        return value
    }
    
    func validateDouble() throws -> Double {
        let string = try checkEmptiness()
        guard let doubleVal = Double(string) else {
            throw TextFieldValidationException.TextIsNotType
        }
        
        return doubleVal
    }
    
    func validateIntegerInRange(min: Int, max: Int) throws -> Int {
        let value = try validateInteger()
        if value < min || value > max {
            throw TextFieldValidationException.RangeMismatch
        }
        
        return value
    }
    
    func validateDoubleInRange(min: Double, max: Double) throws -> Double {
        let value = try validateDouble()
        if value < min || value > max {
            throw TextFieldValidationException.RangeMismatch
        }
        
        return value
    }
}
