//
//  HardAIPlayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-30.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class HardAIPlayer: EasyAIPlayer {
    // makes deductions from other peopl's plays - my current strategy
    
    
    override init(c: Card) {
        charInfo = ["Miss Scarlett": nil, "Prof. Plum": nil, "Mrs Peacock": nil, "Mr Green": nil, "Col. Mustard": nil, "Mrs White": nil]
        
        weaponInfo = ["Candlestick": nil, "Knife": nil, "Lead Pipe": nil, "Revolver": nil, "Rope": nil, "Wrench": nil]
        
        roomInfo = ["Kitchen": nil, "Ballroom": nil, "Conservatory": nil, "Dining room": nil, "Billard": nil, "Library": nil, "Lounge": nil, "Hall": nil, "Study": nil]
        
        
        super.init(c: c)
        for x in hand
        {
            if(x.type == Type.CHARACTER)
            {
                charInfo[x.name] = self
            }else if (x.type == Type.WEAPON){
                weaponInfo[x.name] = self
            }else{
                roomInfo[x.name] = self
            }
        }
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
