//
//  GraphViewController.swift
//  Calculator
//
//  Created by Chuiwen Ma on 10/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    // Preserve origin and scale between launchings of the application
    // Preserve the last graph it was showing
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewWillAppear(animated: Bool) {
        graphView.scale = (defaults.objectForKey("Scale") as? CGFloat) ?? 1.0
        graphView.originOffset.dx = (defaults.objectForKey("OriginOffsetX") as? CGFloat) ?? 0.0
        graphView.originOffset.dy = (defaults.objectForKey("OriginOffsetY") as? CGFloat) ?? 0.0
        // if we have set the LastProgram, unwrap it. if not, do nothing
        if let oldProgram = defaults.objectForKey("LastProgram") { self.program = oldProgram }
    }
    
    override func viewWillDisappear(animated: Bool) {
        defaults.setObject(graphView.scale, forKey: "Scale")
        defaults.setObject(graphView.originOffset.dx, forKey: "OriginOffsetX")
        defaults.setObject(graphView.originOffset.dy, forKey: "OriginOffsetY")
        defaults.setObject(self.program, forKey: "LastProgram")
    }
    
    @IBOutlet private weak var graphView: GraphView! {
        didSet {
            // add pinch gesture recognizer
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "changeScale:"))
            // add pan gesture recognizer
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: "shiftGraph:")
            panRecognizer.maximumNumberOfTouches = 1
            graphView.addGestureRecognizer(panRecognizer)
            // add tap gesture recognizer
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: "reCenter:")
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
            updateUI()
        }
    }
    
    // A calculator brain to run program
    private var brain = CalculatorBrain()
    
    // Function to be passed to graphView
    // assume program is not nil
    private func f(x: Double) -> Double {
        brain.variableValues["M"] = x
        brain.program = program!
        return brain.result
    }
    
    // Current program
    var program: AnyObject? { didSet { updateUI() } }
    
    private func updateUI() {
        graphView?.graphFunction = (program != nil) ? f : nil
    }
    
}
