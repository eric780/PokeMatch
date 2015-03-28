//
//  Gravity.swift
//  PokeMatch
//
//  Created by Eric Lin on 3/8/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

enum GravityDirection:Int, Printable{
    
    case None = 0, Down, Up, Left, Right
    
    var directionString:String{
        switch self{
        case .None:
            return "none"
        case .Down:
            return "down"
        case .Up:
            return "up"
        case .Left:
            return "left"
        case .Right:
            return "right"
        }
    }
    
    var description:String{
        return self.directionString
    }
}

