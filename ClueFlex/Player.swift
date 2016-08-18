//
//  PLayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Player: NSObject{
    
    var hand: [Card]
    var position: Position?
    var character: Card
    
    var sprite : SKSpriteNode?

    
    init(c:Card)
    {
        character = c;
        hand = [Card]()
    }
    
    
    func reply(t: Trio) -> Card?
    {
        
        return nil
    }
    
    func play()
    {
        let roll = rollDie()
        move(roll)
        if(isInRoom())
        {
            Game.getGame().moveToRoomView()
            chooseSuspectOrAccuse()
            let question = selectPersonWeapon()
            let answer = ask(question)
            takeNotes(answer)
            Game.getGame().moveToBoardView()
            passTurn()
            
        }
        
    }
    
    func rollDie() -> Int
    {
        return Int(arc4random_uniform(UInt32(6))+1);
    }
    
    func move(num: Int)
    {
        
    }
    
    func isInRoom() -> Bool
    {
        return false;
        
    }
    
    func chooseSuspectOrAccuse()
    {
        
    }
    
    func selectPersonWeapon() -> Trio
    {
        return Trio(person: Game.getGame().players[0].character , weapon: (Game.getGame().roomScene?.weapons![0])!, location: self.position!.room!)
    }
    
    func ask(question: Trio) -> Answer
    {
        let players = Game.getGame().players
        let me = players.indexOf(self)
        let numPlayers = players.count
        var counter = me! + 1;
        
        var answer: Card?
        var responder: Player?
        
        while(answer == nil && counter != me)
        {
            answer = players[counter].reply(question)
            
            if(answer != nil)
            {
                responder = players[counter]
            }
            
            counter = counter + 1
            counter = counter % numPlayers
        }
        
        return Answer(card: answer, person: responder)
    }
    
    func takeNotes(answer: Answer)
    {
        
    }
    
    
    func passTurn()
    {
        Game.getGame().currentPlayer = Game.getGame().players[(Game.getGame().players.indexOf(self)!+1) % Game.getGame().players.count]
        Game.getGame().updatePList()
        
        
        if(Game.getGame().currentPlayer is HumanPlayer)
        {
            Game.getGame().boardScene.childNodeWithName("UICONTROLS")?.childNodeWithName("TextDisplay")?.runAction(SKAction.unhide())
            Game.getGame().state = State.startOfTurn
        }else{
        Game.getGame().boardScene.childNodeWithName("UICONTROLS")?.childNodeWithName("TextDisplay")?.runAction(SKAction.hide())
            Game.getGame().state = State.waitingForTurn
        }
    }
    
    
    
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.hand == rhs.hand && lhs.position == rhs.position && rhs.character == rhs.character
}


enum PlayerStates{
    case needAnswer
    
    /*case needSuspectOrAccuse
    case needQuestion
    case needRoll
 */
}