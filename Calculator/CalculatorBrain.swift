//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chuiwen Ma on 9/24/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    init() {
        floatFormatter.maximumFractionDigits = 6
        floatFormatter.minimumIntegerDigits = 1
    }
    
    private let floatFormatter = NSNumberFormatter()
    
    private var accumulator = 0.0
    
    private var sequence = ""
    private var currentOperand = ""
    // whenever current operand is set to "", we need an implicit operand
    private var implicitCurrentOperand = "0"
    
    var description: String {
        return sequence + currentOperand
    }
    
    var isPartialResult: Bool {
        return pending != nil
    }
    
    var error: Bool {
        // error is true if accumulator is +Inf, -Inf or NaN
        return accumulator.isInfinite || accumulator.isNaN
    }
    
    func setOperand(operand: Double) {
        internalProgram.append(operand)
        accumulator = operand
        currentOperand = floatFormatter.stringFromNumber(accumulator)!
    }
    
    var variableValues: Dictionary<String, Double> = [String:Double]() {
        didSet {
            // when the dict changes, re-evaluate the result
            self.program = internalProgram
        }
    }
    
    func setOperand(variableName: String) {
        internalProgram.append(variableName)
        accumulator = variableValues[variableName] ?? 0.0
        currentOperand = variableName // this may be not enough, because when cur = "", we convert from accumulator rather than still using variableName
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "🎲": Operation.Variable({ Double(arc4random()) / Double(UINT32_MAX) }),
        "√": Operation.UnaryOperation(sqrt),
        "%": Operation.UnaryOperation({ $0 / 100 }),
        "sin": Operation.UnaryOperation(sin),
        "cos": Operation.UnaryOperation(cos),
        "ln": Operation.UnaryOperation(log),
        "x²": Operation.UnaryOperation({ pow($0, 2) }),
        "x³": Operation.UnaryOperation({ pow($0, 3) }),
        "x⁻¹": Operation.UnaryOperation({ 1 / $0 }),
        "eˣ": Operation.UnaryOperation({ pow(M_E, $0) }),
        "±": Operation.UnaryOperation({ -$0 }),
        "×": Operation.BinaryOperation(*),
        "÷": Operation.BinaryOperation(/),
        "+": Operation.BinaryOperation(+),
        "−": Operation.BinaryOperation(-),
        "=": Operation.Equals,
        "←": Operation.Undo,
        "AC": Operation.Clear
    ]
    
    private enum Operation {
        case Constant(Double)
        case Variable(() -> Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Undo
        case Clear
    }
    
    private func clearBrain() {
        accumulator = 0.0
        sequence = ""
        currentOperand = ""
        implicitCurrentOperand = "0"
        pending = nil
        internalProgram.removeAll()
    }
    
    private func clearVariableValues() {
        variableValues.removeAll()
    }
    
    private var internalProgram = [AnyObject]()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clearBrain()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let variableOrOperation = op as? String {
                        if operations[variableOrOperation] != nil {
                            // operation
                            performOperation(variableOrOperation)
                        } else {
                            // variable
                            setOperand(variableOrOperation)
                        }
                    }
                }
            }
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                currentOperand = symbol
            case .Variable(let function):
                accumulator = function()
                currentOperand = floatFormatter.stringFromNumber(accumulator)!
            case .UnaryOperation(let function):
                // If there is no current operand, use the implicit operand
                if currentOperand == "" {
                    currentOperand = implicitCurrentOperand
                }
                accumulator = function(accumulator)
                switch symbol {
                case "x²":
                    currentOperand = "(" + currentOperand + ")²"
                case "x³":
                    currentOperand = "(" + currentOperand + ")³"
                case "x⁻¹":
                    currentOperand = "(" + currentOperand + ")⁻¹"
                case "eˣ":
                    currentOperand = "e^" + "(" + currentOperand + ")"
                case "%":
                    currentOperand = "(" + currentOperand + ")%"
                default:
                    currentOperand = symbol + "(" + currentOperand + ")"
                }
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                implicitCurrentOperand = sequence + currentOperand
                sequence = sequence + currentOperand + symbol
                currentOperand = ""
            case .Equals:
                executePendingBinaryOperation()
            case .Undo:
                // first remove the '←' operand
                internalProgram.removeLast()
                // undo the last thing
                if internalProgram.count != 0 {
                    internalProgram.removeLast()
                    self.program = internalProgram
                }
            case .Clear:
                clearBrain()
                clearVariableValues()
            }
            
        }
    }
    
    private func executePendingBinaryOperation() {
        if currentOperand == "" {
            currentOperand = implicitCurrentOperand
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
        return accumulator
    }
}