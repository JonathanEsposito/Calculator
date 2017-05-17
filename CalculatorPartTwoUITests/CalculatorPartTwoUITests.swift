//
//  CalculatorPartTwoUITests.swift
//  CalculatorPartTwoUITests
//
//  Created by .jsber on 01/03/17.
//  Copyright © 2017 jo.on. All rights reserved.
//

import XCTest

class CalculatorPartTwoUITests: XCTestCase {
        
    func testBasics() {
        let brain = CalculatorBrain()
        
        // a. touching 7 + would show “7 + ...” (with 7 still in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        XCTAssertEqual(brain.description, "7 + ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 7.0)
        
        // b. 7 + 9 would show “7 + ...” (9 in the display)
        //brain.setOperand(9) // entered but not pushed to model
        XCTAssertEqual(brain.description, "7 + ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 7.0)
        
        // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
        brain.setOperand(9)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 9")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 16.0)
        
        // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
        brain.performOperation("²√x")
        XCTAssertEqual(brain.description, "²√(7 + 9)")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 4.0)
        
        // e. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("²√x")
        XCTAssertEqual(brain.description, "7 + ²√9")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 3.0)
        
        // f. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + ²√9")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 10.0)
        
        // g. 7 + 9 = + 6 + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 9 + 6 + 3")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 25.0)
        
        // h. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "6 + 3")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 9.0)
        
