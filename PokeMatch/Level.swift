//
//  Level.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

let NumColumns = 17
let NumRows = 9

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
        var set = Set<Tile>()
        
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                //create layer of Blank Tiles around the array
                if (row == 0) || (row == NumRows-1) || (col == 0) || (col == NumColumns-1){
                    let blankTile = Tile(column:col, row:row, pokemon: .None)
                    tiles[col,row] = blankTile
                }
                else{
                    var pkType = PokemonType.random()
                    
                    let tile = Tile(column:col, row:row, pokemon: pkType)
                    tiles[col, row] = tile
                    //tilesWithSurroundingLayer[col+1, row+1] = tile
                    
                    set.addElement(tile)
                }
                
                
            }
        }
        return set
    }
    
    //function returns true if two tiles can be matched and removed.
    //also removes those tiles from the tile array before returning
    func tilesAreMatched(t1: Tile, t2: Tile) -> Bool{
        println("checking tile \(t1) and tile \(t2)")
        
        if tileIsUnreachable(t1, t2:t2){
            return false
        }
        else{
            var path = doBFS(t1, t2: t2)
            println(path)
        
            var matched = matchable(t1, t2) && (path.last.0 == t2.column) && (path.last.1 == t2.row)
            
            if(matched){
                //set t1 and t2 to type None
                t1.setPokemonTypeToNone()
                t2.setPokemonTypeToNone()
                return true
            }
        }
        return false
        
    }
    
    //returns true if t2 is unreachable from t1
    //happens when t2 is surrounded on 4 sides by tiles, none of which are t1
    private func tileIsUnreachable(t1: Tile, t2: Tile) -> Bool{
        let neighbors = getNeighbors(t2, goal:t1) //arbitrarily get all neighbors of t2
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
    private func doBFS(t1: Tile, t2: Tile) -> Path{
        var visitedTiles = Set<Tile>()
        visitedTiles.addElement(t1)
        var path = Path()
        path.add(t1.column, row: t1.row)
        var currentTile = t1
        //while current tile not t2
            //generate neighbors for current tile in an order, depending which direction t2 is from currentTile
            //iterate through the neighbors and check which is not an obstacle
                //set currentTile to that
                //add that to path
        while (currentTile != t2){
            let neighbors = getNeighbors(currentTile, goal: t2)
            println("neighbors for \(currentTile) are \(neighbors)")
            var chosenTile:Tile = neighbors[0]
            for tile in neighbors{
                //TODO: iterate through neighbors and take the path that gives the lowest distance
                if ((tile.pokemon == .None) || (tile == t2))
                    && (distance(tile, t2:t2) < distance(chosenTile, t2:t2)) && (!visitedTiles.containsElement(tile)){
                        chosenTile = tile
                        
                }
            }
            currentTile = chosenTile
            path.add(chosenTile.column, row:chosenTile.row)
            visitedTiles.addElement(currentTile)
        }
        
        return path
    }
    
    //returns a heuristical distance between two tiles
    private func distance(t1:Tile, t2:Tile) -> Float{
        let side1 = Float((t2.column - t1.column))
        let side2 = Float((t2.row - t1.row))

        return sqrt(pow(side1, 2) + pow(side2, 2))
    }
    
    //returns a list of neighboring tiles in direction-based order
    //for a given coordinate
    private func getNeighbors(tile: Tile, goal: Tile) -> Array<Tile>{
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
        /*let (col,row) = (tile.column, tile.row)
        println("getting neighbors for \(col),\(row)")
        
        let (goalcol, goalrow) = (goal.column, goal.row)
        println("goal is \(goalcol), \(goalrow)")
        
        let diff_x = goalcol - col
        let diff_y = goalrow - row
        var arr = Array<Tile>()
        
        if abs(diff_x) > abs(diff_y){
            if diff_x >= 0{
                if col < NumColumns-1{
                    arr.append(tiles[col+1,row]!)
                }
                if diff_y >= 0{
                    if(row < NumRows-1){
                        arr.append(tiles[col, row+1]!)
                    }
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if row > 0{
                        arr.append(tiles[col, row-1]!)
                    }
                }
                else{
                    if(row > 0){
                        arr.append(tiles[col, row-1]!)
                    }
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if row < NumRows-1{
                        arr.append(tiles[col, row+1]!)
                    }
                }
            }
            else{//diff_x < 0
                if col > 0{
                    arr.append(tiles[col-1,row]!)
                }
                if diff_y > 0{
                    if row < NumRows-1{
                        arr.append(tiles[col, row+1]!)
                    }
                    if col < NumColumns-1{
                        arr.append(tiles[col+1, row]!)
                    }
                    if row > 0{
                        arr.append(tiles[col, row-1]!)
                    }
                }
                else{
                    if row > 0{
                        arr.append(tiles[col, row-1]!)
                    }
                    if col < NumColumns-1{
                        arr.append(tiles[col+1, row]!)
                    }
                    if row < NumRows-1{
                        arr.append(tiles[col, row+1]!)
                    }
                }
            }
            
        }
        else{
            if diff_y > 0{
                if row < NumRows-1{
                    arr.append(tiles[col,row+1]!)
                }
                if diff_x > 0{
                    arr.append(tiles[col+1, row]!)
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if row > 0{
                        arr.append(tiles[col, row-1]!)
                    }
                }
                else{
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if col < NumColumns-1{
                        arr.append(tiles[col+1, row]!)
                    }
                    if row > 0{
                        arr.append(tiles[col, row-1]!)
                    }
                }
            }
            else{//diff_y < 0
                if row > 0{
                    arr.append(tiles[col,row-1]!)
                }
                if diff_x > 0{
                    if(col < NumColumns-1){
                        arr.append(tiles[col+1, row]!)
                    }
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if row < NumRows-1{
                        arr.append(tiles[col, row+1]!)
                    }
                }
                else{
                    if col > 0{
                        arr.append(tiles[col-1, row]!)
                    }
                    if col < NumColumns-1{
                        arr.append(tiles[col+1, row]!)
                    }
                    if row < NumRows-1{
                        arr.append(tiles[col, row+1]!)
                    }
                }
            }
            
        }
        
        return arr*/
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