//
//  ViewController.swift
//  Calculator
//
//  Created by Chuiwen Ma on 9/24/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var inputSequence: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            let textInCurrentDisplay = display.text!
            // When digit is a number or the first '.', concatenate to the display
            if textInCurrentDisplay.rangeOfString(".") == nil || digit != "." {
                display.text = textInCurrentDisplay + digit
            }
        } else {
            // If '.' is the first digit, display '0.'
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
        }
        userIsInTheMiddleOfTypingANumber = true
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            // display integer when possible
            display.text = (round(newValue) == newValue) ? String(Int(newValue)) : String(newValue)
        }
    }
    
    var brain = CalculatorBrain()
    
    @IBAction func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTypingANumber = false
        }
        if let operationSymbol = sender.currentTitle {
            brain.performOperation(operationSymbol)
        }
        displayValue = brain.result
        if brain.description != " " {
            if brain.isPartialResult {
                inputSequence.text = brain.description + "..."
            } else {
                inputSequence.text = brain.description + "="
            }
        } else {
            // default text
            inputSequence.text = brain.description
        }
    }
    
}