        // i. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("=")
        //brain.setOperand(73) // entered but not pushed to model
        XCTAssertEqual(brain.description, "5 + 6")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 11.0)
        
        // j. 7 + = would show “7 + 7 =” (14 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 7")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 14.0)
        
        // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
        brain.setOperand(4)
        brain.performOperation("×")
        brain.performOperation("π")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "4 × π")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertTrue(abs(brain.result - 12.5663706143592) < 0.001)
        
        // m. 4 + 5 × 3 = could also show “(4 + 5) × 3 =” if you prefer (27 in the display)
        brain.setOperand(4)
        brain.performOperation("+")
        brain.setOperand(5)
        brain.performOperation("×")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "4 + 5 × 3")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 19)
    }
    
    
    
    /****
     * Extra testing for extended functionalities
     ****/
    
    
    
    /****
     * Binary operation Priority tests
     ****/
    func testBinaryOperationPriority() {
        let brain = CalculatorBrain()
        
        // 0.
        brain.clear()
        brain.setOperand(4)
        brain.performOperation("+")
        brain.setOperand(5)
        brain.performOperation("×")
        
        XCTAssertEqual(brain.description, "4 + 5 × ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 5)
        
        // 0b.
        brain.clear()
        brain.setOperand(4)
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("+")
        
        XCTAssertEqual(brain.description, "4 × 5 + ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 20)
        
        // 2. 5 + 3 x 8 - ...
        brain.clear()
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(8)
        brain.performOperation("−")
        
        XCTAssertEqual(brain.description, "5 + 3 × 8 - ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 29)
        
        // 6. 8 + 3 x 5 ^2 = OK
        brain.clear()
        brain.setOperand(8)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("x²")
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "8 + 3 × 5²")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 83)
        
        // 7. 8 + 3 x 5 x^y 2 = ok
        brain.clear()
        brain.setOperand(8)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("xʸ")
        brain.setOperand(2)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "8 + 3 × (5)^2")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 83)
        
        // 8. 8 + 3 x 5 ^2 x^y 2 - 3 = 1880 OK
        brain.clear()
        brain.setOperand(8)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("x²")
        brain.performOperation("xʸ")
        brain.setOperand(2)
        brain.performOperation("−")
        brain.setOperand(3)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "8 + 3 × (5²)^2 - 3")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 1880)
        
        // 9. 2 + 3 x 8 x 2 retuned (2 + 3 x 8) x 2 = 52 instead of 50
        brain.clear()
        brain.setOperand(2)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(8)
        brain.performOperation("×")
        brain.setOperand(2)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "2 + 3 × 8 × 2")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 50)
        
        // 10. returned (2 + (3 × (8)^2)^2)^2 × 2 - 3
        brain.setOperand(2)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(8)
        brain.performOperation("xʸ")
        brain.setOperand(2)
        brain.performOperation("xʸ")
        brain.setOperand(2)
        brain.performOperation("xʸ")
        brain.setOperand(2)
        brain.performOperation("×")
        brain.setOperand(2)
        brain.performOperation("−")
        brain.setOperand(3)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "2 + 3 × (((8)^2)^2)^2 × 2 - 3")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 100663295)
        //        XCTAssertTrue(abs(brain.result - 1688849860263940) < 20) // Alternative option... ( 8^(2^(2^2)) ) Not used in apple calculator..
        
        // 11.
        brain.setOperand(8)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "(8 + 3) × 5") // returns "8 + 3 x 5"
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 55)
        
        // e. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("²√x")
        brain.performOperation("×")
        brain.setOperand(5)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "7 + ²√9 × 5")
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 22)
    }
    
    
    /****
     * Parenthesis test
     ****/
    func testParenthesis() {
        let brain = CalculatorBrain()
        
        // 0. "(..."  Set open parenthesis
        brain.clear()
        brain.performOperation("(")
        
        XCTAssertEqual(brain.description, "(")
        XCTAssertTrue(brain.resultIsPending)
        
        // 1. "5 / 2 - ( 8 x ..." returned "5 / 2 - ( 8 x 8 x"
        brain.clear()
        brain.setOperand(5)
        brain.performOperation("÷")
        brain.setOperand(2)
        brain.performOperation("−")
        brain.performOperation("(")
        brain.setOperand(8)
        brain.performOperation("×")
        
        XCTAssertEqual(brain.description, "5 / 2 - (8 × ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 8)
        
        // 3. "7 x ( 5 + 3 x 2 )" Parenthesis and binary priority
        brain.clear()
        brain.setOperand(7)
        brain.performOperation("×")
        brain.performOperation("(")
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.setOperand(2)
        brain.performOperation(")")
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "7 × (5 + 3 × 2)") // returned "5 + 7 × (3 × 2)" = 47
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 77) // returned 47
        
        // 4. "8 x ( 5 + 3 ) ²√x"
        brain.clear()
        brain.setOperand(8)
        brain.performOperation("×")
        brain.performOperation("(")
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(4)
        brain.performOperation(")")
        brain.performOperation("²√x")
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "8 × ²√(5 + 4)") // returned "²√(8 × (5 + 4))"
        XCTAssertFalse(brain.resultIsPending)
        XCTAssertEqual(brain.result, 24)
        
        // 5. "2 + 3 x ( ..." returned "3 x (2 + ..."
        brain.clear()
        brain.setOperand(2)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("×")
        brain.performOperation("(")
        
        XCTAssertEqual(brain.description, "2 + 3 × (") // returned "3 x (2 +"
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 3)
        
        // If user types a parenthesis by accident or something
        brain.clear()
        brain.setOperand(2)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("(")
        brain.performOperation("−")
        brain.setOperand(1)
        brain.performOperation("+")
        
        XCTAssertEqual(brain.description, "2 + 3 - 1 + ")
        XCTAssertTrue(brain.resultIsPending)
        XCTAssertEqual(brain.result, 4)
        
        // "2 x 4 = x²" should return "(2 × 4)²"
        brain.clear()
        brain.setOperand(2)
        brain.performOperation("×")
        brain.setOperand(4)
        brain.performOperation("=")
        brain.performOperation("x²")
        
        XCTAssertEqual(brain.description, "(2 × 4)²")
        
        // "(2 x 4) = x²" should return "(2 × 4)²"
        brain.clear()
        brain.performOperation("(")
        brain.setOperand(2)
        brain.performOperation("×")
        brain.setOperand(4)
        brain.performOperation(")")
        brain.performOperation("=")
        brain.performOperation("x²")
        
        XCTAssertEqual(brain.description, "(2 × 4)²")
        
        //
        brain.clear()
        brain.setOperand(2)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        brain.performOperation("×")
        brain.setOperand(4)
        brain.performOperation("=")
        brain.performOperation("x²")
        
        XCTAssertEqual(brain.description, "((2 + 3) × 4)²")

        //
        brain.clear()
        brain.setOperand(1)
        brain.performOperation("+")
        brain.setOperand(2)
        brain.performOperation("×")
        brain.performOperation("(")
        brain.setOperand(3)
        brain.performOperation("+")
        brain.setOperand(4)
        brain.performOperation("×")
        brain.performOperation("(")
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(5)
        brain.performOperation(")")
        XCTAssertEqual(brain.description, "1 + 2 × (3 + 4 × (5 + 5)")
        XCTAssertEqual(brain.result, 10)
        
        brain.performOperation(")")
        XCTAssertEqual(brain.description, "1 + 2 × (3 + 4 × (5 + 5))")
        XCTAssertEqual(brain.result, 43)
        
        brain.performOperation("=")
        XCTAssertEqual(brain.result, 87)
        
        // "8.0 x² ( × 3 =" should return "8² × 3"
        brain.setOperand(8)
        brain.performOperation("x²")
        brain.performOperation("(")
        brain.performOperation("×")
        brain.setOperand(3)
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "8² × 3")
        XCTAssertEqual(brain.result, 192)
        
        // "5.0 × 2.0 + x²" : 5 x 2 has already been calculated...
        brain.setOperand(5)
        brain.performOperation("×")
        brain.setOperand(2)
        brain.performOperation("+")
        brain.performOperation("x²")
        brain.performOperation("=")
        
        XCTAssertEqual(brain.description, "(5 × 2)²")
        XCTAssertEqual(brain.result, 100)
    }
    
    func testIsolated() {
//        let brain = CalculatorBrain()
        
        // " x 3" returns??
        // memmory functionality
    }
}
