//
//  GameScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-10.
//  Copyright (c) 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var lastClicked: SKNode?
    
    var numPlayers = 0
    var difficulty = 0
    var characterName = ""
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        for child in self.children
        {
            child.alpha = 0.0;
        }
        
        self.childNodeWithName("Start")?.runAction(SKAction.hide())
        
        
        fadePlayerIcons()
        resizeCharacterIcons()
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if(lastClicked != node)
        {
            switch node.name {
            case "P2"?:
                selectNode(node)
                numPlayers = 2
                
            case "P3"?:
                selectNode(node)
                numPlayers = 3
                
            case "P4"?:
                selectNode(node)
                numPlayers = 4
                
            case "P5"?:
                selectNode(node)
                numPlayers = 5
                
            case "D1"?, "D2"?, "D3"?, "D4"?, "D5"?, "D6"?, "D7"?, "D8"?, "D9"?, "D10"?:
                resetNumbers()
                let label = node as? SKLabelNode
                label?.fontSize = 64
                difficulty = ((label?.text)! as NSString).integerValue
                
            case "C1"?:
                selectCharacter(node)
                characterName = "Miss Scarlet"
                
            case "C2"?:
                selectCharacter(node)
                characterName = "Mrs Peacock"
                
            case "C3"?:
                selectCharacter(node)
                characterName = "Mr Green"
                
            case "C4"?:
                selectCharacter(node)
                characterName = "Colonel Mustard"
                
            case "C5"?:
                selectCharacter(node)
                characterName = "Prof. Plum"
                
            case "C6"?:
                selectCharacter(node)
                characterName = "Mrs White"
                
            case "Start"?:
                let gameObj = initialize()
                let reveal = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                
                
                let nextScene = BoardScene(fileNamed: "BoardScene")
                nextScene?.size = self.size
                nextScene?.scaleMode = .AspectFill
                self.view?.presentScene(nextScene!, transition: reveal)
                
                nextScene?.game = gameObj
                nextScene?.setUpTiles()
                gameObj.boardScene = nextScene
                
                
            default: break
                // do nothing
            }
            
        }
        lastClicked = node
        
        if(numPlayers != 0 && difficulty != 0 && characterName != "" && self.childNodeWithName("Start")?.hidden == true)
        {
            self.childNodeWithName("Start")?.runAction(SKAction.unhide())
        }
        
    }
    
    func moveToBoardScene(){
        numPlayers = 3
        difficulty = 3
        characterName = "Mrs White"
        
        let gameObj = initialize()
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(0.5)
        
        
        let nextScene = BoardScene(fileNamed: "BoardScene")
        nextScene?.size = self.size
        nextScene?.scaleMode = .AspectFill
        self.view?.presentScene(nextScene!, transition: reveal)
        
        nextScene?.game = gameObj
        nextScene?.setUpTiles()
        gameObj.boardScene = nextScene
        
    }
    
    
    func selectCharacter(node: SKNode)
    {
        resizeCharacterIcons()
        node.runAction(SKAction.scaleTo(1.4, duration: 0.1))
    }
    
    func resetNumbers()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("D") == true)
            {
                let label = node as? SKLabelNode
                label?.fontSize = 32
            }
            
        }
    }
    
    func selectNode(node: SKNode)
    {
        fadePlayerIcons()
        node.runAction(SKAction.colorizeWithColor(NSColor.redColor(), colorBlendFactor: 0.5, duration: 0.1))
    }
    
    func fadePlayerIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("P") == true)
            {
                node.runAction(SKAction.colorizeWithColor(NSColor.clearColor(), colorBlendFactor: 0.5, duration: 0.1))
            }
            
        }
    }
    
    func resizeCharacterIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("C") == true)
            {
                node.runAction(SKAction.scaleTo(1.0, duration: 0.1))
            }
            
        }
    }
    
    func initialize() -> Game
    {
        let p1 = Card(n: "Miss Scarlet", t: Type.CHARACTER, file: "scarlet.jpg")
        let p2 = Card(n: "Prof. Plum", t: Type.CHARACTER, file: "plum.jpg")
        let p3 = Card(n: "Mrs Peacock", t: Type.CHARACTER, file: "peacock.jpg")
        let p4 = Card(n: "Mr Green", t: Type.CHARACTER, file: "green.jpg")
        let p5 = Card(n: "Colonel Mustard", t: Type.CHARACTER, file: "mustard.jpg")
        let p6 = Card(n: "Mrs White", t: Type.CHARACTER, file: "white.jpg")
        
        let w1 = Card(n: "Candlestick", t: Type.WEAPON, file: "candlestick.jpg")
        let w2 = Card(n: "Knife", t: Type.WEAPON, file: "knife.jpg")
        let w3 = Card(n: "Lead Pipe", t: Type.WEAPON, file: "leadpipe.jpg")
        let w4 = Card(n: "Revolver", t: Type.WEAPON, file: "revolver.jpg")
        let w5 = Card(n: "Rope", t: Type.WEAPON, file: "rope.jpg")
        let w6 = Card(n: "Wrench", t: Type.WEAPON, file: "wrench.jpg")
        
        let r1 = Card(n: "Kitchen", t: Type.LOCATION, file: "kitchen.jpg")
        let r2 = Card(n: "Ballroom", t: Type.LOCATION, file: "ballroom.jpg")
        let r3 = Card(n: "Conservatory", t: Type.LOCATION, file: "conservatory.jpg")
        let r4 = Card(n: "Dining room", t: Type.LOCATION, file: "dining.jpg")
        let r5 = Card(n: "Billard", t: Type.LOCATION, file: "billard.jpg")
        let r6 = Card(n: "Library", t: Type.LOCATION, file: "library.jpg")
        let r7 = Card(n: "Lounge", t: Type.LOCATION, file: "lounge.jpg")
        let r8 = Card(n: "Hall", t: Type.LOCATION, file: "hall.jpg")
        let r9 = Card(n: "Study", t: Type.LOCATION, file: "study.jpg")
        
        let people = [p1, p2, p3, p4, p5, p6]
        let weapons = [w1, w2, w3, w4, w5, w6]
        let rooms = [r1, r2, r3, r4, r5, r6, r7, r8, r9]
        
        
        // pick solution
        let chosenP = people[Int(arc4random_uniform(6))]
        let chosenW = weapons[Int(arc4random_uniform(6))]
        let chosenR = rooms[Int(arc4random_uniform(9))]
        
        let solution = Trio(person: chosenP, weapon: chosenW, location: chosenR)
        
        //take solution cards out of deck
        var cards = people + weapons + rooms
        cards.removeAtIndex(cards.indexOf(chosenP)!)
        cards.removeAtIndex(cards.indexOf(chosenW)!)
        cards.removeAtIndex(cards.indexOf(chosenR)!)
        
        var availableChars = people+[]
        
        var players = [Player]()
        
        //initialize players with a character card attached
        players.append(HumanPlayer(c: availableChars[availableChars.indexOf({$0.name == characterName})!]))
        availableChars.removeAtIndex(availableChars.indexOf({$0.name == characterName})!)
        
        let numHard = (difficulty + 10%numPlayers) / Int(ceil(10.0 / Double(numPlayers)))
        let numTrick = (difficulty + 10%numPlayers) % Int(ceil(10.0 / Double(numPlayers)))
        let numEasy = numPlayers - numHard - numTrick
        
        var AIPlayers = [Player]()
        
        for _ in 1...numHard{
            // choose a token at random
            let i = arc4random_uniform(UInt32(availableChars.count))
            
            //instantiate and remove token from options
            AIPlayers.append(HardAIPlayer(c: availableChars[Int(i)]))
            availableChars.removeAtIndex(Int(i))
            
        }
        
        //cannot have for loop where end < start
        if(numTrick > 0){
            for _ in 1...numTrick{
                // choose a token at random
                let i = arc4random_uniform(UInt32(availableChars.count))
                
                //instantiate and remove token from options
                AIPlayers.append(TricksterAIPlayer(c: availableChars[Int(i)]))
                availableChars.removeAtIndex(Int(i))
                
            }
        }
        if(numTrick > 0){
            for _ in 1...numEasy{
                // choose a token at random
                let i = arc4random_uniform(UInt32(availableChars.count))
                
                //instantiate and remove token from options
                AIPlayers.append(EasyAIPlayer(c: availableChars[Int(i)]))
                availableChars.removeAtIndex(Int(i))
                
            }
        }
        
        while (AIPlayers.count > 0){
            // choose a token at random
            let i = arc4random_uniform(UInt32(AIPlayers.count))
            
            //instantiate and remove token from options
            players.append(AIPlayers[Int(i)])
            AIPlayers.removeAtIndex(Int(i))
            
        }
        
        //distribute cards between players
        while cards.count > 0{
            for i in 1...players.count-1{
                if(cards.count>0)
                {
                    let x = arc4random_uniform(UInt32(cards.count))
                    players[i].hand.append(cards.removeAtIndex(Int(x)))
                }
            }
        }
        
        let game = Game(players: players, s: solution)
        game.roomCards = rooms
        
        
        //init roomscene for game
        let roomScene = RoomScene(fileNamed: "RoomScene")
        roomScene?.size = self.size
        roomScene?.scaleMode = .AspectFill
        
        roomScene?.people = people
        roomScene?.weapons = weapons
        roomScene?.rooms = rooms
        game.roomScene = roomScene
        
        return game
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
    }
}
