//
//  Tile.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit

let NumberOfPokemonTypes:Int = 15

enum PokemonType:Int, Printable{
    //last case must be None, and not included in NumberOfPokemonTypes
    
    case Bulbasaur = 0, Squirtle, Charmander, Ditto, Caterpie, Koffing, Abra, Poliwag, Growlithe, Paras, Psyduck, Geodude, Jigglypuff, Grimer, Slowpoke, None
    
    var spriteName:String{
        switch self{
        case .Bulbasaur:
            return "bulbasaur"
        case .Squirtle:
            return "squirtle"
        case .Charmander:
            return "charmander"
        case .Ditto:
            return "ditto"
        case .Caterpie:
            return "caterpie"
        case .Koffing:
            return "koffing"
        case .Abra:
            return "abra"
        case .Poliwag:
            return "poliwag"
        case .Growlithe:
            return "growlithe"
        case .Paras:
            return "paras"
        case .Psyduck:
            return "psyduck"
        case .Geodude:
            return "geodude"
        case .Jigglypuff:
            return "jigglypuff"
        case .Grimer:
            return "grimer"
        case .Slowpoke:
            return "slowpoke"
        case .None:
            return "none"
        }
    }
    
    var description:String{
        return self.spriteName
    }
    
    static func random() -> PokemonType{
        return PokemonType(rawValue:Int(arc4random_uniform(UInt32(NumberOfPokemonTypes))))!
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
    
    func setPokemonTypeTo(type:PokemonType){
        self.pokemon = type
    }
    
}

func == (lhs:Tile, rhs:Tile) -> Bool{
    return lhs.row == rhs.row && lhs.column == rhs.column
}

func matchable (lhs: Tile, rhs: Tile) -> Bool{
    return lhs.pokemon.spriteName == rhs.pokemon.spriteName
}