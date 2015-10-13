//
//  GraphViewController.swift
//  Calculator
//
//  Created by Chuiwen Ma on 10/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "changeScale:"))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: "shiftGraph:")
            panRecognizer.maximumNumberOfTouches = 1
            graphView.addGestureRecognizer(panRecognizer)
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: "reCenter:")
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
            updateUI()
        }
    }
    
    var brain = CalculatorBrain()
    
    func myFunc(x: Double) -> Double {
        brain.variableValues["M"] = x
        if program != nil {
            brain.program = program!
        }
        return brain.result
    }
    
    var program: AnyObject? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        graphView?.graphFunction = myFunc
    }
    
}
