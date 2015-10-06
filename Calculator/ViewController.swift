//
//  ViewController.swift
//  Calculator
//
//  Created by Chuiwen Ma on 9/24/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let floatFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // additional setup after loading the view
        floatFormatter.maximumFractionDigits = 6
        floatFormatter.minimumIntegerDigits = 1
    }
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet private weak var inputSequence: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    
    @IBAction private func touchBackspace() {
        if userIsInTheMiddleOfTypingANumber {
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTypingANumber = false
                displayValue = 0
            }
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
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
    
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if let value = newValue {
                display.text = floatFormatter.stringFromNumber(value)
            } else {
                // clear the display out
                display.text = " "
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if let operand = displayValue {
                brain.setOperand(operand)
                userIsInTheMiddleOfTypingANumber = false
            } else {
                return
            }
        }
        if let operationSymbol = sender.currentTitle {
            brain.performOperation(operationSymbol)
        }
        displayValue = brain.result
        if brain.description.isEmpty {
            inputSequence.text = " "
        } else {
            inputSequence.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
    
    @IBAction private func setVariable() {
        brain.variableValues["M"] = displayValue
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.result
    }
    
    @IBAction private func getVariable() {
        brain.setOperand("M")
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.result
        if brain.description.isEmpty {
            inputSequence.text = " "
        } else {
            inputSequence.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
    
}
