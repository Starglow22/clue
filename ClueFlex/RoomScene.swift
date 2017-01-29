//
//  RoomScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class RoomScene: SKScene {
    var game : Game?
    var hand: Hand?
    
    var people: [Card]?
    var weapons: [Card]?
    var rooms: [Card]?
    
    var suspect: Bool?
    var person: Card?
    var weapon: Card?
    
    var answer: Answer?
    var question: Trio?
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        game = Game.getGame()
        
        if(hand == nil)
        {
            hand = Hand(sprite: self.childNode(withName: "Hand") as! SKSpriteNode, cards: (game?.humanPlayer.hand)!)
        }
        
        self.childNode(withName: "Mode")?.run(SKAction.unhide())
        self.childNode(withName: "Characters")?.run(SKAction.hide())
        self.childNode(withName: "Weapons")?.run(SKAction.hide())
        self.childNode(withName: "Done")?.run(SKAction.hide())
        self.childNode(withName: "Result")?.run(SKAction.hide())
        self.childNode(withName: "Return")?.run(SKAction.hide())
        self.childNode(withName: "Answer")?.run(SKAction.hide())
        
        (self.childNode(withName: "CurrentPlayer") as! SKSpriteNode).texture = SKTexture(imageNamed: (game?.currentPlayer.character.imageName)!)
        
        for i in 0...self.childNode(withName: "Characters")!.children.count-1
        {
            let node = (self.childNode(withName: "Characters")?.children)![i]
            let sprite = node as! SKSpriteNode
            sprite.texture = SKTexture(imageNamed: people![i].imageName)
        }
        
        for i in 0...self.childNode(withName: "Weapons")!.children.count-1
        {
            let node = (self.childNode(withName: "Weapons")?.children)![i]
            let sprite = node as! SKSpriteNode
            sprite.texture = SKTexture(imageNamed: people![i].imageName)
        }
        
        person = nil
        weapon = nil
        suspect = nil
        answer = nil
        if(game?.state == State.waitingForSuspectOrAccuse)
        {
            question = nil
            
        }else if(game?.state == State.waitingForAnswer){
            hand?.clicked()
            self.childNode(withName: "Mode")?.run(SKAction.hide())
            self.childNode(withName: "Answer")?.run(SKAction.unhide())
            
            (self.childNode(withName: "Answer")?.childNode(withName: "Ask") as! SKLabelNode).text = (Game.getGame().currentPlayer.character.name) + " asks for:"
            
            (self.childNode(withName: "Answer")?.childNode(withName: "Person") as! SKLabelNode).text = question?.person.name
            (self.childNode(withName: "Answer")?.childNode(withName: "Weapon") as! SKLabelNode).text = question?.weapon.name
            (self.childNode(withName: "Answer")?.childNode(withName: "Location") as! SKLabelNode).text = question?.location.name
        }
        
        // TODO: set background to image of correct room
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.location(in: self)
        let node = self.atPoint(location)
        
        // allow notecard to be interacted with regardless of state
        if(node.name == "NoteCard")
        {
            game?.noteCard.clicked()
        }
        game?.noteCard.clearSelected()
        if(node.parent?.parent?.name == "NoteCard")
        {
            game?.noteCard.selectBox(node as! SKLabelNode)
        }
        
        if(node.name == "hand")
        {
            hand?.clicked()
        }
        
        
        switch game!.state {
        case State.waitingForSuspectOrAccuse:
            if(node.name == "SUSPECT")
            {
                suspect = true
                game?.currentPlayer.suspect = true
                self.childNode(withName: "Mode")?.run(SKAction.hide())
                self.childNode(withName: "Characters")?.run(SKAction.unhide())
                self.childNode(withName: "Weapons")?.run(SKAction.unhide())
                game?.state = State.waitingForQuestion
            }else if (node.name == "ACCUSE"){
                suspect = false
                game?.currentPlayer.suspect = false
                self.childNode(withName: "Mode")?.run(SKAction.hide())
                self.childNode(withName: "Characters")?.run(SKAction.unhide())
                self.childNode(withName: "Weapons")?.run(SKAction.unhide())
                game?.state = State.waitingForQuestion
            }
            
            
        case State.waitingForQuestion:
            if(node.parent == self.childNode(withName: "Characters"))
            {
             let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)
                person = people![i!]
                
            }else if (node.parent == self.childNode(withName: "Weapons")){
                let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)
                weapon = weapons![i!]
            }
            
            if(weapon != nil && person != nil)
            {
                self.childNode(withName: "Done")?.run(SKAction.unhide())
            }
            
            if(node.name == "Done")
            {
                let question = Trio(person: person!, weapon: weapon!, location: (game?.currentPlayer.position?.room)! )
                answer = game?.currentPlayer.ask(question)
                
                if(answer?.card == nil)
                {
                    (self.childNode(withName: "Result")?.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: "NoAnswer")
                    (self.childNode(withName: "Result")?.childNode(withName: "Text") as! SKLabelNode).text = "No one had anything!"
                }else{
                    (self.childNode(withName: "Result")?.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: (answer!.card?.imageName)!)
                    (self.childNode(withName: "Result")?.childNode(withName: "Text") as! SKLabelNode).text = (answer?.person?.character.name)!+"showed you "+(answer?.card?.name)!
                }
                self.childNode(withName: "Result")?.run(SKAction.unhide())
                
                game?.state = State.waitingForDoneWithNoteTaking
                self.childNode(withName: "Return")?.run(SKAction.unhide())
            }
            
        case State.waitingForDoneWithNoteTaking:
            if(node.name == "Return")
            {
                switchToBoardView()
                game?.currentPlayer.passTurn()
                game?.state = State.waitingForTurn
            }
            
        case State.waitingForAnswer:
            if(node.parent?.name == "Hand")
            {
                if (question!.contains((hand?.getCard(node))!))
                {
                    game?.currentPlayer.resumeAsk(question!, humanAns: hand?.getCard(node))
                }
            }
            
            if(node.name == "None")
            {
                if(hand!.cards.contains(question!.person) || hand!.cards.contains(question!.weapon) || hand!.cards.contains(question!.location))
                {
                    (self.childNode(withName: "Ask")?.childNode(withName: "None")?.childNode(withName: "None") as! SKLabelNode).text = "Are you sure?"
                }else{
                    game?.currentPlayer.resumeAsk(question!, humanAns: nil)
                }
            }
        default:
            break; // exhaustive switch
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func switchToBoardView()
    {
        let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 0.5)
        let nextScene = game?.boardScene
        nextScene?.size = self.size
        nextScene?.scaleMode = .aspectFill
        
        //bring noteCard with you so that it stays the same - can't belong to 2 scenes
        let noteCard = self.childNode(withName: "NoteCard")
        self.removeChildren(in: [self.childNode(withName: "NoteCard")!])
        nextScene?.addChild(noteCard!)
        
        self.view?.presentScene(nextScene!, transition: reveal)
    }


}
