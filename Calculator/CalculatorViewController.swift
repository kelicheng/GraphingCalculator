//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by ❤ on 11/13/16.
//  Copyright © 2016 Keli Cheng. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    // class name viewController
    // inherentence from UIViewController
    
    //    @IBOutlet weak var display: UILabel?
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    // = nil automatically initialized
    
    
    // variable needs to be initialized
    private var userIsTyping: Bool = false
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            let textCurrentInDisplay = display.text!
            if (digit == "."){
                if (textCurrentInDisplay.range(of: ".") == nil){
                    display.text = textCurrentInDisplay + digit
                }
            } else {
                display.text = textCurrentInDisplay + digit
            }
            
        } else {
            display.text = digit
        }
        userIsTyping = true
    }
    
    
    // a computed property
    // get and set value
    private var displayValue : Double {
        get {
            // optional: the text may not be convertable
            return Double(display.text!)!
        }
        set {
            // newValue is the value somebody set
            display.text = String(newValue)
        }
    }
    
    
    // use the CalculatorBrain model; needs to be initialized
    private var brain = CalculatorBrain()
    
    
    @IBAction private func performOperation(_ sender: UIButton) {
        // if user is tying, set the number typed to operand
        if userIsTyping {
            brain.setOperand(operand: displayValue)
            userIsTyping = false
        }
        // do the calculation
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathSymbol)
            if (brain.isPartialResult) {
                descriptionDisplay.text = brain.descriptionAccum + "="
            } else {
                descriptionDisplay.text = brain.descriptionAccum + "..."
            }
        }
        // return calculated result
        displayValue = brain.result
        
    }
    
    @IBAction func setM() {
        brain.variableValues["M"] = displayValue
        userIsTyping = false
    }
    
    @IBAction func displayM() {
        brain.pushOperand(variableName: "M")
        displayValue = brain.result
    }
    
    @IBAction func undo() {
        if userIsTyping {
            var temp = display.text!
            temp.remove(at: temp.index(before: temp.endIndex))
            display.text = temp
        } else {
            //  undo the last thing that was done in the CalculatorBrain.
            // Do not undo the storing of variable values (but DO undo the setting of a variable as an operand).
            displayM()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navcon = destination as? UINavigationController {
            destination = navcon.visibleViewController ?? destination
        }
        if let graphVC = destination as? GraphViewController {
            graphVC.navigationItem.title = brain.description
            graphVC.history = brain.history
        }
    }
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//            return !brain.isPartialResult
//    }
}

