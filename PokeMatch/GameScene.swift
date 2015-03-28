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
    var level: Level!
    var winHandler: ((numTiles:Int)->())?
    
    let TileWidth: CGFloat = 34.0
    let TileHeight: CGFloat = 34.0
    
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
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
    func removeAllTileSprites(){
        for child in tileLayer.children{
            child.removeFromParent()
        }
    }
    
    //converts column,row on the grid into a point on the layer
    func pointForColumn(column:Int, row:Int) -> CGPoint{
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    //converts a point on the layer to column,row on the grid
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int){
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight{
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        }
        else{
            return (false, 0, 0);
        }
    }
    
    //returns the skspritenode for a given location inside it
    func spriteNodeAtPoint(point: CGPoint) -> SKSpriteNode?{
        for child in tileLayer.children{
            if child.containsPoint(point){
                return child as SKSpriteNode
            }
        }
        return nil
    }
    
    func drawPath(path:Path){
        //TODO
        var pathpoints = CGPathCreateMutable()
        for (var i=0; i<path.length; i++){
            let node = path.tileSequence[i]
            let point:CGPoint = pointForColumn(node.column, row:node.row)
            if(i==0){
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
        
        delay(0.8){
            shapepath.removeFromParent()
        }
        
    }
    
    func handleDeselectedTile(tile: Tile) -> Bool{//returns true if tile is deselected
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
    
    func handleSelectedTile(tile: Tile) -> Bool{ //returns true if tile is selected
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
    
    func twoTilesSelected() -> Bool{
        let (selectedOne, selectedTwo) = selectedTiles
        return (selectedOne != nil) && (selectedTwo != nil)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        let touch = touches.anyObject() as UITouch
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
    *delay(0.4){
    *   dosomething()
    *}
    *Will delay for 0.4 seconds
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
