//
//  AIPlayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import Cocoa

class EasyAIPlayer: Player {
    
    // Simple elimination: never ask a combo you already know. May ask with cards from hand but not all
    
    var charInfo: [String : Player?]
    var weaponInfo: [String : Player?]
    var roomInfo: [String : Player?]
    
    var shown: [String : [Card]]
    
    var charSoln: Card?
    var weaponSoln: Card?
    var roomSoln: Card?
    
    override init(c: Card) {
        charInfo = ["Miss Scarlett": nil, "Prof. Plum": nil, "Mrs Peacock": nil, "Mr Green": nil, "Col. Mustard": nil, "Mrs White": nil]
        
        weaponInfo = ["Candlestick": nil, "Knife": nil, "Lead Pipe": nil, "Revolver": nil, "Rope": nil, "Wrench": nil]
        
        roomInfo = ["Kitchen": nil, "Ballroom": nil, "Conservatory": nil, "Dining room": nil, "Billard": nil, "Library": nil, "Lounge": nil, "Hall": nil, "Study": nil]
        
        shown = ["Miss Scarlett": [], "Prof. Plum": [], "Mrs Peacock": [], "Mr Green": [], "Col. Mustard": [], "Mrs White": []]
        
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
    
    
    
    override func reply(t: Trio, p:Player) -> Card?
    {
        let numIHave = (hand.contains(t.location) ? 1 : 0) + (hand.contains(t.weapon) ? 1 : 0) + (hand.contains(t.person) ? 1 : 0)
        let response : Card
        
        
        if(numIHave == 0)
        {
            return nil;
        }else if (numIHave == 1)
        {
            if(hand.contains(t.person))
            {
                response = t.person;
            }else if (hand.contains(t.weapon)){
                response = t.weapon
            }else{
                response = t.location
            }
        }else{
            if(shown[p.character.name]!.contains(t.location))
            {
                response = t.location
            }else if(shown[p.character.name]!.contains(t.person)){
                response = t.person
            }else if(shown[p.character.name]!.contains(t.weapon)){
                response = t.weapon
            }else{
                if(hand.contains(t.person))
                {
                    response = t.person;
                }else if (hand.contains(t.weapon)){
                    response = t.weapon
                }else{
                    response = t.location
                }
            }
        }
        
        shown[p.character.name]?.append(response)
        return response
    }
    
    
    override func move(num: Int)
    {
        let options = position!.reachablePositions(num)
        let target: Position
        if(suspect)
        {
            target = (position?.closestRoom([Position]()))!
        }else{
            target = Game.getGame().boardScene.board[(roomSoln?.name)!]! //roomSoln.
        }
        
        let pathToDestination = position!.shortestPathTo(target, pathSoFar: [Position](), queue: [Position]())
        for i in 1...pathToDestination.count
        {
            if(options.contains(pathToDestination[pathToDestination.count-i]))
            {
                moveToken(pathToDestination[pathToDestination.count-i])
                return;
                
            }
        }
        
    }
    
    override func chooseSuspectOrAccuse()
    {
        if(charSoln != nil && weaponSoln != nil && roomSoln != nil)
        {
            suspect = true;
        }else{
            suspect = false;
        }
    }
    
    override func selectPersonWeapon() -> Trio
    {
        var char : String? = nil
        var weapon: String? = nil
        
        for s in charInfo
        {
            if(s.1 == nil)
            {
                char = s.0
                break
            }
        }
        
        for s in weaponInfo
        {
            if(s.1 == nil)
            {
                weapon = s.0
                break
            }
        }
        
        if(char == nil && weapon == nil)
        {
            return Trio(person: charSoln!, weapon: weaponSoln!, location: self.position!.room!)
        }else{
            
            return Trio(person: Card.getCardWithName(char!)! , weapon: Card.getCardWithName(weapon!)!, location: self.position!.room!)
        }
    }
    
    
    override func takeNotes(answer: Answer)
    {
        //UI display answer
    }
    
    
}
