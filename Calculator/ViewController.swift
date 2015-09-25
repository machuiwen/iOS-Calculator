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
            display.text = String(newValue)
        }
    }
    
    var brain = CalculatorBrain()
    
    @IBAction func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTypingANumber = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        print(brain.description)
    }
    
}

