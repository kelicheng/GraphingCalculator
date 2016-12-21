//
//  GraphViewController.swift
//  Calculator
//
//  Created by ❤ on 12/13/16.
//  Copyright © 2016 Keli Cheng. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    var history = [AnyObject]() // load history from calculator
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.changeScale(recognizer:))))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.moveGraph(recognizer:))))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: #selector(graphView.moveOriginTo(recognizer:))))
            
            updateUI()
        }
    }
    
    // convert x coordinate from view bounds to graph coordinate
    func xToGraph(x: CGFloat) -> Double {
        return Double((x-graphView.origin.x)/graphView.scale)
    }
    
    // convert y coordinate from graph coordinate to view bounds
    func yToBound(y: Double) -> CGFloat {
        return graphView.origin.y-(CGFloat(y)*graphView.scale)
    }
    
    func calculateValue(x: Double) -> Double {
        let newBrain = CalculatorBrain()
        for h in history {
            if ((h as? String) != nil) {
                if h as! String == "M" {
                    newBrain.setOperand(operand: x)
                } else {
                    newBrain.performOperation(symbol: h as! String)
                }
            } else if ((h as? Double) != nil)  {
                let op = Double(h as! Double)
                newBrain.setOperand(operand: op)
            } else {
                break
            }
        }
        return newBrain.result
    }
    
    // TODO: adjust position of curve 
    // ISSUE: when passing path to graphView, origins of curve and axes do not fit
    func drawCurve() -> UIBezierPath {
        print(graphView.origin.x)
        print(graphView.origin.y)
        var started = false
        let path = UIBezierPath()
        for count in 0...Int(graphView.bounds.width*graphView.contentScaleFactor) {
            let xBounds = CGFloat(count)/graphView.contentScaleFactor
            
            let xGraph = xToGraph(x: xBounds)
            let yGraph = calculateValue(x: xGraph)
            
            if yGraph.isFinite {
                // calculate y and create an new point
                let yBounds = yToBound(y: yGraph) // -3.0 to adjust position of curve
                let newPoint = CGPoint(x: xBounds, y: yBounds)
                
                // add the new point the path
                if started {
                    path.addLine(to: newPoint)
                } else {
                    path.move(to: newPoint)
                    started = true
                }
                
            } else {
                started = false
            }
        }
        path.stroke()
        return path
    }
    
    func updateUI() {
        graphView.curve = drawCurve()
    }
}
