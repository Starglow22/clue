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
    
    override init()
    {
        players = [Player]()
        currentPlayer = Player()
    }

}
