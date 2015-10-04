//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chuiwen Ma on 9/24/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    let floatFormatter = NSNumberFormatter()
    
    init() {
        floatFormatter.maximumFractionDigits = 6
        floatFormatter.minimumIntegerDigits = 1
    }
    
    private var accumulator = 0.0
    
    private var sequence = " "
    private var currentOperand = ""
    
    var description: String {
        get {
            return sequence + currentOperand
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        currentOperand = floatFormatter.stringFromNumber(accumulator)!
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "Rand": Operation.Variable({ Double(arc4random()) / Double(UINT32_MAX) }),
        "√": Operation.UnaryOperation(sqrt),
        "sin": Operation.UnaryOperation(sin),
        "cos": Operation.UnaryOperation(cos),
        "ln": Operation.UnaryOperation({ ($0 > 0) ? log($0) : Double.NaN }),
        "x²": Operation.UnaryOperation({ pow($0, 2) }),
        "x⁻¹": Operation.UnaryOperation({ ($0 == 0) ? Double.NaN : 1 / $0 }),
        "eˣ": Operation.UnaryOperation({ pow(M_E, $0) }),
        "±": Operation.UnaryOperation({ -$0 }),
        "×": Operation.BinaryOperation(*),
        "÷": Operation.BinaryOperation(/),
        "+": Operation.BinaryOperation(+),
        "−": Operation.BinaryOperation(-),
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    private enum Operation {
        case Constant(Double)
        case Variable(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                currentOperand = symbol
            case .Variable(let function):
                accumulator = function()
                currentOperand = floatFormatter.stringFromNumber(accumulator)!
            case .UnaryOperation(let function):
                // If there is no current operand, use the accumulator value
                if currentOperand == "" {
                    currentOperand = floatFormatter.stringFromNumber(accumulator)!
                }
                accumulator = function(accumulator)
                switch symbol {
                case "x²":
                    currentOperand = "(" + currentOperand + ")²"
                case "x⁻¹":
                    currentOperand = "(" + currentOperand + ")⁻¹"
                case "eˣ":
                    currentOperand = "e^" + "(" + currentOperand + ")"
                default:
                    currentOperand = symbol + "(" + currentOperand + ")"
                }
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                sequence = sequence + currentOperand + symbol
                currentOperand = ""
            case .Equals:
                executePendingBinaryOperation()
            case .Clear:
                accumulator = 0.0
                sequence = " "
                currentOperand = ""
                pending = nil
            }
            
        }
    }
    
    private func executePendingBinaryOperation() {
        if currentOperand == "" {
            currentOperand = floatFormatter.stringFromNumber(accumulator)!
        }
        if pending != nil {
            currentOperand = sequence + currentOperand
            sequence = ""
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    var result: Double {
        get {
            return accumulator
        }
    }
}