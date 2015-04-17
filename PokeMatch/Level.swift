//
//  Level.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation

var NumColumns = 17
var NumRows = 10
let NumPokemonTiles:Int = (NumColumns-2)*(NumRows-2)

enum Difficulty:Int{
    case Easy = 0, Medium, Hard
}

/*====================================================================================
Contains the Model portion of MVC.
Holds the game logic.
Maintains a 2D-Array of Tiles, tileGrid.
Maintains a memoized map(dictionary) of each tile's neighbors, tileNeighbors.
Maintains the number of remaining pokemon.
Maintains the direction of gravity.
====================================================================================*/
class Level{
    private var tileGrid = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var tileNeighbors = [Tile: [Tile]]()
    private var numPokemonLeft = NumPokemonTiles
    let gravityDirection:GravityDirection
    let difficulty:Difficulty
    
    //numberOfLevelPokemon indicates how many unique types there are for the level.
    //the lower, the easier <==> higher number of each tile.
    let numberOfLevelPokemon:Int
    
    /*====================================================================================
        Constructor that sets the direction of gravity and difficulty for 
            an instance of Level
    ====================================================================================*/
    init(direction:GravityDirection, difficulty:Difficulty){
        self.gravityDirection = direction
        self.difficulty = difficulty
        switch difficulty{
        case .Easy:
            self.numberOfLevelPokemon = NumberOfPokemonTypes/3
        case .Medium:
            self.numberOfLevelPokemon = NumberOfPokemonTypes/2
        default:
            self.numberOfLevelPokemon = NumberOfPokemonTypes
        }
        
    }
    
    /*====================================================================================
    TileAtPosition
        Given column and row coordinates, returns the tile at that location.
    ====================================================================================*/
    func TileAtPosition(column:Int, row:Int) -> Tile?{
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tileGrid[column, row]
    }
    
