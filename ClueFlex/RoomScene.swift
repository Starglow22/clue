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
    var asker: Player?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        game = Game.getGame()
        
        if(hand == nil)
        {
            hand = Hand(sprite: self.childNodeWithName("Hand") as! SKSpriteNode, cards: (game?.humanPlayer.hand)!)
        }
        
        self.childNodeWithName("Mode")?.runAction(SKAction.unhide())
        self.childNodeWithName("Characters")?.runAction(SKAction.hide())
        self.childNodeWithName("Weapons")?.runAction(SKAction.hide())
        self.childNodeWithName("Done")?.runAction(SKAction.hide())
        self.childNodeWithName("Result")?.runAction(SKAction.hide())
        self.childNodeWithName("Return")?.runAction(SKAction.hide())
        self.childNodeWithName("Answer")?.runAction(SKAction.hide())
        
        (self.childNodeWithName("CurrentPlayer") as! SKSpriteNode).texture = SKTexture(imageNamed: (game?.currentPlayer.character.imageName)!)
        
        for i in 0...self.childNodeWithName("Characters")!.children.count
        {
            let node = (self.childNodeWithName("Characters")?.children)![i]
            let sprite = node as! SKSpriteNode
            sprite.texture = SKTexture(imageNamed: people![i].imageName)
        }
        
        for i in 0...self.childNodeWithName("Weapons")!.children.count
        {
            let node = (self.childNodeWithName("Weapons")?.children)![i]
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
            asker = nil
            
        }else if(game?.state == State.waitingForAnswer){
            hand?.clicked()
            self.childNodeWithName("Mode")?.runAction(SKAction.hide())
            self.childNodeWithName("Answer")?.runAction(SKAction.unhide())
            
            (self.childNodeWithName("Answer")?.childNodeWithName("Ask") as! SKLabelNode).text = (asker?.character.name)! + " asks for:"
            
            (self.childNodeWithName("Answer")?.childNodeWithName("Person") as! SKLabelNode).text = question?.person.name
            (self.childNodeWithName("Answer")?.childNodeWithName("Weapon") as! SKLabelNode).text = question?.weapon.name
            (self.childNodeWithName("Answer")?.childNodeWithName("Location") as! SKLabelNode).text = question?.location.name
        }
        
        // TODO: set background to image of correct room
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
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
                self.childNodeWithName("Mode")?.runAction(SKAction.hide())
                self.childNodeWithName("Characters")?.runAction(SKAction.unhide())
                self.childNodeWithName("Weapons")?.runAction(SKAction.unhide())
                game?.state = State.waitingForQuestion
            }else if (node.name == "ACCUSE"){
                suspect = false
                self.childNodeWithName("Mode")?.runAction(SKAction.hide())
                self.childNodeWithName("Characters")?.runAction(SKAction.unhide())
                self.childNodeWithName("Weapons")?.runAction(SKAction.unhide())
                game?.state = State.waitingForQuestion
            }
            
            
        case State.waitingForQuestion:
            if(node.parent == self.childNodeWithName("Characters"))
            {
             let i = Int((node.name?.substringFromIndex((node.name?.endIndex.predecessor())!))!)
                person = people![i!]
                
            }else if (node.parent == self.childNodeWithName("Weapons")){
                let i = Int((node.name?.substringFromIndex((node.name?.endIndex.predecessor())!))!)
                weapon = weapons![i!]
            }
            
            if(weapon != nil && person != nil)
            {
                self.childNodeWithName("Done")?.runAction(SKAction.unhide())
            }
            
            if(node.name == "Done")
            {
                let question = Trio(person: person!, weapon: weapon!, location: (game?.currentPlayer.position?.room)! )
                answer = game?.currentPlayer.ask(question)
                
                (self.childNodeWithName("Result")?.childNodeWithName("Image") as! SKSpriteNode).texture = SKTexture(imageNamed: (answer!.card?.imageName)!)
                (self.childNodeWithName("Result")?.childNodeWithName("Text") as! SKLabelNode).text = (answer?.person?.character.name)!+"showed you "+(answer?.card?.name)!
                self.childNodeWithName("Result")?.runAction(SKAction.unhide())
                
                game?.state = State.waitingForDoneWithNoteTaking
                self.childNodeWithName("Return")?.runAction(SKAction.unhide())
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
                    
                }
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func switchToBoardView()
    {
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 0.5)
        let nextScene = game?.boardScene
        nextScene?.size = self.size
        nextScene?.scaleMode = .AspectFill
        
        //bring noteCard with you so that it stays the same - can't belong to 2 scenes
        let noteCard = self.childNodeWithName("NoteCard")
        self.removeChildrenInArray([self.childNodeWithName("NoteCard")!])
        nextScene?.addChild(noteCard!)
        
        self.view?.presentScene(nextScene!, transition: reveal)
    }


}
