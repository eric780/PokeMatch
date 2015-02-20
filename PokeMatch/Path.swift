//
//  Path.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/29/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit

class Node{
    var column:Int;
    var row:Int;
    
    init(column:Int, row:Int){
        self.column = column;
        self.row = row;
    }
    
}

struct Path: Printable{
    //maintains a list of nodes, each node containing column and row coordinates.
    //maintains the length of the path, updated every time a node is added or removed
    //maintains number of turns that is recalculated every time a node is added or removed
    
    var tileSequence: Array<Node>
    var length:Int = 0;
    var numTurns:Int = 0;
    
    init(){
        tileSequence = Array<Node>()
    }
    
    var description:String{
        var s: String = ""
        for n in tileSequence{
            s += "(\(n.column), \(n.row))"
        }
        return s
    }
    
    //adds a node to the end of the path
    mutating func add(column:Int, row:Int){
        var node = Node(column:column, row:row)
        tileSequence += [node]
        length++
        self.numTurns = numberOfTurns()
    }
    
    //removes the last node in the path
    mutating func removeLast(){
        tileSequence.removeAtIndex(tileSequence.count-1)
        length--
        self.numTurns = numberOfTurns()
    }
    
    //heuristic-based function that calculates the number of turns IF a node is added
    mutating func potentialNumberOfTurns(column:Int, row:Int) -> Int{
        add(column, row:row)
        let ret = numberOfTurns()
        removeLast()
        return ret
    }
    
    mutating func wouldIncreaseTurns(column:Int, row:Int) -> Bool{
        return numberOfTurns() < potentialNumberOfTurns(column, row:row)
    }
    
    //returns true if the coordinates are in the path, false otherwise
    func containsCoords(column:Int, row:Int) -> Bool{
        for node in tileSequence{
            if (node.column == column) && (node.row == row){
                return true
            }
        }
        return false
    }
    
    //returns the number of turns in the path
    func numberOfTurns() -> Int{
        var numTurns = 0
        var horizontal = -1 //1 for horizontal movement, 0 for vertical, -1 for no direction yet
        
        for i in 1..<length{
            let (oldx,oldy) = (tileSequence[i-1].column, tileSequence[i-1].row)
            let (x,y) = (tileSequence[i].column, tileSequence[i].row)
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
    
    var last:Node{
        return tileSequence[tileSequence.count-1]
    }
}