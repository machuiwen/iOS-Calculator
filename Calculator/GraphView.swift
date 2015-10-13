//
//  GraphView.swift
//  Calculator
//
//  Created by Chuiwen Ma on 10/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var color: UIColor = UIColor.blueColor()  { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var originOffset = CGVector(dx: 0.0, dy: 0.0) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var threshold: CGFloat = 1000.0 { didSet { setNeedsDisplay() } }
    
    private var origin: CGPoint {
        return CGPoint(x: bounds.midX + originOffset.dx, y: bounds.midY + originOffset.dy)
    }
    
    private var pointsPerUnit: CGFloat {
        return 40 * scale
    }
    
    // The x-y function of the graph
    var graphFunction: ((Double) -> Double)? { didSet { setNeedsDisplay() } }
    
    // Non-private method which supports scaling via a pinch gesture
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            scale *= recognizer.scale
            recognizer.scale = 1.0
        }
    }
    
    // Non-private method which supports panning via a pan gesture
    func shiftGraph(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            originOffset.dx += recognizer.translationInView(self).x
            originOffset.dy += recognizer.translationInView(self).y
            recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
        }
    }
    
    // Non-private method which supports recentering via a double-tap gesture
    func reCenter(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            originOffset.dx = recognizer.locationInView(self).x - bounds.midX
            originOffset.dy = recognizer.locationInView(self).y - bounds.midY
        }
    }
    
    // transfer x from view coordinates to graph coordinates
    private func viewXToGraphX(x: CGFloat) -> Double {
        return Double((x - origin.x) / pointsPerUnit)
    }
    
    // transfer y from graph coordinates to view coordinates
    private func graphYToViewY(y: Double) -> CGFloat {
        return -CGFloat(y) * pointsPerUnit + origin.y
    }
    
    // compute a CGPoint given function f and x coordinate
    private func computePoint(f: (Double) -> Double, x: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: graphYToViewY(f(viewXToGraphX(x))))
    }
    
    // create a path for function f
    private func pathForFunction(f: (Double) -> Double) -> UIBezierPath {
        let path = UIBezierPath()
        // iterate over pixel
        var begin = false
        for (var i = bounds.minX; i <= bounds.maxX; i += 1 / contentScaleFactor) {
            let point = computePoint(f, x: i)
            // use threshold to remove discrete point
            if (point.y.isNormal || point.y.isZero) {
                if !begin || abs(point.y - path.currentPoint.y) > threshold {
                    path.moveToPoint(point)
                    begin = true
                } else {
                    path.addLineToPoint(point)
                }
            } else {
                begin = false
            }
        }
        path.lineWidth = lineWidth
        return path
    }
    
    private var axesDrawer = AxesDrawer(color: UIColor.blackColor(),contentScaleFactor: UIView().contentScaleFactor)
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(bounds, origin: self.origin, pointsPerUnit: self.pointsPerUnit)
        color.set()
        if graphFunction != nil {
            pathForFunction(graphFunction!).stroke()
        }
    }
}
