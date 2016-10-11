//
//  TricksterAIPlayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-30.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class TricksterAIPlayer: EasyAIPlayer {
    //sometimes asks a combo they have. Max 1x per game
    
    
    override init(c: Card) {
        
        super.init(c: c)
    }

    
    override func selectPersonWeapon() -> Trio
    {
        return Trio(person: Game.getGame().players[0].character , weapon: (Game.getGame().roomScene?.weapons![0])!, location: self.position!.room!)
    }
    


}
