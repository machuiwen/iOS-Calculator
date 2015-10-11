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
    
    private func updateDisplay() {
        if !brain.error {
            displayValue = brain.result
        } else {
            display.text = "Error"
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    private func updateDisplayAndDescription() {
        updateDisplay()
        if brain.description.isEmpty {
            inputSequence.text = " "
        } else {
            inputSequence.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
    
    @IBAction private func touchUndo(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTypingANumber = false
                displayValue = nil
            }
        } else {
            brain.performOperation(sender.currentTitle!)
            updateDisplayAndDescription()
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
            display.text = floatFormatter.stringFromNumber(newValue ?? 0)
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
        updateDisplayAndDescription()
    }
    
    @IBAction private func setVariable() {
        brain.variableValues["M"] = displayValue
        updateDisplay()
    }
    
    @IBAction private func getVariable() {
        brain.setOperand("M")
        updateDisplayAndDescription()
    }
    
    @IBAction private func removeVariable() {
        brain.variableValues.removeValueForKey("M")
        updateDisplay()
    }
    
}
