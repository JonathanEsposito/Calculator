//
//  Collection.swift
//  CalculatorPartTwo
//
//  Created by .jsber on 08/02/17.
//  Copyright © 2017 jo.on. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
