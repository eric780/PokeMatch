//
//  Menu.swift
//  PokeMatch
//
//  Created by Eric Lin on 4/3/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Menu: SKScene {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //draw menu stuff
        
    }
    
    override func touchesBegan(touches:Set<NSObject>, withEvent event:UIEvent){
        let touch = touches.first as! UITouch
        //let location = touch.locationInNode(tileLayer) //touched CGPoint
    }
}