//
//  TricksterAIPlayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-30.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class TricksterAIPlayer: EasyAIPlayer {
    //sometimes asks a combo they have. Max 1x per game
    
    var hasTricked = false;
    
    override init(c: Card) {
        
        super.init(c: c)
    }

    
    override func selectPersonWeapon() -> Trio
    {
        if(hasTricked == false && self.hand.contains(self.position!.room!) && Int(arc4random_uniform(10))==1) // 1/10 chance, could be any number
        {
            let person = self.hand.first(where: { (card) -> Bool in
                return card.type == Type.character
            }) ?? Card.getCardWithName(self.charInfo.first(where: { (pair :(key: String, value: Player?)) -> Bool in
                return pair.value != nil
            })?.key ?? "")
            let weapon = self.hand.first(where: { (card) -> Bool in
                return card.type == Type.weapon
            }) ?? Card.getCardWithName(self.weaponInfo.first(where: { (pair :(key: String, value: Player?)) -> Bool in
                return pair.value != nil
            })?.key ?? "")

            if(person == nil || weapon == nil)// in case somehow the odds go terribly wrong
            {
                return super.selectPersonWeapon()
            }
            
            hasTricked = true
            return Trio(person: person!, weapon: weapon!, location: (self.position?.room!)!)
        }
        
        return super.selectPersonWeapon()
    }
    


}
