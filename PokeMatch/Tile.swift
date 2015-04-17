//
//  Tile.swift
//  PokeMatch
//
//  Created by Eric Lin on 1/11/15.
//  Copyright (c) 2015 Eric Lin. All rights reserved.
//

import Foundation
import SpriteKit

let NumberOfPokemonTypes:Int = 30

enum PokemonType:Int, Printable{
    //last case must be None, and not included in the count of NumberOfPokemonTypes
    
    case Bulbasaur = 0, Squirtle, Charmander, Ditto, Caterpie,
    Koffing, Abra, Poliwag, Growlithe, Paras,
    Psyduck, Geodude, Jigglypuff, Grimer, Slowpoke,
    Vulpix, Raichu, Scyther, Gyarados, Weepinbell,
    Beedrill, Pidgeot, Gengar, Dragonair, Hypno,
    Vaporeon, Jolteon, Flareon, Machamp, Exeggcute,
    None
    
    //Returns the string of a sprite, used to match the sprite to the image name, spriteName.png
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
        case .Raichu:
            return "raichu"
        case .Vulpix:
            return "vulpix"
        case .Scyther:
            return "scyther"
        case .Gyarados:
            return "gyarados"
        case .Weepinbell:
            return "weepinbell"
        case .Beedrill:
            return "beedrill"
        case .Pidgeot:
            return "pidgeot"
        case .Gengar:
            return "gengar"
        case .Dragonair:
            return "dragonair"
        case .Hypno:
            return "hypno"
        case .Vaporeon:
            return "vaporeon"
        case .Jolteon:
            return "jolteon"
        case .Flareon:
            return "flareon"
        case .Machamp:
            return "machamp"
        case .Exeggcute:
            return "exeggcute"
        case .None:
            return "none"
        }
    }
    
    var description:String{
        return self.spriteName
    }
    
    //Returns a random Pokemon Type
    static func random(number:Int) -> PokemonType{
        return PokemonType(rawValue:Int(arc4random_uniform(UInt32(number))))!
    }
    
}

/*====================================================================================
    Class Tile

Represents a Tile in the game. Since its a class, instances are REFERENCED (not copied)
as they would be in a Struct.
====================================================================================*/
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
    
    /*====================================================================================
        We can hash a Tile based on its position
    ====================================================================================*/
    var hashValue:Int{
        return row*100 + column
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