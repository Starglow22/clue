//
//  Position.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Position{
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
        
        if(node.name!.contains("start"))
        {
            isOccupied = true
        }else{
            isOccupied = false
        }
        
    }
    
    
    func reachablePositions(_ moves: Int, _ firstCall: Bool) -> [Position]
    {
        if(!firstCall && (self.isRoom || moves == 0)){

            return [Position]()
            
        }else{
            var neighbors = [Position]()
            for p in self.adjacent
            {
                if(!p.isOccupied)
                {
                    neighbors.append(p)
                }
                
                for pos in p.reachablePositions(moves-1, false){ // avoid duplicates
                    if(!neighbors.contains(pos))
                    {
                        neighbors.append(pos);
                    }
                }
                
            }
            return neighbors
        }
    }
    
    //breadth first search
    func closestRoom() -> Position//_ queue: [Position], visited: [Position]) -> Position
    {
        var queue = self.adjacent;
        var visited = [self];
        var pos: Position;
        repeat{
            pos = queue.removeFirst();
            visited.append(pos);
            
            for p in pos.adjacent{
                if(!queue.contains(p) && !visited.contains(p))
                {
                    queue.append(p);
                }
            }
            
        }while(!pos.isRoom)
        
        return pos;
        
        
/*        if(self.isRoom)
        {
            return self
        }else{
            var newQueue = queue
                for pos in self.adjacent
                {
                    if(!newQueue.contains(pos) && !visited.contains(pos))
                    {
                        newQueue.append(pos);
                    }
            
                }
            return newQueue.removeFirst().closestRoom(newQueue, visited: visited+[self])
        }*/
    }
    
    //breadth first search
    func closestRoomFrom(selection: [String]) -> Position //unknown.length > 1, string are names of rooms
    {
        var queue = self.adjacent;
        var visited = [self];
        var pos: Position;
        repeat{
            pos = queue.removeFirst();
            visited.append(pos);
            
            for p in pos.adjacent{
                if(!queue.contains(p) && !visited.contains(p))
                {
                    queue.append(p);
                }
            }
            
        }while(!(pos.isRoom && selection.contains((pos.room?.name)!)))
        
        return pos;
    }
    
    //breadth first search
    func shortestPathTo(_ room: Position) -> [Position]?
    {
        var vis  = [Position]()
         var prev = Dictionary<Position, Position>()
        
        
            var directions = [Position]();
            var q = [Position]();
            var current = self;
            q.append(current);
            vis.append(current)
            while(!q.isEmpty){
                current = q.removeFirst();
                if (current == room){
                    break;
                }else{
                    for node in current.adjacent{
                        
                        if(!vis.contains(node)){
                            q.append(node);
                            vis.append(node)
                            prev[node] = current;
                        }
                    }
                }
            }

        
        var node = room
        while(node != self)
        {
            directions.append(node)
            node = prev[node]!
        }
    return directions.reversed()
        
        /*
         if(self == room)
         {
         return pathSoFar + [self]
         }else if (self.isRoom){
         return nil;
         }else{
         var newQueue = queue;
         
         for pos in self.adjacent
         {
         if(!newQueue.contains(pos) && !pathSoFar.contains(pos))
         {
         newQueue.append(pos);
         }
         
         }
         
         var result : [Position]?;
         while(result == nil && !newQueue.isEmpty)
         {
         result = newQueue.removeFirst().shortestPathTo(room, pathSoFar: pathSoFar+[self], queue: newQueue)
         }
         return result
         }
         */
    }

}

extension Position:Hashable{
var hashValue: Int {
    return sprite.hashValue;
}

static func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.adjacent == rhs.adjacent && lhs.room == rhs.room && rhs.isRoom == rhs.isRoom
}
}