    /*====================================================================================
    createInitialTiles
    Initializes the tile array, as well as the surrounding None tiles.
    Insures that there is an equal number of each tile.
    ====================================================================================*/
    func createInitialTiles() -> Set<Tile>{
        var unfilledCoordinates = [(Int, Int)]()
        
        var set = Set<Tile>()
        
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                //create layer of Blank Tiles around the array
                if (row == 0) || (row == NumRows-1) || (col == 0) || (col == NumColumns-1){
                    let blankTile = Tile(column:col, row:row, pokemon: .None)
                    tileGrid[col,row] = blankTile
                }
                else{
                    unfilledCoordinates.append((col, row))
                }
                
                
            }
        }
        //Outer blank layer has been filled
        //Now, fill in the unfilled spots.
        //precondition: unfilledCoordinates.count == NumPokemonTiles * NumberOfPokemonTypes
        for (var i=0; i<numberOfLevelPokemon; i++){
            for (var k=0; k<(NumPokemonTiles/numberOfLevelPokemon); k++){
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
                tileGrid[col, row] = tile
                
                set.insert(tile)
            }
            
        }
        
        return set
    }
    

    
    /*====================================================================================
    shuffle
        Function that shuffles the remaining tiles on the board. Maintains the same
        number of each tile, just changes the location. Only non-None tiles will be
        shuffled.
    ====================================================================================*/
    func shuffle () -> Set<Tile>{
        /*
            Iterates through tiles twice:
                Once to record not-None types in a type:int hashmap (counts how many of each type)
                Once to set a not-None type to a random type from the hashmap, then decrements the counter
        */
        var set = Set<Tile>()
        var typeCounts = [PokemonType: Int]()
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                //get type of tile
                var pkType = tileGrid[col, row]!.pokemon
                
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
                var tile = tileGrid[col, row]!
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
                    
                    set.insert(tile)

                }
            }
        }
        
        return set
    }
    
    
    /*====================================================================================
    tilesAreMatched
        Function returns true if two tiles can be matched and removed.
        Also returns the path between those two tiles (path is guaranteed to be < 3 turns.
        Removes those two from tileGrid.
    ====================================================================================*/
    func tilesAreMatched(t1: Tile, t2: Tile) -> (Bool, Path?){
        println("checking tile \(t1) and tile \(t2)")
        
        if tileIsUnreachable(t1, t2:t2){
            return (false, nil)
        }
        //Only search if tiles are the same
        else if(matchable(t1, t2)){
            var path = doBFS(t1, t2: t2)
            println(path)
            println(path.numTurns)
            
            //If returned path ends in t2
            if((path.last.column == t2.column) && (path.last.row == t2.row)){
                //set t1 and t2 to type None
                t1.setPokemonTypeToNone()
                t2.setPokemonTypeToNone()
                
                numPokemonLeft = numPokemonLeft - 2
                
                cascade(gravityDirection, t1:t1, t2:t2)
                    
                return (true, path)
            }
        }
        //Could not match tiles
        return (false, nil)
        
    }
    
    /*====================================================================================
    tileIsUnreachable
        Returns true if t2 is unreachable from t1.
        This occurs when t2 is surrounded by 4 tiles, none of which are t1.
        In the case where there is no gravity, there could be an empty tile 
            next to t2, but t2 still unreachable.
    ====================================================================================*/
    private func tileIsUnreachable(t1: Tile, t2: Tile) -> Bool{
        let neighbors = getNeighbors(t2)
        var noneTileCount = 0
        for tile in neighbors{
            if tile == t1{
                return false
            }
            if tile.pokemon == .None{
                noneTileCount++
            }
        }
        if noneTileCount > 0{
            //there is a free space going to the tile, so t2 is reachable
            return false
        }
        return true
    }
    
    
    /*====================================================================================
    doBFS
        Performs a BFS from t1 to t2.
        Precondition: t2 is reachable from t1.
        Postcondition: Returns a path, if there is one, from t1 to t2 that is
            less than 3 turns.
            If not possible, returns a bogus path that does not reach t2.
    ====================================================================================*/
    private func doBFS(t1: Tile, t2: Tile) -> Path{
        var bfsqueue = Queue<Path>()
        
        var initialpath = Path()
        initialpath.add(t1.column, row: t1.row)
        
        bfsqueue.enqueue(initialpath)
        
        while !bfsqueue.isEmpty(){
            let path = bfsqueue.dequeue()!
            
            //if the path has too many turns, throw it away
            if(path.numTurns > 2){
                continue
            }
            
            //if we have reached our destination, return the path
            let node = path.last
            if (node.column == t2.column && node.row == t2.row) && path.numTurns < 3{
                return path
            }
            //otherwise enqueue more paths
            let tile = tileGrid[node.column, node.row]!
            for neighbor in getNeighbors(tile){
                if !path.containsCoords(neighbor.column, row: neighbor.row) &&
                    ((neighbor.pokemon == .None) || (neighbor == t2)){
                    var newpath = path
                    newpath.add(neighbor.column, row:neighbor.row)
                    println(newpath)
                    bfsqueue.enqueue(newpath)
                    
                }
            }
        }
        return initialpath //returns bogus path if t2 is unreachable within 3 turns
    }
    

    /*====================================================================================
    cascade
        Handles gravity and cascading tiles down a given direction.
        t1 and t2 are the tiles that were removed.
    ====================================================================================*/
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
                        if tileGrid[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tileGrid[col+1, rowToCheck]!, t2: tileGrid[col, rowToCheck]!)
                        }
                    }
                    for col in 1..<NumColumns-1{
                        if tileGrid[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tileGrid[col+1, rowToCheck]!, t2: tileGrid[col, rowToCheck]!)
                        }
                    }
                }
                if direction == .Right{
                    //do a bubble sort to swap the Nones to the end of the row
                    for col in reverse(1..<NumColumns-1){
                        if tileGrid[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tileGrid[col-1, rowToCheck]!, t2: tileGrid[col, rowToCheck]!)
                        }
                    }
                    for col in reverse(1..<NumColumns-1){
                        if tileGrid[col, rowToCheck]!.pokemon == .None{
                            swapTiles(tileGrid[col-1, rowToCheck]!, t2: tileGrid[col, rowToCheck]!)
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
                        if tileGrid[colToCheck, row]!.pokemon == .None{
                            swapTiles(tileGrid[colToCheck, row-1]!, t2: tileGrid[colToCheck, row]!)
                        }
                    }
                    for row in reverse(1..<NumRows-1){
                        if tileGrid[colToCheck, row]!.pokemon == .None{
                            swapTiles(tileGrid[colToCheck, row-1]!, t2: tileGrid[colToCheck, row]!)
                        }
                    }
                }
                if direction == .Down{
                    //do a bubble sort to swap the Nones to the end of the col
                    for row in (1..<NumRows-1){
                        if tileGrid[colToCheck, row]!.pokemon == .None{
                            swapTiles(tileGrid[colToCheck, row+1]!, t2: tileGrid[colToCheck, row]!)
                        }
                    }
                    for row in (1..<NumRows-1){
                        if tileGrid[colToCheck, row]!.pokemon == .None{
                            swapTiles(tileGrid[colToCheck, row+1]!, t2: tileGrid[colToCheck, row]!)
                        }
                    }
                }
            }
        }

        
    }
    

    /*====================================================================================
    tileArrayToSet
        Returns tileGrid as a set of tiles.
    ====================================================================================*/
    func tileArrayToSet() -> Set<Tile>{
        var s = Set<Tile>()
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                s.insert(tileGrid[col, row]!)
            }
        }
        
        return s
    }
    
    /*====================================================================================
    swapTiles
        Swaps t1 and t2 within tileGrid.
        Does so by changing their pokemon types.
    ====================================================================================*/
    private func swapTiles(t1:Tile, t2:Tile){
        let (t1row, t1col) = (t1.row, t1.column)
        let (t2row, t2col) = (t2.row, t2.column)
        let tempPokemon = t2.pokemon
        tileGrid[t2col, t2row]!.pokemon = tileGrid[t1col, t1row]!.pokemon
        tileGrid[t1col, t1row]!.pokemon = tempPokemon
    }
    
    
    /*====================================================================================
    getNeighbors
        Returns a list of a given tile's neighbors. Memoized within tileNeighbors.
    ====================================================================================*/
    private func getNeighbors(tile: Tile) -> Array<Tile>{
        if let neighbors = tileNeighbors[tile]{
            return neighbors
        }
        else{
            let (col,row) = (tile.column, tile.row)
            var arr = Array<Tile>()
            if col < NumColumns-1{
                arr.append(tileGrid[col+1, row]!)
            }
            if col > 0{
                arr.append(tileGrid[col-1, row]!)
            }
            if row < NumRows-1{
                arr.append(tileGrid[col, row+1]!)
            }
            if row > 0{
                arr.append(tileGrid[col, row-1]!)
            }
            tileNeighbors[tile] = arr
            return arr
        }
    }
    
    /*====================================================================================
    remainingTiles
        Returns the number of remaining non-None tiles.
    ====================================================================================*/
    func remainingTiles() -> Int{
        return numPokemonLeft
    }
    
    /*====================================================================================
        Helper function to print a row to console.
    ====================================================================================*/
    func printRow(row:Int){
        for col in 0..<NumColumns{
            println(tileGrid[col, row])
        }
    }

    /*====================================================================================
        Helper function to print the entire tileGrid to console.
    ====================================================================================*/
    private func printTileArray(array: Array2D<Tile>){
        for row in 0..<NumRows{
            for col in 0..<NumColumns{
                let t = tileGrid[col,row]
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