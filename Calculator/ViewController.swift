//
//  ViewController.swift
//  Calculator
//
//  Created by .jsber on 30/11/16.
//  Copyright © 2016 jo.on. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var radDegLabel: UILabel!
    
    @IBOutlet weak var memoryRecalButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    // Buttons with second possible operations
    @IBOutlet weak var epowerXButton: UIButton!
    @IBOutlet weak var twoPowerXButton: UIButton!
    @IBOutlet weak var logYButton: UIButton!
    @IBOutlet weak var logTwoButton: UIButton!
    @IBOutlet weak var sinButton: UIButton!
    @IBOutlet weak var sinhButton: UIButton!
    @IBOutlet weak var cosButton: UIButton!
    @IBOutlet weak var coshButton: UIButton!
    @IBOutlet weak var tanButton: UIButton!
    @IBOutlet weak var tanhButton: UIButton!
    
    @IBOutlet weak var showHideSecondOperationButton: UIButton!
    private var secondOperationVisible = false
    
    private var userIsInTheMiddleOfTyping = false
    private var displayValue : Double {
        get {
            return Double(displayLabel.text!)!
        }
        set {
            displayLabel.text = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue) : String(newValue)
        }
    }
    
    private var savedMemmory: Double?
    private var brain = CalculatorBrain()
    
    // MARK: - Actions
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle! == "," ? "." : sender.currentTitle!// Gets the current title from the pressed digit button
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = displayLabel.text!
            if Double(textCurrentlyInDisplay + digit) != nil {
                displayLabel.text = textCurrentlyInDisplay + digit
            }
        } else {
            displayLabel.text = digit
            clearButton.setTitle("C", for: .normal)
        }
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematiclSymbol = sender.currentTitle {
            // Debug
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            print("")
            print(formatter.string(from: currentDateTime))
            print("***New Operation***\nmathematiclSymbol: \(mathematiclSymbol)")
            // End debug
            
            brain.performOperation(mathematiclSymbol)
        }
        displayValue = brain.result
        displayDescription()
    }
    
    @IBAction private func restore() {
        if let savedMemmory = savedMemmory {
            brain.setOperand(savedMemmory)
            displayValue = brain.result
        } else {
            displayLabel.text = "0"
        }
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction private func save(_ sender: UIButton) {
        let buttonTitle = sender.currentTitle!
        let operation = String(buttonTitle.characters.dropFirst())

        print("save operation: \(operation)")
        print("savedProgram 1.: \(savedMemmory)")
        
        if operation == "+" {
            savedMemmory = (savedMemmory ?? 0) + displayValue
        } else if operation == "−" {
            savedMemmory = (savedMemmory ?? 0) - displayValue
        }
        
        print("savedProgram 2.: \(savedMemmory!)")
        
        memoryRecalButton.setThickBorder()
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func switchBetweenRadAndDeg(_ sender: UIButton) {
        if sender.currentTitle == "Rad" {
            brain.useRadians = true
            sender.setTitle("Deg", for: .normal)
            radDegLabel.text = "Rad"
        } else {
            brain.useRadians = false
            sender.setTitle("Rad", for: .normal)
            radDegLabel.text = ""
        }
    }
    
    @IBAction private func clearMemory(_ sender: UIButton) {
        savedMemmory = nil
        memoryRecalButton.setDefaultBorder()
    }
    
    @IBAction func clearOrClearAll(_ sender: UIButton) {
        displayLabel.text = "0"
        if sender.currentTitle == "C" {
            userIsInTheMiddleOfTyping = false
            sender.setTitle("AC", for: .normal)
        } else {
            brain.clear()
            descriptionLabel.text = ""
        }
    }
    
    func displayDescription() {
        descriptionLabel.text = brain.description + (brain.resultIsPending ? "..." : " =")// waitForInput
    }
    
    // Show or hide secundaty funcitons
    @IBAction func secondPossibleOperation(_ sender: UIButton) {
        secondOperationVisible = !secondOperationVisible
        if secondOperationVisible {
            epowerXButton.setTitle("yˣ", for: .normal)
            twoPowerXButton.setTitle("2ˣ", for: .normal)
            logYButton.setTitle("logᵧ", for: .normal)
            logTwoButton.setTitle("log₂", for: .normal)
            sinButton.setTitle("sin⁻¹", for: .normal)
            sinhButton.setTitle("sinh⁻¹", for: .normal)
            cosButton.setTitle("cos⁻¹", for: .normal)
            coshButton.setTitle("cosh⁻¹", for: .normal)
            tanButton.setTitle("tan⁻¹", for: .normal)
            tanhButton.setTitle("tanh⁻¹", for: .normal)
        
            showHideSecondOperationButton.setThickBorder()
        } else {
            epowerXButton.setTitle("eˣ", for: .normal)
            twoPowerXButton.setTitle("10ˣ", for: .normal)
            logYButton.setTitle("ln", for: .normal)
            logTwoButton.setTitle("log₁₀", for: .normal)
            sinButton.setTitle("sin", for: .normal)
            sinhButton.setTitle("sinh", for: .normal)
            cosButton.setTitle("cos", for: .normal)
            coshButton.setTitle("cosh", for: .normal)
            tanButton.setTitle("tan", for: .normal)
            tanhButton.setTitle("tanh", for: .normal)
            
            showHideSecondOperationButton.setDefaultBorder()
        }
    }
}

