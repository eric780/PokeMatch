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
    var score:Int = 10000
    var timer = NSTimer()
    
    @IBOutlet weak var numLivesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        scene = GameScene(size: skView.bounds.size)
        
        level = Level()
        scene.level = level
        
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        //set initial scorelabel
        scoreLabel.text = String(score)
        
        //scorekeeping
        timer = NSTimer.scheduledTimerWithTimeInterval(0.08, target:self, selector: Selector("decrementScore"), userInfo: nil, repeats:true)
        
        beginGame()
        
        scene.winHandler = checkGameWin
    }
    
    func beginGame(){
        let newTiles = level.createInitialTiles()
        scene.addSpritesForTiles(newTiles)
    }
    
    func getScore() -> Int{
        return scoreLabel.text!.toInt()!
    }
    
    //decrements the score by 1
    func decrementScore(){
        if(score > 0){
            score = score - 1
            scoreLabel.text = String(score)
        }
    }
    
    func checkGameWin(numTiles:Int){
        if numTiles == 0{
            timer.invalidate()
        }
        
    }
    
    @IBAction func shuffleDidPress(sender: AnyObject) {
        shuffle()
    }
    
    
    func shuffle(){
        var livesRemaining:Int = numLivesLabel.text!.toInt()!
        if livesRemaining > 0{
            let tiles = level.shuffle()
            scene.removeAllTileSprites()
            scene.addSpritesForTiles(tiles)
            
            livesRemaining -= 1
            numLivesLabel.text = String(livesRemaining)
        }


        
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
