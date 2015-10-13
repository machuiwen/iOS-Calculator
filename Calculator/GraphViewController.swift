//
//  GraphViewController.swift
//  Calculator
//
//  Created by Chuiwen Ma on 10/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
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
