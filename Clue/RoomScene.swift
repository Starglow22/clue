//
//  RoomScene.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class RoomScene: SKScene {
    let help = Help()
    
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
        // For mouseover detection
        let options = [NSTrackingAreaOptions.mouseMoved, NSTrackingAreaOptions.activeInKeyWindow] as NSTrackingAreaOptions
        let trackingArea = NSTrackingArea(rect:view.frame,options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
        
        game = Game.getGame()
        help.hide(self)
        game!.noteCard.help.hide(self)
        
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
        self.childNode(withName: "QuestionPanel")?.run(SKAction.move(to: CGPoint(x: 415, y: 540), duration: 0))
        
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
        
        if(game!.allPlayers.count < 6){
            for x in game!.allPlayers.count+1...6
            {
                (playerNameDisplay.childNode(withName: "P\(x)") as! SKLabelNode).text = ""
            }
        }
        
        highlightCurrentPlayer()
        
        //set background to image of correct room
        let room = game?.currentPlayer.position?.room?.imageName
        (game?.roomScene?.childNode(withName: "Background") as! SKSpriteNode).texture = SKTexture(imageNamed: "\(room!)-room")
    }
    
    override func willMove(from view: SKView) {
        for trackingArea in view.trackingAreas {
            view.removeTrackingArea(trackingArea)
        }
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
            return;
        }
        game?.noteCard.clearSelected()
        if(node.parent?.parent?.name == "NoteCard")
        {
            game?.noteCard.selectBox(node as! SKLabelNode)
        }
        
        if(node.name == "Hand")
        {
            hand?.clicked(value: nil)
            return;
        }
        
        if(self.childNode(withName: "Help")!.frame.contains(location) && node.name == "Help") { // self.atPoint uses accumulated bounding rectangle including children but not what I want for help. Fine for other uses.
            help.clicked(self)
            return
        }else if (self.childNode(withName: ".//Notepad-Help")!.frame.contains(location) && node.name == "Notepad-Help"){
            game!.noteCard.help.clicked(self)
            return
        }else if(help.displayed)
        {
            help.hide(self)
            return
        }else if (game!.noteCard.help.displayed){
            game!.noteCard.help.hide(self)
            return
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
                
                self.childNode(withName: "QuestionPanel")?.run(SKAction.move(to: CGPoint(x: 745, y:510), duration: 0)) //y:260
                self.childNode(withName: "QuestionPanel")?.childNode(withName: "None")?.run(SKAction.hide())
                (self.childNode(withName: "QuestionPanel")!.childNode(withName: "Ask") as! SKLabelNode).text = "You asked for:"
                (self.childNode(withName: "QuestionPanel")!.childNode(withName: "Person") as! SKLabelNode).text = person!.name
                (self.childNode(withName: "QuestionPanel")!.childNode(withName: "Weapon") as! SKLabelNode).text = weapon!.name
                (self.childNode(withName: "QuestionPanel")!.childNode(withName: "Location") as! SKLabelNode).text = (game?.currentPlayer.position?.room)!.name
                self.childNode(withName: "QuestionPanel")!.run(SKAction.unhide())
                
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
                    (self.childNode(withName: "Result")?.childNode(withName: "Text") as! SKLabelNode).text = "\(answer!.person!.character.name) proved \(answer!.card!.name) wasn't involved in the murder"
                }
                self.childNode(withName: "Result")?.run(SKAction.unhide())
                
                game?.state = State.waitingForDoneWithNoteTaking
                self.childNode(withName: "Return")?.run(SKAction.unhide())
                game?.noteCard.set(true)
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
                    (self.childNode(withName: "QuestionPanel")!.childNode(withName: "Ask") as! SKLabelNode).text = "You showed \(hand!.getCard(node).name) to \(game!.currentPlayer.character.name)"
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
        game?.noteCard.set(true)
    }
    
    override func keyDown(with theEvent: NSEvent) {
        game?.noteCard.handleKey(theEvent)
    }
    
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        let node = self.atPoint(location)
        
        if (node.name == "SUSPECT" || node.name == "ACCUSE") {
            let text = node as! SKLabelNode
            text.fontSize = 72
        }else{
            (self.childNode(withName: "//SUSPECT") as! SKLabelNode).fontSize = 64 // in whole hieracrhy
            (self.childNode(withName: "//ACCUSE") as! SKLabelNode).fontSize = 64
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
        let SCALE = 1.2
        for i in 0...self.childNode(withName: "Characters")!.children.count-1
        {
            let node = (self.childNode(withName: "Characters")?.childNode(withName: "C"+(i+1).description))!
            if(people![i] != person)
            {
                node.run(SKAction.resize(toWidth: CGFloat(90), height: CGFloat(110), duration: 0.1))
            } else {
                node.run(SKAction.resize(toWidth: CGFloat(90*SCALE), height: CGFloat(110*SCALE), duration: 0.1))
            }
            
        }
        
        for i in 0...self.childNode(withName: "Weapons")!.children.count-1
        {
            let node = (self.childNode(withName: "Weapons")?.childNode(withName: "W"+(i+1).description))!
            if(weapons![i] != weapon)
            {
                node.run(SKAction.resize(toWidth: CGFloat(90), height: CGFloat(110), duration: 0.1))
            } else {
                node.run(SKAction.resize(toWidth: CGFloat(90*SCALE), height: CGFloat(110*SCALE), duration: 0.1))
            }
        }
    }
    
}
