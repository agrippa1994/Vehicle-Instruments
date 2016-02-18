//
//  Calculator.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 12.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation
import JavaScriptCore

enum CalculationError : ErrorType {
    case Error(message: String)
}

func CalculateValueWithInput(var script: String, value: Double) throws -> Double {
    script = "(function($0) { return \(script) ;})( \(value) )"
    let context = JSContext()
    
    if let value = context.evaluateScript(script) where value.isNumber {
        return value.toDouble()
    }
    
    throw CalculationError.Error(message: context.exception.toString())
}