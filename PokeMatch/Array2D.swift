//
//  Array2D.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set(newValue) {
            array[row*columns + column] = newValue
        }
    }    
    
}