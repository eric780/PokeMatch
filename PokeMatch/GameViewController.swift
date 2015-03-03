//
//  GameViewController.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/10/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene:GameScene!
    var level:Level!

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        scene = GameScene(size: skView.bounds.size)
        
        level = Level()
        scene.level = level
        
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        beginGame()
    }
    
    func beginGame(){
        let newTiles = level.createInitialTiles()
        scene.addSpritesForTiles(newTiles)
    }
    
    @IBAction func shuffleDidPress(sender: AnyObject) {
        shuffle()
    }
    
    
    func shuffle(){
        let tiles = level.shuffle()
        scene.removeAllTileSprites()
        scene.addSpritesForTiles(tiles)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
