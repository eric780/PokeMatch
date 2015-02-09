//
//  Queue.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/30/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

struct Queue<T>{
    private var array = Array<T>()
    
    mutating func enqueue(element: T){
        array.append(element)
    }
    
    //returns head of array, then shifts all elements up by 1
    mutating func dequeue() -> T{
        assert(array.count > 0)
        var h = array.removeAtIndex(0)
        
        for(var i=1; i<array.count; i++){
            array[i-1] = array[i]
        }
        
        return h
    }
    
    
    func peek() -> T{
        assert(array.count > 0)
        return array[0]
    }
    
    var count:Int{
        return array.count
    }
    
    func empty() -> Bool{
        return (array.count == 0)
    }
    
    
}