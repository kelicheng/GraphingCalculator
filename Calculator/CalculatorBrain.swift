//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by ❤ on 11/15/16.
//  Copyright © 2016 Keli Cheng. All rights reserved.
//

import Foundation

// a global function
//func multiply(op1: Double, op2: Double) -> Double{
//    return op1*op2
//}
func factorial(operand: Double) -> Double{
    // TODO: restrict to Int only 
    if (operand <= 1){
        return 1
    } else {
        return operand*factorial(operand: operand-1.0)
    }
}

class CalculatorBrain{
    var history = [AnyObject]()
    var variableValues: Dictionary<String,Double> = [:]
    private var internalProgram = [AnyObject]() // either Double or String
    // accumulate the result
    private var accumulator = 0.0
    var descriptionAccum = " "
    var description: String {
        get {
            if pending == nil {
                return descriptionAccum
            } else {
                return pending!.descriptionFunc(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccum ? descriptionAccum : "")
            }
        }
    }
    var isPartialResult = false
    
    // reset the accumulator to operand
    func setOperand(operand: Double){
        internalProgram.append(operand as AnyObject)
        accumulator = operand
        descriptionAccum = String(format:"%g", operand) // “%g” trim trailing zeros
        history.append(operand as AnyObject)
    }
    
    func pushOperand(variableName: String){
        history.append(variableName as AnyObject)
        let op = variableValues[variableName] ?? 0.0
        
        internalProgram.append(op as AnyObject)
        accumulator = op
        descriptionAccum = variableName
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "log₁₀": Operation.UnaryOperation(log10, {"log₁₀("+$0+")"}),
        "ln": Operation.UnaryOperation(log, {"ln("+$0+")"}),
        "eˣ": Operation.UnaryOperation(exp, {"e^("+$0+")"}),
        "±": Operation.UnaryOperation({-$0}, {"-("+$0+")"}),
        "x!": Operation.UnaryOperation(factorial, {"("+$0+")!"}),
        "1/x": Operation.UnaryOperation({1/$0}, {"1/("+$0+")"}),
        "√": Operation.UnaryOperation(sqrt, {"√("+$0+")"}),
        "x²": Operation.UnaryOperation({pow($0, 2)}, {"("+$0+")^2"}),
        "x³": Operation.UnaryOperation({pow($0, 3)}, {"("+$0+")^3"}),
        "sin": Operation.UnaryOperation(sin, {"sin("+$0+")"}),
        "cos": Operation.UnaryOperation(cos, {"cos("+$0+")"}),
        "tan": Operation.UnaryOperation(tan, {"tan("+$0+")"}),
        // example of a closure; brace in front and add "in"
        // {(op1, op2) in return op1*op2}
        "×": Operation.BinaryOperation({$0*$1}, {$0+"*"+$1}),
        "÷": Operation.BinaryOperation({$0/$1}, {$0+"/"+$1}),
        "+": Operation.BinaryOperation({$0+$1}, {$0+"+"+$1}),
        "-": Operation.BinaryOperation({$0-$1}, {$0+"-"+$1}),
        "%": Operation.UnaryOperation({$0/100.0}, {"("+$0+")/100.0"}),
        "=": Operation.Equals,
        "C": Operation.Clear
        
    ]
    
    // discrete set of value; passby value
    // Type name capitalized
    // case has associated values; constant->double
    enum Operation {
        case Constant(Double)
        // associate UnaryOperation with a function that takes a double and returns a double
        case UnaryOperation((Double) -> Double, (String) -> String)
        // plus and multiple; takes two double and return a double value
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case Equals
        case Clear
    }
    func performOperation(symbol: String){
        //        switch symbol {
        //        case "∏": accumulator = M_PI
        //        case "√": accumulator = sqrt(accumulator)
        //        default: break
        //        }
        
        internalProgram.append(symbol as AnyObject)
        // look up operations dictionary for symbol
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
                descriptionAccum = symbol
                history.append(symbol as AnyObject)
            case .UnaryOperation(let associatedFunc, let descriptionFunc):
                accumulator = associatedFunc(accumulator)
                descriptionAccum = descriptionFunc(descriptionAccum)
                history.append(symbol as AnyObject)
            case .BinaryOperation(let associatedFunc, let accoDescription):
                // have to wait for euqal to apply binary operation
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: associatedFunc, firstOperand: accumulator, descriptionFunc: accoDescription, descriptionOperand: descriptionAccum)
                history.append(symbol as AnyObject)
            case .Equals:
                executePendingBinaryOperation()
                history.append(symbol as AnyObject)
            case .Clear:
                clear()
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        // if have pending operation, evaluate
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccum = pending!.descriptionFunc(pending!.descriptionOperand, descriptionAccum)
            isPartialResult = true
            pending = nil
        } else {
            isPartialResult = false
        }
        
    }
    private var pending: PendingBinaryOperationInfo?
    
    // struct likes class, but struct is a passby value; a class is a passby reference: when passing to others, is actually passing a pointer; passby value: when pass it, copies it; mutate
    // in swift, it doesn't create the copy unless touch it and mutate it
    private struct PendingBinaryOperationInfo{
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunc: (String, String) -> String
        var descriptionOperand: String
    }
    
    // documentation
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
         clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps {
                    if let operand = op as? Double{
                        setOperand(operand: operand)
                    } else if let operation = op as? String{
                        performOperation(symbol: operation)
                    }
                    
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0
        descriptionAccum = " "
        pending = nil
        variableValues = [:]
        internalProgram.removeAll()
        history.removeAll()
    }
    
    // no set function; read-only property
    var result: Double{
        get {
            return accumulator
        }
    }
}
