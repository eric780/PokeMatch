//
//  Level.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

let NumColumns = 17
let NumRows = 10
let NumPokemonTiles:Int = (NumColumns-2)*(NumRows-2)

class Level{
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    //private var tilesWithSurroundingLayer = Array2D<Tile>(columns: NumColumns+2, rows: NumRows+2)
    
    func TileAtPosition(column:Int, row:Int) -> Tile?{
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle () -> Set<Tile>{
        return createInitialTiles()
    }
    
    //initialize tiles array, as well as the tiles with surrounding layer,
    //which has row 0, col 0, row n, col n empty
    func createInitialTiles() -> Set<Tile>{
        //TODO: change function to initialize tile grid, ie. make sure there's 2 or 4 of each, etc
        //keeps track of how many of each pokemon have been instantiated
        var unfilledCoordinates = [(Int, Int)]()
        
        var set = Set<Tile>()
        
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                //create layer of Blank Tiles around the array
                if (row == 0) || (row == NumRows-1) || (col == 0) || (col == NumColumns-1){
                    let blankTile = Tile(column:col, row:row, pokemon: .None)
                    tiles[col,row] = blankTile
                }
                else{
                    unfilledCoordinates.append((col, row))
                    /*var pkType = PokemonType.random()
                    
                    
                    let tile = Tile(column:col, row:row, pokemon: pkType)
                    tiles[col, row] = tile
                    //tilesWithSurroundingLayer[col+1, row+1] = tile
                    
                    set.addElement(tile)*/
                }
                
                
            }
        }
        //precondition: unfilledCoordinates.count == NumPokemonTiles * NumberOfPokemonTypes
        for (var i=0; i<NumberOfPokemonTypes; i++){
            for (var k=0; k<(NumPokemonTiles/NumberOfPokemonTypes); k++){
                let randomIndex = Int(arc4random_uniform(UInt32(unfilledCoordinates.count)))
                var (col, row):(Int, Int)
                
                if unfilledCoordinates.count == 1{
                    (col, row) = unfilledCoordinates[0]
                }
                else{
                    (col, row) = unfilledCoordinates.removeAtIndex(randomIndex)
                }
                
                let pkType = PokemonType(rawValue: i)!
                let tile = Tile(column:col, row:row, pokemon: pkType)
                tiles[col, row] = tile
                
                set.addElement(tile)
            }
            
        }
        
        return set
    }
    
    //function returns true if two tiles can be matched and removed, along with the path
    //also removes those tiles from the tile array before returning
    func tilesAreMatched(t1: Tile, t2: Tile) -> (Bool, Path?){
        println("checking tile \(t1) and tile \(t2)")
        
        if tileIsUnreachable(t1, t2:t2){
            return (false, nil)
        }
        else{
            if(matchable(t1, t2)){//don't do search if the tiles are different pokemon
                var path = doBFS(t1, t2: t2)
                println(path)
                println(path.numTurns)
                
                var ended = (path.last.column == t2.column) && (path.last.row == t2.row)
                
                if(ended){
                    //set t1 and t2 to type None
                    t1.setPokemonTypeToNone()
                    t2.setPokemonTypeToNone()
                    return (true, path)
                }
            }
        }
        return (false, nil)
        
    }
    
    //returns true if t2 is unreachable from t1
    //happens when t2 is surrounded on 4 sides by tiles, none of which are t1
    private func tileIsUnreachable(t1: Tile, t2: Tile) -> Bool{
        let neighbors = getNeighbors(t2) //arbitrarily get all neighbors of t2
        var noneTileCount = 0
        for tile in neighbors{
            if tile == t1{
                return false
            }
            if tile.pokemon == .None{
                noneTileCount++
            }
        }
        if noneTileCount > 0{ //there is a free space going to the tile
            return false
        }
        return true
    }
    
    
    //returns a shortest list of tiles that will lead from t1 to t2
    //precondition: t2 is reachable from t1
    private func doBFS(t1: Tile, t2: Tile) -> Path{
        var bfsqueue = Queue<Path>()
        
        var initialpath = Path()
        initialpath.add(t1.column, row: t1.row)
        
        bfsqueue.enQueue(initialpath)
        
        while !bfsqueue.isEmpty(){
            let path = bfsqueue.deQueue()!
            //if the path has too many turns, we don't want it anymore
            //TODO: find more of these "discard" conditions to speed up BFS
            if(path.numTurns > 2){
                continue
            }
            
            let node = path.last
            if (node.column == t2.column && node.row == t2.row) && path.numTurns < 3{
                return path
            }
            let tile = tiles[node.column, node.row]!
            for neighbor in getNeighbors(tile){
                if !path.containsCoords(neighbor.column, row: neighbor.row) &&
                    ((neighbor.pokemon == .None) || (neighbor == t2)){
                    var newpath = path
                    newpath.add(neighbor.column, row:neighbor.row)
                    println(newpath)
                    bfsqueue.enQueue(newpath)
                    
                }
            }
        }
        return initialpath //returns bogus path if t2 is unreachable within 3 turns
    }
    
    
    //returns the Manhattan distance between two tiles (H)
    private func distance(t1:Tile, t2:Tile) -> Int{
        let side1 = Float(t2.column - t1.column)
        let side2 = Float(t2.row - t1.row)

        return Int(sqrtf(pow(side1, 2) + pow(side2, 2)))
    }
    //returns the movement cost (G) for a path
    private func movementCost(path:Path) -> Int{
        return path.length + 2*path.numTurns
    }
    
    //returns a list of neighboring tiles
    private func getNeighbors(tile: Tile) -> Array<Tile>{
        let (col,row) = (tile.column, tile.row)
        var arr = Array<Tile>()
        if col > 0{
            arr.append(tiles[col-1, row]!)
        }
        if row > 0{
            arr.append(tiles[col, row-1]!)
        }
        if col < NumColumns-1{
            arr.append(tiles[col+1, row]!)
        }
        if row < NumRows-1{
            arr.append(tiles[col, row+1]!)
        }
        return arr
    }
    
    private func printTileArray(array: Array2D<Tile>){
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                let t = tiles[col,row]
                if t == nil{
                    print("NIL, ")
                }
                else{
                    print("\(t), ")
                }
            }
            println()
        }
    }
    
    
}