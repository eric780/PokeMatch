//
//  GameScene.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/10/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import SpriteKit
import UIKit


class GameScene: SKScene {
/*====================================================================================
    GameScene handles the "View" portion of MVC. Handles screen touches, displaying tiles, etc. 
    Contains a reference to the level.
====================================================================================*/
    var level: Level!
    
    /*
        winHandler is a closure that allows the GameViewController to handle win logic.
        In the Controller, there is a line that sets this field to a function defined in Controller.
    */
    var winHandler: ((numTiles:Int)->())?
    
    let TileWidth: CGFloat = 34.0
    let TileHeight: CGFloat = 34.0
    
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
    //Dictates how long a path will appear on the screen
    let PathDrawDelay:Double = 0.8
    
    /*====================================================================================
        Tuple that holds up to two tiles that are selected by the user.
        Logic is handled in handleSelectedTile, handleDeselectedTile, twoTilesSelected, and deselectBothTiles.
    ====================================================================================*/
    var selectedTiles:(Tile?, Tile?) = (nil, nil)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tileLayer.position = layerPosition
        gameLayer.addChild(tileLayer)
    }
    
    /*====================================================================================
        Given a set of tiles, adds sprites for each one on the tileLayer.
        Also used to redraw the board.
    ====================================================================================*/
    func addSpritesForTiles(tiles: Set<Tile>){
        for tile in tiles{
            if tile.pokemon != .None{
                let sprite = SKSpriteNode(imageNamed: tile.pokemon.spriteName)
                sprite.position = pointForColumn(tile.column, row:tile.row)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                tileLayer.addChild(sprite)
                tile.sprite = sprite
            }
        }
    }
    /*====================================================================================
        Removes all sprites from the board. Used in redrawing the board.
    ====================================================================================*/
    func removeAllTileSprites(){
        for child in tileLayer.children{
            child.removeFromParent()
        }
    }
    
    /*====================================================================================
        Given a column and row in the grid, returns the equivalent CGPoint on the screen. 
        This is typically the top left corner of a tile.
    ====================================================================================*/
    func pointForColumn(column:Int, row:Int) -> CGPoint{
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    /*====================================================================================
        Given a CGPoint, returns (if possible) a column and row coordinate on the grid.
        This is the opposite of pointForColumn.
        Returns a bool indicating whether the conversion was successful, and then the column and row.
    ====================================================================================*/
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int){
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight{
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        }
        else{
            return (false, 0, 0);
        }
    }
    
    /*====================================================================================
        Given a CGPoint, returns the Sprite that the CGPoint is located within.
    ====================================================================================*/
    func spriteNodeAtPoint(point: CGPoint) -> SKSpriteNode?{
        for child in tileLayer.children{
            if child.containsPoint(point){
                return child as! SKSpriteNode
            }
        }
        return nil
    }
    
    /*====================================================================================
        Draws a Path, then removes it after a certain delay.
    ====================================================================================*/
    func drawPath(path:Path){
        var pathpoints = CGPathCreateMutable()
        for (var i=0; i<path.length; i++){
            let node = path.tileSequence[i]
            let point:CGPoint = pointForColumn(node.column, row:node.row)
            if(i == 0){
                CGPathMoveToPoint(pathpoints, nil, point.x, point.y)
            }
            else{
                CGPathAddLineToPoint(pathpoints, nil, point.x, point.y)
            }
        }

        let shapepath = SKShapeNode()
        shapepath.path = pathpoints
        shapepath.strokeColor = UIColor.whiteColor()
        shapepath.lineWidth = 1.5
        tileLayer.addChild(shapepath)
        
        delay(PathDrawDelay){
            shapepath.removeFromParent()
        }
        
    }
    
    /*====================================================================================
        Handles logic for deselecting a tile. Returns true if a tile was deselected.
    ====================================================================================*/
    func handleDeselectedTile(tile: Tile) -> Bool{
        let (selectedOne, selectedTwo) = selectedTiles
        if tile == selectedOne{
            selectedTiles = (nil, selectedTwo)
            return true
        }
        else if tile == selectedTwo{
            selectedTiles = (selectedOne, nil)
            return true
        }
        return false
    }
    
    /*====================================================================================
        Handles logic for selecting a tile. Returns true if a tile was selected.
    ====================================================================================*/
    func handleSelectedTile(tile: Tile) -> Bool{
        let (selectedOne,selectedTwo) = selectedTiles
        if selectedOne == nil && selectedTwo == nil{
            selectedTiles = (tile, nil)
            return true
        }
        else if selectedTwo == nil{
            selectedTiles = (selectedOne, tile)
            return true
        }
        else if selectedOne == nil{
            selectedTiles = (tile, selectedTwo)
            return true
        }
        else{ //two tiles already selected
            return false
        }

    }
    
    /*====================================================================================
        Returns true if there are two tiles selected.
    ====================================================================================*/
    func twoTilesSelected() -> Bool{
        let (selectedOne, selectedTwo) = selectedTiles
        return (selectedOne != nil) && (selectedTwo != nil)
    }
    
    /*====================================================================================
        Deselects both tiles. Resets selectedTiles to (nil, nil)
    ====================================================================================*/
    func deselectBothTiles(){
        let (selectedOne,selectedTwo) = selectedTiles
        
        //change red shading back to normal
        if selectedOne != nil{
            var sprite = spriteNodeAtPoint(pointForColumn(selectedOne!.column, row: selectedOne!.row))
            sprite!.colorBlendFactor = 0.5
        }
        if selectedTwo != nil{
            var sprite = spriteNodeAtPoint(pointForColumn(selectedTwo!.column, row: selectedTwo!.row))
            sprite!.colorBlendFactor = 0.5
        }
        
        selectedTiles = (nil, nil)
        
    }
    
    /*====================================================================================
        Handles all logic for user touching the screen.
    ====================================================================================*/
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent){
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer) //touched CGPoint
        let (success, column, row) = convertPoint(location) //converted col,row coordinates from touched point
        if success{//if touch location is within grid
            if let tile = level.TileAtPosition(column, row:row){
                println("touch coordinates: \(location.x), \(location.y)")
                println(tile)
                
                if let sprite = spriteNodeAtPoint(location){
                    if handleDeselectedTile(tile){
                        sprite.colorBlendFactor = 0.0
                    }
                    else if handleSelectedTile(tile){
                        sprite.color = UIColor.redColor()
                        sprite.colorBlendFactor = 0.5
                        
                        if twoTilesSelected(){
                            let (tilesMatch, path) = level.tilesAreMatched(selectedTiles.0!, t2:selectedTiles.1!)
                            if tilesMatch{
                                (selectedTiles.0!).sprite!.removeFromParent()
                                (selectedTiles.1!).sprite!.removeFromParent()
                                
                                selectedTiles = (nil, nil)
                                
                                drawPath(path!)
                                
                                delay(0.5){
                                    //cascade redraw
                                    if self.level.gravityDirection != .None{
                                        self.removeAllTileSprites()
                                        self.addSpritesForTiles(self.level.tileArrayToSet())
                                    }
                                }
                                
                                
                                if let handler = winHandler{
                                    handler(numTiles: level.remainingTiles())
                                }
                                
                            }
                            else{
                                //deselect both tiles?
                            }
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    /*Example Usage:
        delay(0.4){
            dosomething()
        }
        Will delay for 0.4 seconds, then call dosomething().
    */
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}
