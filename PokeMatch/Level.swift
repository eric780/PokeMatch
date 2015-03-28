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
    private var tileNeighbors = [Tile: [Tile]]()
    private var numPokemonLeft = NumPokemonTiles
    let gravityDirection:GravityDirection = .None
    
    
    func TileAtPosition(column:Int, row:Int) -> Tile?{
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle () -> Set<Tile>{
        //iterates through tiles, records which ones have pokemon types of None saves to hashmap counter
        //iterates through tiles again, if tile has type not-non, sets it to a random type from hashmap
        var set = Set<Tile>()
        var typeCounts = [PokemonType: Int]()
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                //get type of tile
                var pkType = tiles[col, row]!.pokemon
                
                //don't count None types
                if pkType != .None{
                    //if type not yet encountered, initialize at 1
                    //otherwise increment the count of that type
                    var count = typeCounts[pkType]
                    if count == nil{
                        typeCounts[pkType] = 1
                    }
                    else{
                        count = count! + 1
                        typeCounts[pkType] = count
                    }
                }

                //end nested for loop
            }
        }
        
        //now iterate again through all tiles
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                var tile = tiles[col, row]!
                if tile.pokemon != .None{
                    //get random key (pokemonType)
                    var randomIndex = Int(arc4random_uniform(UInt32(typeCounts.count)))
                    var pkType = Array(typeCounts.keys)[randomIndex]
                    var newCount = typeCounts[pkType]
                    
                    if(newCount > 0){
                        //set current tile to randomly chosen pkType
                        tile.setPokemonTypeTo(pkType)
                        newCount = newCount!-1
                        typeCounts[pkType] = newCount
                    }
                    else{//we ran out of this type already
                        //pick another random index
                        while(newCount <= 0){
                            randomIndex = Int(arc4random_uniform(UInt32(typeCounts.count)))
                            pkType = Array(typeCounts.keys)[randomIndex]
                            newCount = typeCounts[pkType]
                        }
                        //same as above, set current tile to pkType
                        tile.setPokemonTypeTo(pkType)
                        newCount = newCount! - 1
                        typeCounts[pkType] = newCount
                    }
                    
                    set.addElement(tile)

                }
            }
        }
        
        return set
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
                    
                    numPokemonLeft = numPokemonLeft - 2
                    
                    cascade(gravityDirection, t1:t1, t2:t2)
                    
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
    
    //handles gravity and cascades tiles down a given direction
    //t1 and t2 are the two tiles removed
    private func cascade(direction:GravityDirection, t1:Tile, t2:Tile){
        if direction == .None{
            return
        }
        
        //determine rows and cols to check
        var rowsToCheck = [t1.row]
        var colsToCheck = [t1.column]
        if t1.row != t2.row{
            rowsToCheck.append(t2.row)
        }
        if t1.column != t2.column{
            colsToCheck.append(t2.column)
        }
        
        
        if direction == .Left || direction == .Right{
            while !rowsToCheck.isEmpty{
                let rowToCheck = rowsToCheck.removeAtIndex(0)
                if direction == .Left{
                    //do a bubble sort to swap the Nones to the end of the row
                    for col in 1..<NumColumns-1{
                        if tiles[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tiles[col+1, rowToCheck]!, t2: tiles[col, rowToCheck]!)
                        }
                    }
                    for col in 1..<NumColumns-1{
                        if tiles[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tiles[col+1, rowToCheck]!, t2: tiles[col, rowToCheck]!)
                        }
                    }
                }
                if direction == .Right{
                    //do a bubble sort to swap the Nones to the end of the row
                    for col in reverse(1..<NumColumns-1){
                        if tiles[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tiles[col-1, rowToCheck]!, t2: tiles[col, rowToCheck]!)
                        }
                    }
                    for col in reverse(1..<NumColumns-1){
                        if tiles[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tiles[col-1, rowToCheck]!, t2: tiles[col, rowToCheck]!)
                        }
                    }
                }
            }
            
        }
        else{//direction is Up or Down
            while !colsToCheck.isEmpty{
                let colToCheck = colsToCheck.removeAtIndex(0)
                if direction == .Up{
                    //do a bubble sort to swap the Nones to the end of the col
                    for row in reverse(1..<NumRows-1){
                        if tiles[colToCheck, row]!.pokemon == .None{
                            swapTiles(tiles[colToCheck, row-1]!, t2: tiles[colToCheck, row]!)
                        }
                    }
                    for row in reverse(1..<NumRows-1){
                        if tiles[colToCheck, row]!.pokemon == .None{
                            swapTiles(tiles[colToCheck, row-1]!, t2: tiles[colToCheck, row]!)
                        }
                    }
                }
                if direction == .Down{
                    //do a bubble sort to swap the Nones to the end of the col
                    for row in (1..<NumRows-1){
                        if tiles[colToCheck, row]!.pokemon == .None{
                            swapTiles(tiles[colToCheck, row+1]!, t2: tiles[colToCheck, row]!)
                        }
                    }
                    for row in (1..<NumRows-1){
                        if tiles[colToCheck, row]!.pokemon == .None{
                            swapTiles(tiles[colToCheck, row+1]!, t2: tiles[colToCheck, row]!)
                        }
                    }
                }
            }
        }

        
    }
    
    func printRow(row:Int){
        for col in 0..<NumColumns{
            println(tiles[col, row])
        }
    }
    
    func tileArrayToSet() -> Set<Tile>{
        var s = Set<Tile>()
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                s.addElement(tiles[col, row]!)
            }
        }
        
        return s
    }
    
    //swaps t1 and t2 within tiles
    private func swapTiles(t1:Tile, t2:Tile){
        let (t1row, t1col) = (t1.row, t1.column)
        let (t2row, t2col) = (t2.row, t2.column)
        let tempPokemon = t2.pokemon
        tiles[t2col, t2row]!.pokemon = tiles[t1col, t1row]!.pokemon
        tiles[t1col, t1row]!.pokemon = tempPokemon
    }
    
    
    //returns the Manhattan distance between two tiles (H)
    private func distance(t1:Tile, t2:Tile) -> Int{
        let side1 = Float(t2.column - t1.column)
        let side2 = Float(t2.row - t1.row)

        return Int(sqrtf(pow(side1, 2) + pow(side2, 2)))
    }
    
    //returns a list of neighboring tiles (memoized)
    private func getNeighbors(tile: Tile) -> Array<Tile>{
        if let neighbors = tileNeighbors[tile]{
            return neighbors
        }
        else{
            let (col,row) = (tile.column, tile.row)
            var arr = Array<Tile>()
            if col < NumColumns-1{
                arr.append(tiles[col+1, row]!)
            }
            if col > 0{
                arr.append(tiles[col-1, row]!)
            }
            if row < NumRows-1{
                arr.append(tiles[col, row+1]!)
            }
            if row > 0{
                arr.append(tiles[col, row-1]!)
            }
            tileNeighbors[tile] = arr
            return arr
        }
    }
    
    func remainingTiles() -> Int{
        return numPokemonLeft
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