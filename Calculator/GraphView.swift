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
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var originOffset: CGPoint = CGPoint(x: 0.0, y: 0.0) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 3.0
    
    var origin: CGPoint {
        return CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y)
    }
    
    var pointsPerUnit: CGFloat {
        return 50 * scale
    }
    
    //    var originOffset: CGPoint = CGPoint(x: 0.0, y: 0.0) { didSet { setNeedsDisplay() } }
    
    var graphFunction: ((Double) -> Double) = log {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            scale *= recognizer.scale
            recognizer.scale = 1.0
        }
    }
    
    func shiftGraph(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            originOffset.x += recognizer.translationInView(self).x
            originOffset.y += recognizer.translationInView(self).y
            recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
        }
    }
    
    func reCenter(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            originOffset.x = recognizer.locationInView(self).x - bounds.midX
            originOffset.y = recognizer.locationInView(self).y - bounds.midY
            print(recognizer.locationInView(self))
        }
    }
    
    func viewXToGraphX(x: CGFloat) -> Double {
        return Double((x - origin.x) / pointsPerUnit)
    }
    
    func graphYToViewY(y: Double) -> CGFloat {
        return -CGFloat(y) * pointsPerUnit + origin.y
    }
    
    let path = UIBezierPath()
    
    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: self.contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: self.origin, pointsPerUnit: self.pointsPerUnit)
        path.removeAllPoints()
//        path.moveToPoint(CGPoint(x: bounds.minX, y: bounds.minY))
//        path.moveToPoint(CGPoint(x: bounds.minX),
        path.moveToPoint(CGPoint(x: bounds.minX, y: graphYToViewY(graphFunction(viewXToGraphX(bounds.minX)))))
        for (var i: CGFloat = bounds.minX; i <= bounds.maxX; i++) {
            path.addLineToPoint(CGPoint(x: i, y: graphYToViewY(graphFunction(viewXToGraphX(i)))))
        }
        UIColor.blueColor().setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}
