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

    var suspect: Bool
    
    var counter: Int
    
    init(c:Card)
    {
        character = c;
        hand = [Card]()
        
        suspect = true
        counter = 0
    }
    
    
    func reply(t: Trio, p:Player) -> Card?
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
            
            //nil only if waiting for human input
            if(answer != nil)
            {
                takeNotes(answer!)
                Game.getGame().moveToBoardView()
                passTurn()
            }
            
        }
        
    }
    
    func rollDie() -> Int
    {
        return Int(arc4random_uniform(UInt32(6))+1);
    }
    
    func move(num: Int)
    {
        
    }
    
    //animation - move sprite node in 2 moves x and y, largest first, set new position
    func moveToken(newPos: Position)
    {
        // move to new position
        let newX = newPos.sprite.position.x
        let newY = newPos.sprite.position.y
        
        let oldX = sprite!.position.x
        let oldY = sprite!.position.y
        
        if (abs(oldX-newX) > abs(oldY - newY))
        {
            sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: oldY), duration: 0.5))
            sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: newY), duration: 0.5))
        }else{
            sprite?.runAction(SKAction.moveTo(CGPoint(x: oldX, y: newY), duration: 0.5))
            sprite?.runAction(SKAction.moveTo(CGPoint(x: newX, y: newY), duration: 0.5))
        }
        
        position = newPos
    }
    
    func isInRoom() -> Bool
    {
        return (position?.isRoom)!;
        
    }
    
    func chooseSuspectOrAccuse()
    {
        
    }
    
    func selectPersonWeapon() -> Trio
    {
        return Trio(person: Game.getGame().players[0].character , weapon: (Game.getGame().roomScene?.weapons![0])!, location: self.position!.room!)
    }
    
    func ask(question: Trio) -> Answer?
    {
        let players = Game.getGame().players
        let me = players.indexOf(self)
        let numPlayers = players.count
        counter = me! + 1;
        
        var answer: Card?
        var responder: Player?
        
        while(answer == nil && counter != me)
        {
            if(players[counter] is HumanPlayer)
            {
                players[counter].reply(question, p: self)
                return nil
            }
            answer = players[counter].reply(question, p: self)
            
            if(answer != nil)
            {
                responder = players[counter]
            }
            
            counter = counter + 1
            counter = counter % numPlayers
        }
        
        return Answer(card: answer, person: responder)
    }
    
    
    func resumeAsk(question: Trio, humanAns: Card?)
    {
        let players = Game.getGame().players
        let me = players.indexOf(self)
        let numPlayers = players.count
        
        var answer = humanAns
        var result: Answer
        if(answer != nil)
        {
            result = Answer(card: answer, person: Game.getGame().humanPlayer)
        }else{
            
            var responder: Player?
            
            while(answer == nil && counter != me)
            {
                
                answer = players[counter].reply(question, p:self)
                
                if(answer != nil)
                {
                    responder = players[counter]
                }
                
                counter = counter + 1
                counter = counter % numPlayers
            }
            
            result = Answer(card: answer, person: responder)
        }
        
        takeNotes(result)
        Game.getGame().moveToBoardView()
        passTurn()
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
            Game.getGame().state = State.startOfTurn
        }else{
            Game.getGame().state = State.waitingForTurn
            
            Game.getGame().currentPlayer.play()
        }
        (Game.getGame().boardScene.childNodeWithName("CurrentPlayer") as! SKSpriteNode).texture = SKTexture(imageNamed: (Game.getGame().currentPlayer.character.imageName))
    }
    
    
    
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.hand == rhs.hand && lhs.position == rhs.position && rhs.character == rhs.character
}

