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
    
    var isOccupied : Bool
    
    init(isRoom: Bool, room: Card?, node: SKSpriteNode)
    {
        self.isRoom = isRoom;
        self.sprite = node
        self.room = room;
        self.adjacent = []
        
        if(node.name!.containsString("start"))
        {
            isOccupied = true
        }else{
            isOccupied = false
        }
        
    }
    
    
    func reachablePositions(moves: Int) -> [Position]
    {
        if(self.room != nil)
        {
            return [self]
        }else if(moves == 0){
            if(!isOccupied)
            {
                return [self]
            }else{
                return [Position]()
            }
            
        }else{
            var neighbors = [Position]()
            for p in self.adjacent
            {
                neighbors += p.reachablePositions(moves-1)
            }
            return neighbors
        }
    }
    
    //breadth first search
    func closestRoom(queue: [Position]) -> Position
    {
        if(self.isRoom)
        {
            return self
        }else{
            var newQueue = queue + self.adjacent
            return newQueue.removeLast().closestRoom(newQueue)
        }
    }
    
    //dfs
    // first item is current position, last item is adjacent to room
    func shortestPathTo(room: Position, pathSoFar: [Position]) -> [Position]
    {
        if(self == room)
        {
            return pathSoFar
        }else{
            var shortestPath:[Position]? = nil
            for p in self.adjacent
            {
                let result = p.shortestPathTo(room, pathSoFar: pathSoFar + [self])
                if(shortestPath == nil || shortestPath!.count > result.count)
                {
                    shortestPath = result
                }
            }
            return shortestPath!
        }
    }

}

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.adjacent == rhs.adjacent && lhs.room == rhs.room && rhs.isRoom == rhs.isRoom
}