//
//  Path.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/29/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit

class Path: Printable{
    var tileSequence: Array<(Int, Int)>
    
    init(){
        tileSequence = Array<(Int, Int)>()
    }
    
    var description:String{
        var s: String = ""
        for (x,y) in tileSequence{
            s += "(\(x), \(y))"
        }
        return s
    }
    
    func add (column:Int, row:Int){
        tileSequence += [(column,row)]
    }
    
    var last:(Int, Int){
        return tileSequence[tileSequence.count-1]
    }
}