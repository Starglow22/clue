//
//  Position.swift
//  Clue
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
    
    
    func reachablePositions(_ moves: Int, _ firstCall: Bool, lastRoomEntered: Position?, turnsSinceEntered : Int) -> [Position]
    {
        if(!firstCall && (self.isRoom || moves == 0)){
            
            return [Position]()
            
        }else{
            var neighbors = [Position]()
            for p in self.adjacent
            {
                if((!p.isOccupied || p.isRoom) && !(p == lastRoomEntered && turnsSinceEntered < 2))
                {
                    neighbors.append(p)
                    
                    for pos in p.reachablePositions(moves-1, false, lastRoomEntered: lastRoomEntered, turnsSinceEntered: turnsSinceEntered){ // avoid duplicates
                        if(!neighbors.contains(pos))
                        {
                            neighbors.append(pos);
                        }
                    }
                }
            }
            return neighbors
        }
    }
    
    //breadth first search
    func closestRoom(lastVisited: Position?, numTurns : Int) -> Position? //_ queue: [Position], visited: [Position]) -> Position
    {
        var queue = [self];
        var visited = [Position]();
        var pos: Position;
        repeat{
            if(queue.isEmpty)
            {
                return nil
            }
            pos = queue.removeFirst();
            visited.append(pos);
            
            for p in pos.adjacent{
                if(!queue.contains(p) && !visited.contains(p) && !p.isOccupied && !(pos.isRoom && p.isRoom && pos != self) && !(pos == lastVisited && numTurns < 2))
                {
                    queue.append(p);
                }
            }
            
        }while(!pos.isRoom || pos == self || (pos == lastVisited && numTurns < 2))
        
        return pos;
    }
    
    //breadth first search
    func closestRoomFrom(selection: [String], lastVisited: Position?, numTurns : Int) -> Position? //unknown.length > 1, string are names of rooms
    {
        var queue = [self];
        var visited = [Position]();
        var pos: Position;
        repeat{
            if(queue.isEmpty)
            {
                return nil
            }
            pos = queue.removeFirst();
            visited.append(pos);
            
            for p in pos.adjacent{
                if(!queue.contains(p) && !visited.contains(p) && !p.isOccupied && !(p.isRoom && pos.isRoom && pos != self))
                {
                    queue.append(p);
                }
            }
            
        }while(!pos.isRoom || pos == self || (pos == lastVisited && numTurns < 2) || !selection.contains((pos.room?.name)!))
        
        return pos;
    }
    
    //breadth first search
    func shortestPathTo(_ room: Position, lastVisited: Position?, numTurns : Int) -> [Position]?
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
                    if(node == room || (!vis.contains(node) && (!node.isOccupied || node.isRoom)
                        && !(node == self && node.isRoom && current.isRoom)  && !(node == lastVisited && numTurns < 2))){
                        q.append(node);
                        vis.append(node)
                        if(prev[node] == nil)
                        {
                            prev[node] = current;
                        }
                    }
                }
            }
        }
        
        
        var backtrackNode = room
        var endPoint : Position?
        while(backtrackNode != self)
        {
            directions.append(backtrackNode)
            if(prev[backtrackNode] == nil)
            {
                return nil // no path found
            }
            
            backtrackNode = prev[backtrackNode]!
            
            if(backtrackNode.isRoom && backtrackNode != self) // end path at intermediate room if applicable
            {
                endPoint = backtrackNode;
            }
        }
        
        if(endPoint == nil)
        {
            return directions.reversed()
        }else{ // truncate at room
            return directions.dropFirst(directions.index(of: endPoint!)!).reversed()
        }
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
