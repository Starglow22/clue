//
//  Card.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Card : Equatable, Hashable {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    var hashValue: Int

    static var list = [Card]()
    
    var type: Type
    var imageName: String
    var name: String
    
    init(n: String, t: Type, file:String) {
        name = n;
        type = t;
        imageName = file;
        hashValue = n.hashValue
        
        Card.list.append(self)
    }
    
    static func getCardWithName(_ name:String) -> Card?
    {
        for c in list{
            if(c.name == name)
            {
                return c
            }
        }
        return nil
    }
    
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}



enum Type{
    case character
    case weapon
    case location
}
