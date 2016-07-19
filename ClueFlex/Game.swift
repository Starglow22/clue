//
//  File.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Foundation


class Game: NSObject {
    var players: [Player]
    var currentPlayer: Player
    
    var solution: Trio
    
    init(players: [Player], s:Trio)
    {
        self.players = players
        currentPlayer = players[Int(arc4random_uniform(UInt32(players.count)))]
        
        solution = s
    }

}
