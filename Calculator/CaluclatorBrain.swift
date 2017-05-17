//
//  CaluclatorBrain.swift
//  Calculator
//
//  Created by .jsber on 30/11/16.
//  Copyright © 2016 jo.on. All rights reserved.
//

import Foundation
// Mark: - Global Methods

func factorial(of factorialNumber: Double) -> Double {
    if factorialNumber == 0 {
        return 1
    }
    return factorialNumber * factorial(of: factorialNumber - 1)
}

class CalculatorBrain {
    // MARK: - Properties
    private var internalProgram = [String]() // mainly for reference
    
    private var accumulator: Double?
    private var descriptionAccumulator = ""
    
    private var beforeParenthesisProgram = [Any]() // PendingBinaryOperationInfo or beforeBinaryOperationProgram witch is [PendingBinaryOperationInfo]
    private var beforeParenthesisDescriptionAccumulator: [Any] = []
    
    private var beforeBinaryOperationProgram = [PendingBinaryOperationInfo]()
    private var beforeBinaryOperationDescriptionAccumulator: [String] = []
    
    var useRadians: Bool = false {
        didSet {
            if useRadians {
                operations.updateValue(Operation.unaryOperations(function: sin, discriptionalFunction: {"sin(rad:\($0))"}, parenthesisByDefault: true), forKey: "sin")
                operations.updateValue(Operation.unaryOperations(function: sinh, discriptionalFunction: {"sinh(rad:\($0))"}, parenthesisByDefault: true), forKey: "sinh")
                operations.updateValue(Operation.unaryOperations(function: cos, discriptionalFunction: {"cos(rad:\($0))"}, parenthesisByDefault: true), forKey: "cos")
                operations.updateValue(Operation.unaryOperations(function: cosh, discriptionalFunction: {"cosh(rad:\($0))"}, parenthesisByDefault: true), forKey: "cosh")
                operations.updateValue(Operation.unaryOperations(function: tan, discriptionalFunction: {"tan(rad:\($0))"}, parenthesisByDefault: true), forKey: "tan")
                operations.updateValue(Operation.unaryOperations(function: tanh, discriptionalFunction: {"tanh(rad:\($0))"}, parenthesisByDefault: true), forKey: "tanh")
                
                operations.updateValue(Operation.unaryOperations(function: asin, discriptionalFunction: {"sin⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "sin⁻¹")
                operations.updateValue(Operation.unaryOperations(function: asinh, discriptionalFunction: {"sinh⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "sinh⁻¹")
                operations.updateValue(Operation.unaryOperations(function: acos, discriptionalFunction: {"cos⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "cos⁻¹")
                operations.updateValue(Operation.unaryOperations(function: acosh, discriptionalFunction: {"cosh⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "cosh⁻¹")
                operations.updateValue(Operation.unaryOperations(function: atan, discriptionalFunction: {"tan⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "tan⁻¹")
                operations.updateValue(Operation.unaryOperations(function: atanh, discriptionalFunction: {"tanh⁻¹(rad:\($0))"}, parenthesisByDefault: true), forKey: "tanh⁻¹")
                
            } else {
                operations.updateValue(Operation.unaryOperations(function: {__sinpi($0 / 180)}, discriptionalFunction: {"sin(\($0))"}, parenthesisByDefault: true), forKey: "sin")
                operations.updateValue(Operation.unaryOperations(function: {sinh($0 * M_PI / 180)}, discriptionalFunction: {"sinh(\($0))"}, parenthesisByDefault: true), forKey: "sinh") //
                operations.updateValue(Operation.unaryOperations(function: {__cospi($0 / 180)}, discriptionalFunction: {"cos(\($0))"}, parenthesisByDefault: true), forKey: "cos")
                operations.updateValue(Operation.unaryOperations(function: {cosh($0 * M_PI / 180)}, discriptionalFunction: {"cosh(\($0))"}, parenthesisByDefault: true), forKey: "cosh") //
                operations.updateValue(Operation.unaryOperations(function: {__tanpi($0 / 180)}, discriptionalFunction: {"tan(\($0))"}, parenthesisByDefault: true), forKey: "tan")
                operations.updateValue(Operation.unaryOperations(function: {tanh($0 * M_PI / 180)}, discriptionalFunction: {"tanh(\($0))"}, parenthesisByDefault: true), forKey: "tanh") //
                
                operations.updateValue(Operation.unaryOperations(function: {pow(__sinpi($0 / 180), -1)}, discriptionalFunction: {"sin⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "sin⁻¹") //
                operations.updateValue(Operation.unaryOperations(function: {asinh($0 * M_PI / 180)}, discriptionalFunction: {"sinh⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "sinh⁻¹") //
                operations.updateValue(Operation.unaryOperations(function: {pow(__cospi($0 / 180), -1)}, discriptionalFunction: {"cos⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "cos⁻¹") //
                operations.updateValue(Operation.unaryOperations(function: {acosh($0 * M_PI / 180)}, discriptionalFunction: {"cosh⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "cosh⁻¹") //
                operations.updateValue(Operation.unaryOperations(function: {pow(__tanpi($0 / 180), -1)}, discriptionalFunction: {"tan⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "tan⁻¹") //
                operations.updateValue(Operation.unaryOperations(function: {atanh($0 * M_PI / 180)}, discriptionalFunction: {"tanh⁻¹(\($0))"}, parenthesisByDefault: true), forKey: "tanh⁻¹") //
            }
        }
    }
    
    /// Returns if we are expecting more input or finished calculating
    var resultIsPending: Bool {
        get {
            return pending != nil || !beforeParenthesisProgram.isEmpty || !beforeParenthesisDescriptionAccumulator.isEmpty || !beforeBinaryOperationProgram.isEmpty
        }
    }
    
    // MARK: - Set operand
    func setOperand(_ operand: Double){
        accumulator = operand
        internalProgram.append("\(operand)")
        // If operand is to big to cause a problem to display, it will be written in a scientific style (3e+7) (??)
        descriptionAccumulator = String(format:"%g", operand)
    }
    
    // MARK: - Operation
    /// Dictionary of all operation buttons with their associated functions and values
    private var operations: [String:Operation] = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        
        "Rand" : Operation.constantGenerated(by: { Double(arc4random()) / Double(UINT32_MAX) * abs(0 - 1) + min(0, 1) } ),
        
        "±" : Operation.unaryOperations(function: {-$0}, discriptionalFunction: {"-\($0)"}, parenthesisByDefault: false),
        "10ˣ" : Operation.unaryOperations(function: {pow(10, $0)},discriptionalFunction:  {"10^\($0)"}, parenthesisByDefault: false),
        "x²" : Operation.unaryOperations(function: {pow($0, 2)}, discriptionalFunction: {"\($0)²"}, parenthesisByDefault: false),
        "x³" : Operation.unaryOperations(function: {pow($0, 3)}, discriptionalFunction: {"\($0)³"}, parenthesisByDefault: false),
        "eˣ" : Operation.unaryOperations(function: {pow(M_E, $0)}, discriptionalFunction: {"e^\($0)"}, parenthesisByDefault: false),
        "2ˣ" : Operation.unaryOperations(function: {pow(2, $0)}, discriptionalFunction: {"2^\($0)"}, parenthesisByDefault: false),
        "1/x" : Operation.unaryOperations(function: {1 / $0}, discriptionalFunction: {"1/\($0)"}, parenthesisByDefault: false),
        "²√x" : Operation.unaryOperations(function: sqrt, discriptionalFunction: {"²√\($0)"}, parenthesisByDefault: false),
        "∛x" : Operation.unaryOperations(function: {pow($0, (1/3))}, discriptionalFunction: {"∛\($0)"}, parenthesisByDefault: false),
        "x!" : Operation.unaryOperations(function: { factorial(of: $0) }, discriptionalFunction: {"\($0)!"}, parenthesisByDefault: false),
        "%" : Operation.unaryOperations(function: {$0 / 100}, discriptionalFunction: {"\($0)%"}, parenthesisByDefault: false),
        "log₁₀" : Operation.unaryOperations(function: {log10($0)}, discriptionalFunction: {"log₁₀(\($0))"}, parenthesisByDefault: true),
        "log₂" : Operation.unaryOperations(function: {log2($0)}, discriptionalFunction: {"log₂(\($0))"}, parenthesisByDefault: true),
        "ln" : Operation.unaryOperations(function: {log($0) / log(M_E)}, discriptionalFunction: {"ln(\($0))"}, parenthesisByDefault: true),
        "sin" : Operation.unaryOperations(function: {__sinpi($0 / 180)}, discriptionalFunction: {"sin(\($0))"}, parenthesisByDefault: true),
        "sinh" : Operation.unaryOperations(function: {sinh($0 * M_PI / 180)}, discriptionalFunction: {"sinh(\($0))"}, parenthesisByDefault: true),
        "cos" : Operation.unaryOperations(function: {__cospi($0 / 180)}, discriptionalFunction: {"cos(\($0))"}, parenthesisByDefault: true),
        "cosh" : Operation.unaryOperations(function: {cosh($0 * M_PI / 180)}, discriptionalFunction: {"cosh(\($0))"}, parenthesisByDefault: true),
        "tan" : Operation.unaryOperations(function: {__tanpi($0 / 180)}, discriptionalFunction: {"tan(\($0))"}, parenthesisByDefault: true),
        "tanh" : Operation.unaryOperations(function: {tanh($0 * M_PI / 180)}, discriptionalFunction: {"tanh(\($0))"}, parenthesisByDefault: true),
        "sin⁻¹" : Operation.unaryOperations(function: {pow(__sinpi($0 / 180), -1)}, discriptionalFunction: {"sin⁻¹(\($0))"}, parenthesisByDefault: true),
        "sinh⁻¹" : Operation.unaryOperations(function: {asinh($0 * M_PI / 180)}, discriptionalFunction: {"sinh⁻¹(\($0))"}, parenthesisByDefault: true),
        "cos⁻¹" : Operation.unaryOperations(function: {pow(__cospi($0 / 180), -1)}, discriptionalFunction: {"cos⁻¹(\($0))"}, parenthesisByDefault: true),
        "cosh⁻¹" : Operation.unaryOperations(function: {acosh($0 * M_PI / 180)}, discriptionalFunction: {"cosh⁻¹(\($0))"}, parenthesisByDefault: true),
        "tan⁻¹" : Operation.unaryOperations(function: {pow(__tanpi($0 / 180), -1)}, discriptionalFunction: {"tan⁻¹(\($0))"}, parenthesisByDefault: true),
        "tanh⁻¹" : Operation.unaryOperations(function: {atanh($0 * M_PI / 180)}, discriptionalFunction: {"tanh⁻¹(\($0))"}, parenthesisByDefault: true),
        
        "×" : Operation.binaryOperation(function: {$0 * $1}, discriptionalFunction: {"\($0) × \($1)"}, priority: 1),
        "÷" : Operation.binaryOperation(function: {$0 / $1}, discriptionalFunction: {"\($0) / \($1)"}, priority: 1),
        "+" : Operation.binaryOperation(function: {$0 + $1}, discriptionalFunction: {"\($0) + \($1)"}, priority: 0),
        "−" : Operation.binaryOperation(function: {$0 - $1}, discriptionalFunction: {"\($0) - \($1)"}, priority: 0),
        "EE" : Operation.binaryOperation(function: {$0 * pow(10, $1)}, discriptionalFunction: {"(\($0)) x 10^\($1)"}, priority: 2),
        "xʸ" : Operation.binaryOperation(function: {pow($0, $1)}, discriptionalFunction: {"(\($0))^\($1)"}, priority: 2),
        "yˣ" : Operation.binaryOperation(function: {pow($1, $0)}, discriptionalFunction: {"(\($1))^\($0)"}, priority: 2),
        "ʸ√x" : Operation.binaryOperation(function: {pow($1, (1/$0))}, discriptionalFunction: {"(\($1))√\($0)"}, priority: 2),
        "logᵧ" : Operation.binaryOperation(function: {log($0) / log($1)}, discriptionalFunction: {"(log(\($0)) / log\($1))"}, priority: 2),
        
        "=" : Operation.equals,
        
        "(" : Operation.openParenthesis,
        ")": Operation.closeParenthesis
    ]
    
    private enum Operation {
        case constant(Double)
        /// __Associated Values:__
        ///    - **() -> Double:** _a function wich generates a Double_
        case constantGenerated(by: () -> Double)
        /// __Associated Values:__
        ///    - **(Double) -> Double:** _computational function_
        ///    - **(String) -> String:** _descriptional function_
        ///    - **Bool:** _if true, operand always wrapped in parenthesis_
        case unaryOperations(function: (Double) -> Double, discriptionalFunction: (String) -> String, parenthesisByDefault: Bool)
        /// __Associated Values:__
        ///    - **(Double, Double) -> Double:** _computational function_
        ///    - **(String, String) -> String:** _descrpitional function_
        ///    - **Int:** _priority or order in which to execute functions (heighest goes first)_
        case binaryOperation(function: (Double, Double) -> Double, discriptionalFunction: (String, String) -> String, priority: Int)
        case equals
        case openParenthesis
        case closeParenthesis
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol)
        
        // Debug
        print("***Perform Operation***")
        print("brain.internalProgram: \(internalProgram)")
        print("accumulator before Opeation: \(accumulator)")
        print("descriptionAccumulator: \(descriptionAccumulator)")
        print("pending? \(pending)")
        // End Debug
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                // Set constant value to accumulator.
                accumulator = value
                // Set the verbal representation (symbol) of this value to the description accumulator.
                descriptionAccumulator = symbol
                //-----------------------------------------------------------
                
            case .constantGenerated(let function):
                // Set the calculated value to the accumulator.
                accumulator = function()
                // Set the verbal representation (symbol) of this value to the description accumulator.
                descriptionAccumulator = symbol
                //-----------------------------------------------------------
                
                
            case .unaryOperations(let unaryFunction, let descriptionFunction, let parenthesisByDefault):

                /****
                 * Makes it posible to overwrite binary operation with a new unary operation.
                 * For example if the user wants "8 ^3" but types "8 x" , it can overwrite this "x" operation
                 * with the new "^3" operation just by typing "8 x ^3" witch results in "8 ^3" and "512"
                 * (unary operations cannot be overwritten because they immediately return a result, 
                 * so the second unary operation will always be applied to the result of the previous unary operation)
                 ****/
                
                // If we have at least 2 elements in internalProgram, get its secondLast element.
                if internalProgram.count > 2 {
                    let secondLastProgramElement = internalProgram[internalProgram.count - 2]
                    // Is the secondlast element a binary operation?
                    if let secondElementFunction = operations[secondLastProgramElement], case .binaryOperation(_, _, _) = secondElementFunction {
                        // reset pending to nil or not set
                        pending = nil
                        // remove secondlast element from internalProgram
                        internalProgram.remove(at: internalProgram.count - 2)
                        debugPrint("Binary operation is followed by another operation, so binary operation will been removed")
                    }
                }
                /**** end operation overwrite ****/
                
                
                
                /****
                 * Do calculation on what is currently in the accumulator. 
                 * If there is nothing in the accumulator use 0.
                 ****/
                self.accumulator = unaryFunction(accumulator ?? 0)
                print("unaryOperation Accumulator: \(self.accumulator)")
                /**** end of calculation ****/
                
                
                /****
                 * Set the discription on what is currently in our description accumulator.
                 *
                 ****/
                // Execute the description function using the description accumulator if the operation has parenthesis by default,
                // otherwise use the conditionly wrapped accumulator
                descriptionAccumulator = descriptionFunction(parenthesisByDefault ? (descriptionAccumulator == "" ? "0" : descriptionAccumulator) : self.descriptionAccumulatorConditionallyWrapped())
                /**** end of description****/
                //-----------------------------------------------------------
                
                
            case .binaryOperation(let function, let descriptionFunction, let currentPriority):
                
                /****
                 * Makes it posible to overwrite a pending operation with the current operation.
                 * For example if the user wants "8 + 3" but types "8 x" , it can overwrite this "x" operation
                 * with the new "+" operation just by typing "8 x + 3" witch results in "8 + 3" and "11"
                 ****/
                
                // If we have at least 2 elements in internalProgram, get its secondLast element.
                if internalProgram.count > 1 {
                    let secondLastProgramElement = internalProgram[internalProgram.count - 2]
                    // If binary operation follows binary operation, overwrite previous operation and priority with new operation and priority
                    if let secondElementFunction = operations[secondLastProgramElement], case .binaryOperation(_, _, _) = secondElementFunction {
                        // Override operation properties with properties of new operation
                        pending?.binaryFuntction = function
                        pending?.descriptionFunction = descriptionFunction
                        pending?.priority = currentPriority
                        
                        // Remove secondlast element from internal programe
                        internalProgram.remove(at: internalProgram.count - 2)
                        debugPrint("Operation is followed by operation, so last operation has been ignored")
                        
                        // Stop this function as we still need a second operand
                        break
                    }
                }
                /**** End of operation overwrite ****/
                
                
                
                
                /****
                 * If the current operation has a higher priority than the previous operation,
                 * (For example: 8 + 2 x ...) we have to put the currently pending operation "8 +" in our memory
                 * before we save our current operaton "2 x" as pending.
                 * We will now keep "8 +" in our memmory until we are in an operation with a priority lower than the priority
                 * of the then pending operation, for example: if we now would get "3 +", "+" has a lower priority than "x"
                 * so after having executed the pending operation "2 x 3 = 6", we would now execute "8 +" as "8 + 6 = 14" before saving
                 * our current operation as pending operation "14 +"
                 *
                 * Normaly we would first complete the pending operation "8 + 2 = 10" and then save our current operation
                 * as pending operation as follows "10 x". In this case, this would be absolute incorrect.
                 ****/
                if let pending = pending, pending.priority < currentPriority {
                    print("1. beforeBinaryOperationDescriptionAccumulator: \(beforeBinaryOperationDescriptionAccumulator)")
                    
                    // Add the previous operation to our temporary saved description accumulator
                    beforeBinaryOperationDescriptionAccumulator.append(pending.descriptionFunction!(pending.descriptionOperand!, ""))
                    // Add pending operation to our saved operations
                    beforeBinaryOperationProgram.append(pending)
                    
                    print("2. beforeBinaryOperationDescriptionAccumulator: \(beforeBinaryOperationDescriptionAccumulator)")
                } else {
                    /* exectue current pending operations */
                    // If there is a pending operation, execute it so the accumulator and display changes appropriatly ( 8x2+... : 16 of 8x2x... : 16  vs 8+2x... : 2   )
                    executePendingBinaryOperation()
                    
                    /* execute pending operations from memmory */
                    // If there are any saved pending operations
                    if !beforeBinaryOperationProgram.isEmpty {
                        // execute all of them in reveresed order UNTIL we find one with a lower priority than the current priority
                        for index in 0..<beforeBinaryOperationProgram.count {
                            print("index: \(index)")
                            // get the last pending operation
                            let savedPending = beforeBinaryOperationProgram.last!
                            // If the priority is lower than the current priority, then break!
                            if savedPending.priority < currentPriority {
                                break
                            }
                            // else set result to accumulator
                            accumulator = savedPending.binaryFuntction(savedPending.firstOperand, (accumulator ?? 0))
                            // and remove the last from array as we just executed it
                            beforeBinaryOperationProgram.removeLast()
                            
                            // add description
                            descriptionAccumulator = beforeBinaryOperationDescriptionAccumulator.removeLast() + descriptionAccumulator
                        }
                    }
                }
                /**** End of Priority handeling ****/
                
                // Save the current operation while waiting for the second operand
                pending = PendingBinaryOperationInfo(
                    binaryFuntction: function, firstOperand: accumulator ?? 0,
                    descriptionFunction: descriptionFunction, descriptionOperand: self.descriptionAccumulatorConditionallyWrapped(priority: currentPriority),
                    priority: currentPriority)
                //-----------------------------------------------------------
                
            case .equals:
                print("equals: \(internalProgram)")
                /****
                 * We hit the equal sign so we can savely execute all our pending operations in reversed order 
                 * First in, last out.
                 *
                 *****/
                // execute the current pending operation
                executePendingBinaryOperation()
                
                // If there are any other saved pending operations, execute them too
                if !beforeBinaryOperationProgram.isEmpty {
                    // Loop through our memory in REVERSED order and execute every saved pending operation
                    let _ = beforeBinaryOperationProgram.reversed().map { accumulator = $0.binaryFuntction($0.firstOperand, accumulator!) }
                    // Note: the description is already been shown, so we now only needed to compute it!
                }
                
                // As we have executed all our pending operations, we can remove all of them from our memory
                descriptionAccumulator = beforeBinaryOperationDescriptionAccumulator.reduce("") {$0 + $1} + descriptionAccumulator
                beforeBinaryOperationDescriptionAccumulator.removeAll()
                beforeBinaryOperationProgram.removeAll()
                
                // Extention: if there are parenthesis, move pending and binaryOperationProgram to work memmory 
                if !beforeParenthesisProgram.isEmpty {
                    // remove "=" from internal program
                    internalProgram.removeLast()
                    // try closing parenthesis
                    performOperation(")")
                }
                //-----------------------------------------------------------
                
                
            case .openParenthesis:
                print("***.openParenthesis***")
                print("accumulator in parethesis: \(accumulator)")
                
                //=======> parenthesis can only be added as first (so afther nothing or "=") or after a binary operation?
                //=======> refactor?
                
                // Get secondlast item, the item before the parenthesis (this should be a binary operation, "=" or nothing, I think... for now only checking if it is not a double)
                if internalProgram.count > 1 {
                    let secondLastProgramElement = internalProgram[internalProgram.count - 2]
                    // If a parenthesis has been entered without operation (if a double is immediatly followed by a parenthesis), ignore action
                    var isBinaryOperation = false
                    if let parenthesisOperation = operations[secondLastProgramElement], case .binaryOperation(_, _, _) = parenthesisOperation {
                        isBinaryOperation = true
                    }
                    if secondLastProgramElement == "=" || isBinaryOperation { // secondLastProgramElement == "=" || ({//Double(secondLastProgramElement) == nil {
                        // If we have saved pending operations, add them
                        if !beforeBinaryOperationProgram.isEmpty {
                            // to our program
                            beforeParenthesisProgram.append( beforeBinaryOperationProgram as Any )
                            beforeBinaryOperationProgram.removeAll()
                            
                            // to our description
                            beforeParenthesisDescriptionAccumulator.append( beforeBinaryOperationDescriptionAccumulator )
                            beforeBinaryOperationDescriptionAccumulator.removeAll()
                        }
                        
                        // If there is a currently pending operation, add it too
                        if let pending = pending, let pendingDescriptionFunction = pending.descriptionFunction, let pendingDescriptionOperand = pending.descriptionOperand {
                            // to our program
                            beforeParenthesisProgram.append( self.pending as Any)
                            
                            // to our description
                            beforeParenthesisDescriptionAccumulator.append( pendingDescriptionFunction(pendingDescriptionOperand, "(") )
                        } else {
                            // there is nothing pending so just add "(" at the front of our description
                            beforeParenthesisDescriptionAccumulator.append("(")
                        }
                        
                        // start description accumulator with a parenthesis
                        descriptionAccumulator = ""
                        pending = nil
                        // clear(all: false)
                    } else {
                        // second last is a double, so remove parenthesis from program
                        internalProgram.removeLast()
                    }
                } else {
                    // there is nothing pending so just add "(" at the front of our description
                    beforeParenthesisDescriptionAccumulator.append("(")
                }
                
                print("savedBeforeParenthesis: \(beforeParenthesisProgram)")
                //-----------------------------------------------------------
                
                
            case .closeParenthesis:
                // prevent adding of additional closing parenthesis
                if beforeParenthesisProgram.isEmpty && beforeParenthesisDescriptionAccumulator.isEmpty {
                    internalProgram.removeLast()
                    break
                }
                
                descriptionAccumulator += ")"
                // execute open operation. Operation has been closed bij this parenthesis
                executePendingBinaryOperation()
                
                // If there are any other saved pending operations, execute them too
                if !beforeBinaryOperationProgram.isEmpty {
                    // Loop through our memory in REVERSED order and execute every saved pending operation
                    let _ = beforeBinaryOperationProgram.reversed().map { accumulator = $0.binaryFuntction($0.firstOperand, accumulator!) }
                    beforeBinaryOperationProgram.removeAll()
                    
                    // Note: the description is already been shown, so we now only needed to compute it!
                    self.descriptionAccumulator = beforeBinaryOperationDescriptionAccumulator.reduce("") {$0 + $1} + self.descriptionAccumulator
                    beforeBinaryOperationDescriptionAccumulator.removeAll()
                }
                
                
                /****
                 * Now bring pending and beforeBinaryOperationProgram back to work memory
                 *
                 ****/
                
                // If opening parenthesis was first saved object, then there is no operation to perform anymore
                if !beforeParenthesisProgram.isEmpty && !beforeParenthesisDescriptionAccumulator.isEmpty {
                    
                    // last item saved in our program should be a pending operation
                    if let beforeParenthesisPending = beforeParenthesisProgram.removeLast() as? PendingBinaryOperationInfo {
                        self.pending = beforeParenthesisPending
                        
                        // As we moved our pending to our work memmory, it will be shown so we have to remove it from the description
                        beforeParenthesisDescriptionAccumulator.removeLast()
                    }
                    
                    // If we also have a pendingBinaryOperationProgram, bring this back too
                    if !beforeParenthesisProgram.isEmpty, let beforeParenthesisBinaryOperationProgram = beforeParenthesisProgram.removeLast() as? [PendingBinaryOperationInfo] {
                        self.beforeBinaryOperationProgram = beforeParenthesisBinaryOperationProgram

                        if let beforeParenthesisBinaryOperationDescriptionAccumulator = beforeParenthesisDescriptionAccumulator.removeLast() as? [String] {
                            self.beforeBinaryOperationDescriptionAccumulator = beforeParenthesisBinaryOperationDescriptionAccumulator + self.beforeBinaryOperationDescriptionAccumulator
                        }
                    }
                    self.descriptionAccumulator = "(" + self.descriptionAccumulator
                } else if !beforeParenthesisDescriptionAccumulator.isEmpty, let beforeParenthesisDescription = beforeParenthesisDescriptionAccumulator.removeLast() as? String {
                    // If beforeParenthesisProgram is empty and we only have an opening parenthesis in our beforeParenthesisDescriptionAccumulator
                    descriptionAccumulator = beforeParenthesisDescription + descriptionAccumulator
                }
                //-----------------------------------------------------------
            }
        }
        
        // Debug
        print("***End of Operation***")
        print("calculated accumulator: \(accumulator)")
        print("savedBeforeParenthesis: \(beforeParenthesisProgram)")
        print("internalProgram: \(internalProgram)")
        print("pending: \(pending)")
        print("descriptionAccumulator: \(descriptionAccumulator)")
        print("beforeBinaryOperationProgram: \(beforeBinaryOperationProgram.count)")
        print("result: \(result)")
        print("description: \(description)")
        print("*** ***\n\n")
        // End debug
    }
    
    
    
    
    private func executePendingBinaryOperation() {
        
        // Debug
        print("***executePendingBinaryOperations***")
        print("execute pending: \(pending) with accumulator: \(accumulator)")
        print("Description at execute Pending: \(descriptionAccumulator)")
        // End debug
        
        
        if let pending = self.pending {
            // calculation
            accumulator = pending.binaryFuntction(pending.firstOperand, accumulator!)
            // description
            if let descriptionOperand = pending.descriptionOperand, let descriptionFunction = pending.descriptionFunction {
                print("Description Function: \(dump(descriptionFunction))")
                print("Description Operand: \(descriptionOperand)")
                
                // update de description accumulator
                descriptionAccumulator = descriptionFunction(descriptionOperand, "\(descriptionAccumulator)")
            }
            // clear pending
            self.pending = nil
        }
    }
    
    
    
    private func descriptionAccumulatorConditionallyWrapped(priority: Int? = nil) -> String {
        /****
         * If descriptionAccumulator is not a Double, so if it is a string of operands and functions
         * and it is not already wrapped in parenthesis, then we want it between parenthesis [(2x4)^2 vs 2x4^2]
         ****/
        
        // if nothing is pending and if we have a unary operation going on or a binary operation with a priority higher than 0
        if !resultIsPending, (priority != nil ? priority! > 0 : true) {
            // description accumulator is not a Double, so if it is a string of operands and functions
            if Double(descriptionAccumulator) == nil {
                // if a unary operation is followed by a binary operation
                if internalProgram.count > 1 {
                    let secondLastProgramElement = internalProgram[internalProgram.count - 2]
                    if let secondElementFunction = operations[secondLastProgramElement], case .unaryOperations(_, _, _) = secondElementFunction {
                        if priority != nil {
                            // we don't need parenthesis
                            return "\(descriptionAccumulator == "" ? "0" : descriptionAccumulator)"
                        }
                    }
                }
                
                // if the description accumulator misses a parenthesis at the front or at the back
                if let firstCharacter = descriptionAccumulator.characters.first,
                    let lastCharacter = descriptionAccumulator.characters.last,
                    (String(firstCharacter) != "(" || String(lastCharacter) != ")") {
                    // wrap it in parenthesis
                    return "(\(descriptionAccumulator == "" ? "0" : descriptionAccumulator))"
                }
            }
        }
        return "\(descriptionAccumulator == "" ? "0" : descriptionAccumulator)"
    }
    
    
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFuntction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: ((String, String) -> String)?
        var descriptionOperand: String?
        var priority: Int
    }
    
    func clear(all: Bool = true) {
        pending = nil
        if all {
            internalProgram.removeAll()
            beforeParenthesisProgram.removeAll()
            beforeParenthesisDescriptionAccumulator = []
            accumulator = nil
            descriptionAccumulator = ""
            beforeBinaryOperationProgram = []
            beforeBinaryOperationDescriptionAccumulator = []
        }
    }
    
    var description: String {
        get {
            // If there is a pending operation, we want it to show its operation symbol
            if resultIsPending && pending != nil, pending!.descriptionFunction != nil && pending!.descriptionOperand != nil {
                print("beforeBinaryOperationDescriptionAccumulator: \(beforeBinaryOperationDescriptionAccumulator)")
                // If the description accumulator (with or without parenthesis) is different from the pending description operand, show the description accumulator else show nothing
                let conditionalDescriptionAccumulator = pending!.descriptionOperand != descriptionAccumulator && pending?.descriptionOperand != "(\(descriptionAccumulator))" ? descriptionAccumulator : ""
                //
                let beforeParenthesis = beforeParenthesisDescriptionAccumulator.reduce("") {
                    var toAdd = ""
                    if let savedPendingOperations = $1 as? [String] {
                        toAdd = savedPendingOperations.reduce("") {$0 + $1}
                    } else {
                        toAdd = $1 as! String
                    }
                    return $0 + toAdd
                }
                print("count: \(beforeParenthesisDescriptionAccumulator.count)")
                print(beforeParenthesisDescriptionAccumulator)
                return beforeParenthesis + beforeBinaryOperationDescriptionAccumulator.reduce("") {$0 + $1} + pending!.descriptionFunction!(pending!.descriptionOperand!, conditionalDescriptionAccumulator)
            } else {
                print("beforeBinaryOperationDescriptionAccumulator: \(beforeBinaryOperationDescriptionAccumulator)")
                let beforeParenthesis = beforeParenthesisDescriptionAccumulator.reduce("") {
                    var toAdd = ""
                    if let savedPendingOperations = $1 as? [String] {
                        toAdd = savedPendingOperations.reduce("") {$0 + $1}
                    } else {
                        toAdd = $1 as! String
                    }
                    return $0 + toAdd
                }
                print("count: \(beforeParenthesisDescriptionAccumulator.count)")
                print(beforeParenthesisDescriptionAccumulator)
                return beforeParenthesis + beforeBinaryOperationDescriptionAccumulator.reduce("") {$0 + $1} + descriptionAccumulator
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator ?? 0
        }
    }
}
