//
//  Tile.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit

let NumberOfPokemonTypes:UInt32 = 3

enum PokemonType:Int{
    //last case must be None, and not included in NumberOfPokemonTypes
    
    case Bulbasaur = 0, Squirtle, Charmander, Caterpie, Pidgey, None
    
    var spriteName:String{
        switch self{
        case .Bulbasaur:
            return "bulbasaur"
        case .Squirtle:
            return "squirtle"
        case .Charmander:
            return "charmander"
        case .Caterpie:
            return "caterpie"
        case .Pidgey:
            return "pidgey"
        case .None:
            return "none"
        }
    }
    
    static func random() -> PokemonType{
        return PokemonType(rawValue:Int(arc4random_uniform(NumberOfPokemonTypes)))!
    }
}

class Tile:Printable, Hashable{
    var column:Int
    var row:Int
    var pokemon: PokemonType
    var sprite: SKSpriteNode?
    var selected: Bool
    
    init(column:Int, row:Int, pokemon:PokemonType){
        self.column = column
        self.row = row
        self.pokemon = pokemon
        selected = false
    }
    
    var hashValue:Int{
        return row*10 + column
    }
    
    var description:String{
        return "\(pokemon.spriteName), at column:\(column), row:\(row)"
    }
    
    func samePokemon(tile:Tile) -> Bool{
        return self.pokemon.spriteName == tile.pokemon.spriteName
    }
    
    func setPokemonTypeToNone(){
        self.pokemon = .None
    }
    
}

func == (lhs:Tile, rhs:Tile) -> Bool{
    return lhs.row == rhs.row && lhs.column == rhs.column
}

func matchable (lhs: Tile, rhs: Tile) -> Bool{
    return lhs.pokemon.spriteName == rhs.pokemon.spriteName
}