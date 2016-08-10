//
//  HumanPlayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class HumanPlayer: Player {
    
    override func reply(t: Trio) -> Card?
    {
        return nil
    }
    
    
    override func rollDie() -> Int
    {
        return 0;
    }
    
    override func move(num: Int)
    {
        
    }
    
    override func isInRoom() -> Bool
    {
        return false;
        
    }
    
    override func chooseSuspectOrAccuse()
    {
        
    }
    
    override func selectPersonWeapon() -> Trio
    {
        return Trio(person: Game.getGame().players[0].character , weapon: (Game.getGame().roomScene?.weapons![0])!, location: self.position!.room!)
    }
    
    
    override func takeNotes(answer: Answer)
    {
        //UI display answer
    }
    

}
