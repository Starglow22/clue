//
//  Position.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Position: Equatable {
    var isRoom : Bool
    var room: Card?
    var adjacent: [Position]
    
    var sprite : SKSpriteNode
    
    init(isRoom: Bool, room: Card?, node: SKSpriteNode)
    {
        self.isRoom = isRoom;
        self.sprite = node
        self.room = room;
        self.adjacent = [Position]()
    }
    
    func reachablePositions(moves: Int) -> [Position]
    {
        if(moves == 0 || self.room != nil)
        {
            return [self]
        }else{
            var neighbors = [Position]()
            for p in self.adjacent
            {
                neighbors += p.reachablePositions(moves-1)
            }
            return neighbors
        }
    }

}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.adjacent == rhs.adjacent && lhs.room == rhs.room && rhs.isRoom == rhs.isRoom
}