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
    /*====================================================================================
        Maintains a list of nodes, each node containing column and row coordinates
        Maintains the length of the path, updated each time a node is added or removed
        Maintains a number of turns for the path that is recalculated every time
            a node is added or removed
    ====================================================================================*/
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
    
    /*====================================================================================
    add
        Adds a node to the end of the path
    ====================================================================================*/
    mutating func add(column:Int, row:Int){
        var node = Node(column:column, row:row)
        tileSequence += [node]
        length++
        self.numTurns = numberOfTurns()
    }
    
    /*====================================================================================
    removeLast
        Removes the last node in the path
    ====================================================================================*/
    mutating func removeLast(){
        tileSequence.removeAtIndex(tileSequence.count-1)
        length--
        self.numTurns = numberOfTurns()
    }
    
    /*====================================================================================
    potentialNumberOfTurns
        Function calculates the number of turns the path would have IF a given node
        is added.
    ====================================================================================*/
    mutating func potentialNumberOfTurns(column:Int, row:Int) -> Int{
        add(column, row:row)
        let ret = numberOfTurns()
        removeLast()
        return ret
    }
    
    /*====================================================================================
    wouldIncreaseTurns
        Returns true if added a given node would increase the number of turns
    ====================================================================================*/
    mutating func wouldIncreaseTurns(column:Int, row:Int) -> Bool{
        return numberOfTurns() < potentialNumberOfTurns(column, row:row)
    }
    
    /*====================================================================================
    containsCoords
        Returns true if the given coordinates are contained in the path.
    ====================================================================================*/
    func containsCoords(column:Int, row:Int) -> Bool{
        for node in tileSequence{
            if (node.column == column) && (node.row == row){
                return true
            }
        }
        return false
    }
    
    /*====================================================================================
    numberOfTurns
        Calculates the number of turns in this path
    ====================================================================================*/
    private func numberOfTurns() -> Int{
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