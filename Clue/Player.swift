//
//  PLayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Player: NSObject{
    
    static let MOVE_DELAY = 0.7
    
    var hand: [Card]
    var position: Position?
    var character: Card
    
    var sprite : SKSpriteNode?
    
    var suspect: Bool
    
    var counter: Int
    
    var lastRoomEntered : Position?
    var turnsSinceEntered : Int
    
    init(c:Card)
    {
        character = c;
        hand = [Card]()
        
        suspect = true
        counter = 0
        
        turnsSinceEntered = 0
    }
    
    
    func reply(_ t: Trio, p:Player) -> Card?
    {
        
        return nil
    }
    
    func play()
    {
        let roll = rollDie()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let distance  = self.move(num: roll)
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double)(min(distance, roll))*Player.MOVE_DELAY) {
                if(self.isInRoom())
                {
                    Game.getGame().state = State.waitingForDoneWithNoteTaking
                    Game.getGame().moveToRoomView()
                    self.chooseToSuspect()
                    let question = self.selectPersonWeapon()
                    
                    if(!self.suspect)
                    {
                        Game.getGame().accuse(guess: question)
                    }else{
                        self.displayQuestion(question)
                        let answer = self.ask(question)
                        
                        //nil only if waiting for human input
                        if(answer != nil)
                        {
                            self.takeNotes(answer!, question: question)
                        }
                    }
                }else{
                    self.passTurn()
                }
            }
        }
    }
    
    func displayQuestion(_ question: Trio)
    {
        let display = Game.getGame().roomScene!.childNode(withName: "QuestionPanel")!
        
        display.run(SKAction.unhide())
        
        (display.childNode(withName: "Ask") as! SKLabelNode).text = "\(Game.getGame().currentPlayer.character.name) suspects:"
        display.run(SKAction.resize(toWidth: (display.childNode(withName: "Ask")?.frame.width)!, duration: 0))
        (display.childNode(withName: "Person") as! SKLabelNode).text = question.person.name
        (display.childNode(withName: "Weapon") as! SKLabelNode).text = question.weapon.name
        (display.childNode(withName: "Location") as! SKLabelNode).text = self.position!.room!.name
        
        Game.getGame().state = State.waitingForDoneWithNoteTaking
    }
    
    func rollDie() -> Int
    {
        let roll = Int(arc4random_uniform(UInt32(6))+1);
        if(!(self is HumanPlayer))
        {
            self.playRollAnimation(die: roll);
        }
        return roll
    }
    
    func playRollAnimation(die: Int)
    {
        let root = Game.getGame().boardScene.childNode(withName: "UICONTROLS")!
        let textDisplay = root.childNode(withName: "TextDisplay") as! SKLabelNode
        
        textDisplay.text = self.character.name + "'s turn!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            root.childNode(withName: "Die"+die.description)?.run(SKAction.unhide())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Game.getGame().boardScene.rollDie(roll: die); // return random int if not provided with one
            textDisplay.text = self.character.name + " rolled " +  die.description;
        }
    }
    
    func move(num: Int) -> Int
    {
        return 0
    }
    
    //animation - move through path
    func moveToken(newPos: Position, p: [Position]?)
    {
        
        if(position!.isRoom)
        {
            lastRoomEntered = position
            turnsSinceEntered = 0
        }else{
            turnsSinceEntered += 1
        }
        
        let root = Game.getGame().boardScene.childNode(withName: "UICONTROLS")!
        root.childNode(withName: "Die")?.run(SKAction.hide())
        
        position?.isOccupied = false;
        position = newPos
        newPos.isOccupied = true;
        
        if(sprite == nil)
        {
            sprite = (Game.getGame().boardScene.childNode(withName: "BoardBackground")!.childNode(withName: character.name) as! SKSpriteNode)
        }
        
        var path = p;
        
        if(path == nil)
        {
            path = self.position?.shortestPathTo(newPos, lastVisited: lastRoomEntered, numTurns: turnsSinceEntered)
        }
        
        var i = 0.0;
        while(!(path?.isEmpty)!){
            let top = path?.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + i*Player.MOVE_DELAY) {
                self.sprite?.run(SKAction.move(to: top!.sprite.position, duration: Player.MOVE_DELAY))
            }
            i += 1;
        }
        
    }
    
    
    func isInRoom() -> Bool
    {
        return (position?.isRoom)!;
        
    }
    
    func chooseToSuspect()
    {
        
    }
    
    func selectPersonWeapon() -> Trio
    {
        return Trio(person: Game.getGame().allPlayers[0].character , weapon: (Game.getGame().roomScene?.weapons![0])!, location: self.position!.room!)
    }
    
    //returns nil if no one has anything
    func ask(_ question: Trio) -> Answer?
    {
        let players = Game.getGame().allPlayers
        let me = players.index(of: self)
        let numPlayers = players.count
        counter = (me! + 1) % numPlayers;
        
        var answer: Card?
        var responder: Player?
        
        while(answer == nil && counter != me)
        {
            
            if(players[counter] is HumanPlayer)
            {
                players[counter].reply(question, p: self) // changes state
                
                counter = counter + 1
                counter = counter % numPlayers
                
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
    
    
    func resumeAsk(_ question: Trio, humanAns: Card?)
    {
        let players = Game.getGame().allPlayers
        let me = players.index(of: self)
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
        
        if(answer == nil)
        {
            let display = (Game.getGame().roomScene?.childNode(withName: "Result"))!
            display.run(SKAction.unhide())
            
            (display.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: "NoAnswer")
            (display.childNode(withName: "Text") as! SKLabelNode).text = "No one had anything!"
        }
        
        takeNotes(result, question: question)
    }
    
    
    func takeNotes(_ answer: Answer, question: Trio)
    {
        
    }
    
    
    func passTurn()
    {
        if(Game.getGame().remainingPlayers.index(of: self) == nil)
        {
            var nextPlayer : Player
            repeat{
                nextPlayer = Game.getGame().allPlayers[(Game.getGame().allPlayers.index(of: self)! + 1)]
            } while (Game.getGame().remainingPlayers.index(of: nextPlayer) == nil);
            Game.getGame().currentPlayer = Game.getGame().remainingPlayers[Game.getGame().remainingPlayers.index(of: nextPlayer)!]
        }else{
            Game.getGame().currentPlayer = Game.getGame().remainingPlayers[(Game.getGame().remainingPlayers.index(of: self)!+1) % Game.getGame().remainingPlayers.count]
        }
        Game.getGame().updatePList()
        
        let root = Game.getGame().boardScene.childNode(withName: "UICONTROLS")!
        let textDisplay = root.childNode(withName: "TextDisplay") as! SKLabelNode
        
        if(Game.getGame().currentPlayer is HumanPlayer)
        {
            Game.getGame().state = State.waitingForDieRoll
            textDisplay.text = "Your turn!"
            Game.getGame().boardScene.childNode(withName: "UICONTROLS")?.childNode(withName: "Die")?.run(SKAction.unhide())
            
        }else{
            Game.getGame().state = State.waitingForTurn
            
            Game.getGame().currentPlayer.play()
            textDisplay.text = Game.getGame().currentPlayer.character.name + "'s turn!"
        }
        
        let glow = Game.getGame().boardScene.childNode(withName: ".//PlayerGlow")!
        glow.parent!.removeChildren(in: [glow])
        if(Game.getGame().currentPlayer.sprite == nil)
        {
        Game.getGame().currentPlayer.sprite = Game.getGame().boardScene.childNode(withName: "BoardBackground")!.childNode(withName: Game.getGame().currentPlayer.character.name) as? SKSpriteNode
        }
        Game.getGame().currentPlayer.sprite!.addChild(glow)
        glow.position = CGPoint(x: 0, y: 0)
        
        Game.getGame().boardScene.highlightCurrentPlayer()
        (Game.getGame().boardScene.childNode(withName: "CurrentPlayer") as! SKSpriteNode).texture = SKTexture(imageNamed: (Game.getGame().currentPlayer.character.imageName))
    }
    
    
    
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.sprite == rhs.sprite && lhs.hand == rhs.hand && lhs.position == rhs.position && rhs.character == rhs.character
}

