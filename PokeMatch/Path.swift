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
    var length:Int = 0;
    
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
        length++
    }
    
    func numberOfTurns() -> Int{
        var numTurns = 0
        var horizontal = -1 //1 for horizontal movement, 0 for vertical, -1 for no direction yet
        
        for i in 1..<length{
            let (oldx,oldy) = tileSequence[i-1]
            let (x,y) = tileSequence[i]
            if (x - oldx != 0){//horizontal movement
                if (horizontal == 0){
                    numTurns++
                }
                horizontal = 1
                
            }
            else{//vertical movement
                if horizontal == 1{
                    numTurns++
                }
                horizontal = 0
            }
        }
        
        return numTurns
    }
    
    var last:(Int, Int){
        return tileSequence[tileSequence.count-1]
    }
}