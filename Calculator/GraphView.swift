//
//  GraphView.swift
//  Calculator
//
//  Created by ❤ on 12/13/16.
//  Copyright © 2016 Keli Cheng. All rights reserved.
//

import Foundation
import UIKit

protocol GraphViewDataSource: class {
    func pointsForGraphView(sender: GraphView) -> CGPoint
}
@IBDesignable
class GraphView: UIView {
    @IBInspectable var curve = UIBezierPath()
    @IBInspectable var scale: CGFloat = 16.0 {
        didSet {
            updateRange()
            setNeedsDisplay() // Marks the receiver’s entire bounds rectangle as needing to be redrawn.
        }
    }
    var origin: CGPoint {
        get {
            return CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
//var origin = CGPoint(x: 0, y: 0){
//    didSet {
//            updateRange()
//            setNeedsDisplay()
//        }
//    }
    
    var range_min_x: CGFloat = -100.0
    var range_max_x: CGFloat = 100.0
    var increment: CGFloat = 1.0
    func updateRange() {
        range_min_x = -origin.x/scale
        range_max_x = range_min_x+(bounds.size.width/scale)
        increment = (1.0/scale)
    }
    // ISSUE: pinch not working
    // pinch gesture handler
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
        
    }
    
    // panning gesture handler
    func moveGraph(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x)!+translation.x, y: (recognizer.view?.center.y)!+translation.y)
            
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        default:
            break
        }
    }
    
    // double-tapping gesture handler
    func moveOriginTo(recognizer: UITapGestureRecognizer) {
        recognizer.numberOfTapsRequired = 2
        switch recognizer.state {
        case .changed, .ended:
            let target = recognizer.location(in: recognizer.view)
            recognizer.view?.center = target
        default:
            break
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        let drawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        drawer.drawAxesInRect(bounds: bounds, origin: origin, pointsPerUnit: scale)
        curve.stroke()
    }
}
