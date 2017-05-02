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
            hand = Hand(sprite: self.childNode(withName: "Hand") as! SKSpriteNode, cards: (game?.humanPlayer.hand)!, isBoard: false)
        }
        
        self.childNode(withName: "Mode")?.run(SKAction.hide())
        self.childNode(withName: "Characters")?.run(SKAction.hide())
        self.childNode(withName: "Weapons")?.run(SKAction.hide())
        self.childNode(withName: "Done")?.run(SKAction.hide())
        self.childNode(withName: "Result")?.run(SKAction.hide())
        self.childNode(withName: "Return")?.run(SKAction.hide())
        self.childNode(withName: "QuestionPanel")?.run(SKAction.hide())
        
        self.childNode(withName: "Result")?.run(SKAction.moveTo(y: CGFloat(260), duration: 0))
        
        (self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")?.childNode(withName: "None") as! SKLabelNode).text = "I have none"
        self.childNode(withName: "QuestionPanel")?.childNode(withName: "Accuse")?.run(SKAction.hide())
        
        (self.childNode(withName: "Result")?.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: "cardBack")
        
        if(game?.state == State.waitingForDoneWithNoteTaking)
        {
            self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")?.run(SKAction.hide())
        }
        
        
        (self.childNode(withName: "CurrentPlayer") as! SKSpriteNode).texture = SKTexture(imageNamed: (game?.currentPlayer.character.imageName)!)
        
        for i in 0...self.childNode(withName: "Characters")!.children.count-1
        {
            let node = (self.childNode(withName: "Characters")?.childNode(withName: "C"+(i+1).description))!
            let sprite = node as! SKSpriteNode
            sprite.texture = SKTexture(imageNamed: people![i].imageName)
        }
        
        for i in 0...self.childNode(withName: "Weapons")!.children.count-1
        {
            let node = (self.childNode(withName: "Weapons")?.childNode(withName: "W"+(i+1).description))!
            let sprite = node as! SKSpriteNode
            sprite.texture = SKTexture(imageNamed: weapons![i].imageName)
        }
        
        person = nil
        weapon = nil
        suspect = nil
        answer = nil
        
        updateState();
        resizeCardIcons();
        
        game = Game.getGame()
        let playerNameDisplay = self.childNode(withName: "PlayersList")!
        
        let i = game!.allPlayers.index(of: game!.currentPlayer)!
        
        for x in 1...game!.allPlayers.count
        {
            if(game?.allPlayers[(i+x-1)%game!.allPlayers.count] is HumanPlayer)
            {
                (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text = "You (" +
                    (game?.allPlayers[(i+x-1)%game!.allPlayers.count].character.name)! + ")"
            }else{
                (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text = game?.allPlayers[(i+x-1)%game!.allPlayers.count].character.name
            }
        }
        
        for x in game!.allPlayers.count+1...6
        {
            (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text = ""
        }
        
        highlightCurrentPlayer()
        
        // TODO: set background to image of correct room
    }
    
    public func updateState(){
        if(game?.state == State.waitingForSuspectOrAccuse)
        {
            question = nil
            hand?.clicked(value: true)
            self.childNode(withName: "Mode")?.run(SKAction.unhide())
        }else if(game?.state == State.waitingForAnswer){
            hand?.clicked(value: true)
            self.childNode(withName: "Return")?.run(SKAction.hide())
            self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")?.run(SKAction.unhide())
            self.childNode(withName: "QuestionPanel")?.run(SKAction.unhide())
        }else if(game?.state == State.waitingForDoneWithNoteTaking){
            self.childNode(withName: "Return")?.run(SKAction.unhide())
            hand?.clicked(value: false)
        }
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
        
        if(node.name == "Hand")
        {
            hand?.clicked(value: nil)
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
             let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)! - 1
                person = people![i]
                
            }else if (node.parent == self.childNode(withName: "Weapons")){
                let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)! - 1
                weapon = weapons![i]
            }
            
            if(weapon != nil && person != nil)
            {
                self.childNode(withName: "Done")?.run(SKAction.unhide())
            }
            
            if(node.name == "Done")
            {
                
                self.childNode(withName: "Characters")?.run(SKAction.hide())
                self.childNode(withName: "Weapons")?.run(SKAction.hide())
                self.childNode(withName: "Done")?.run(SKAction.hide())
                
                self.childNode(withName: "Result")?.run(SKAction.moveTo(y: CGFloat(545), duration: 0))
                
                let question = Trio(person: person!, weapon: weapon!, location: (game?.currentPlayer.position?.room)! )
                answer = game?.currentPlayer.ask(question)
                
                if(!suspect!)
                {
                    game?.accuse(guess: question)
                    return;
                }
                
                if(answer?.card == nil)
                {
                    (self.childNode(withName: "Result")?.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: "NoAnswer")
                    (self.childNode(withName: "Result")?.childNode(withName: "Text") as! SKLabelNode).text = "No one had anything!"
                }else{
                    (self.childNode(withName: "Result")?.childNode(withName: "Image") as! SKSpriteNode).texture = SKTexture(imageNamed: (answer!.card?.imageName)!)
                    (self.childNode(withName: "Result")?.childNode(withName: "Text") as! SKLabelNode).text = (answer?.person?.character.name)!+" showed you "+(answer?.card?.name)!
                }
                self.childNode(withName: "Result")?.run(SKAction.unhide())
                
                game?.state = State.waitingForDoneWithNoteTaking
                self.childNode(withName: "Return")?.run(SKAction.unhide())
            }
            
            resizeCardIcons();
            
        case State.waitingForDoneWithNoteTaking:
            if(node.name == "Return")
            {
                game?.state = State.waitingForTurn
                game?.currentPlayer.passTurn()
                switchToBoardView()
            }
            
        case State.waitingForAnswer:
            if(node.parent?.name == "Hand")
            {
                if (question!.contains((hand?.getCard(node))!))
                {
                    doAnswer()
                    game?.currentPlayer.resumeAsk(question!, humanAns: hand?.getCard(node))
                }
            }
            
            if(node.name == "None")
            {
                if(hand!.cards.contains(question!.person) || hand!.cards.contains(question!.weapon) || hand!.cards.contains(question!.location))
                {
                    (self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")?.childNode(withName: "None") as! SKLabelNode).text = "Are you sure?"
                }else{
                    doAnswer()
                    game?.currentPlayer.resumeAsk(question!, humanAns: nil)
                }
            }
        default:
            break; // exhaustive switch
        }
    }
    
    private func doAnswer()
    {
        game!.state = State.waitingForDoneWithNoteTaking
        updateState()
        self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")!.run(SKAction.hide())
        self.childNode(withName: "Return")?.run(SKAction.unhide())
        let textDisplay = self.childNode(withName: "QuestionPanel")!.childNode(withName: "Ask") as! SKLabelNode
        textDisplay.text = textDisplay.text?.replacingOccurrences(of: "asks", with: "asked");
    }
    
    override func keyDown(with theEvent: NSEvent) {
        game?.noteCard.handleKey(theEvent)
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

    func highlightCurrentPlayer()
    {
        
        let playerNameDisplay = self.childNode(withName: "PlayersList")!
        
        for x in 1...game!.allPlayers.count
        {
            if((playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text == game?.currentPlayer.character.name
                || (game?.currentPlayer is HumanPlayer && ((playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text?.contains("You"))!))
            {
                (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).fontSize = 36
            }else{
                (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).fontSize = 24
            }
        }
    }
    
    
    func resizeCardIcons()
    {
        for i in 0...self.childNode(withName: "Characters")!.children.count-1
        {
            let node = (self.childNode(withName: "Characters")?.childNode(withName: "C"+(i+1).description))!
            if(people![i] != person)
            {
                node.run(SKAction.resize(toWidth: CGFloat(90), height: CGFloat(110), duration: 0.1))
            } else {
                node.run(SKAction.resize(toWidth: CGFloat(100), height: CGFloat(120), duration: 0.1))
            }
            
        }
        
        for i in 0...self.childNode(withName: "Weapons")!.children.count-1
        {
            let node = (self.childNode(withName: "Weapons")?.childNode(withName: "W"+(i+1).description))!
            if(weapons![i] != weapon)
            {
                node.run(SKAction.resize(toWidth: CGFloat(90), height: CGFloat(110), duration: 0.1))
            } else {
                node.run(SKAction.resize(toWidth: CGFloat(100), height: CGFloat(120), duration: 0.1))
            }
            
        }
    }

}
