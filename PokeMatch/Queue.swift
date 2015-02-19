//
//  Queue.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/30/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

class QNode<T>{
    var value:T? = nil
    var next:QNode? = nil
}

public class Queue<T>{
    private var top:QNode<T>! = QNode<T>()
    
    func enQueue(var element:T){
        if(top == nil){
            top = QNode()
        }
        if(top.value == nil){
            top.value = element
        }
        else{
        
            var childToUse:QNode<T> = QNode<T>()
            var current:QNode = top
        
            while(current.next != nil){
                current = current.next!
            }
        
            //append
            childToUse.value = element
            current.next = childToUse
        }
    }
    
    func deQueue() -> T?{
        let topitem:T? = self.top?.value
        if(topitem == nil){
            return nil
        }
        
        var queueitem:T? = top.value!
        
        //set top to next if exists, otherwise queue has been emptied
        if let nextitem = top.next{
            top = nextitem
        }
        else{
            top = nil
        }
        
        return queueitem
        
    }
    
    func isEmpty() -> Bool{
        if let topitem:T = self.top?.value{
            return false
        }
        else{
            return true
        }
    }
    
    func peek() -> T?{
        return top.value!
    }
}