//
//  GameScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-10.
//  Copyright (c) 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let help = Help()
    var lastClicked: SKNode?
    
    var numPlayers = 0
    var difficulty = 0
    var characterName = ""
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        help.hide(self)
        
        for child in self.children
        {
            if(child.name != "Help")
            {
                child.alpha = 0.0;
            }
        }
        
        self.childNode(withName: "Start")?.run(SKAction.hide())
        
        fadePlayerIcons()
        resizeCharacterIcons()
        
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.location(in: self)
        let node = self.atPoint(location)
        
        if(self.childNode(withName: "Help")!.frame.contains(location)) { // self.atPoint uses accumulated bounding rectangle including children but not what I want for help. Fine for other uses.
            help.clicked(self)
        }else if(help.displayed)
        {
            help.hide(self)
        }
        
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
                characterName = "Miss Scarlett"
                
            case "C2"?:
                selectCharacter(node)
                characterName = "Mrs Peacock"
                
            case "C3"?:
                selectCharacter(node)
                characterName = "Mr Green"
                
            case "C4"?:
                selectCharacter(node)
                characterName = "Col. Mustard"
                
            case "C5"?:
                selectCharacter(node)
                characterName = "Prof. Plum"
                
            case "C6"?:
                selectCharacter(node)
                characterName = "Mrs White"
                
            case "Start"?:
                let nextScene = BoardScene(fileNamed: "BoardScene")
                nextScene?.size = self.size
                nextScene?.scaleMode = .aspectFill
                nextScene?.setUpTiles()
                
                let gameObj = initialize(scene: nextScene!)
                gameObj.boardScene = nextScene!
                nextScene?.game = gameObj
                nextScene?.setUpTiles()
                
                let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                
                self.view?.presentScene(nextScene!, transition: reveal)
                
                
                for player in gameObj.allPlayers
                {
                    switch player.character.name
                    {
                    case "Miss Scarlett":
                        player.position = nextScene?.board["scarlett start"]
                    case "Prof. Plum":
                        player.position = nextScene?.board["plum start"]
                    case "Mrs Peacock":
                        player.position = nextScene?.board["peacock start"]
                    case "Mr Green":
                        player.position = nextScene?.board["green start"]
                    case "Col. Mustard":
                        player.position = nextScene?.board["mustard start"]
                    default:
                        player.position = nextScene?.board["white start"]
                    }
                }
                
                if(!(gameObj.currentPlayer is HumanPlayer))
                {
                    gameObj.currentPlayer.play()
                }
                
                
            default: break
                // do nothing
            }
            
        }
        lastClicked = node
        
        if(numPlayers != 0 && difficulty != 0 && characterName != "" && self.childNode(withName: "Start")?.isHidden == true)
        {
            self.childNode(withName: "Start")?.run(SKAction.unhide())
        }
        
    }
    
    func selectCharacter(_ node: SKNode)
    {
        resizeCharacterIcons()
        node.run(SKAction.scale(to: 1.4, duration: 0.1))
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
    
    func selectNode(_ node: SKNode)
    {
        fadePlayerIcons()
        node.run(SKAction.colorize(with: NSColor.red, colorBlendFactor: 0.5, duration: 0.1))
    }
    
    func fadePlayerIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("P") == true)
            {
                node.run(SKAction.colorize(with: NSColor.clear, colorBlendFactor: 0.5, duration: 0.1))
            }
            
        }
    }
    
    func resizeCharacterIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("C") == true)
            {
                node.run(SKAction.scale(to: 1.0, duration: 0.1))
            }
            
        }
    }
    
    func initialize(scene: BoardScene) -> Game
    {
        let p1 = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        let p2 = Card(n: "Prof. Plum", t: Type.character, file: "plum")
        let p3 = Card(n: "Mrs Peacock", t: Type.character, file: "peacock")
        let p4 = Card(n: "Mr Green", t: Type.character, file: "green")
        let p5 = Card(n: "Col. Mustard", t: Type.character, file: "mustard")
        let p6 = Card(n: "Mrs White", t: Type.character, file: "white")
        
        let w1 = Card(n: "Candlestick", t: Type.weapon, file: "candlestick")
        let w2 = Card(n: "Knife", t: Type.weapon, file: "knife")
        let w3 = Card(n: "Lead Pipe", t: Type.weapon, file: "leadpipe")
        let w4 = Card(n: "Revolver", t: Type.weapon, file: "revolver")
        let w5 = Card(n: "Rope", t: Type.weapon, file: "rope")
        let w6 = Card(n: "Wrench", t: Type.weapon, file: "wrench")
        
        let r1 = Card(n: "Kitchen", t: Type.location, file: "kitchen")
        let r2 = Card(n: "Ballroom", t: Type.location, file: "ballroom")
        let r3 = Card(n: "Conservatory", t: Type.location, file: "conservatory")
        let r4 = Card(n: "Dining room", t: Type.location, file: "dining")
        let r5 = Card(n: "Billard", t: Type.location, file: "billard")
        let r6 = Card(n: "Library", t: Type.location, file: "library")
        let r7 = Card(n: "Lounge", t: Type.location, file: "lounge")
        let r8 = Card(n: "Hall", t: Type.location, file: "hall")
        let r9 = Card(n: "Study", t: Type.location, file: "study")
        
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
        cards.remove(at: cards.index(of: chosenP)!)
        cards.remove(at: cards.index(of: chosenW)!)
        cards.remove(at: cards.index(of: chosenR)!)
        
        var availableChars = people+[]
        
        var players = [Player]()
        
        //initialize players with a character card attached
        players.append(HumanPlayer(c: availableChars[availableChars.index(where: {$0.name == characterName})!]))
        availableChars.remove(at: availableChars.index(where: {$0.name == characterName})!)
        
        //        let numHard = (difficulty + 10%numPlayers) / Int(floor(10.0 / Double(numPlayers)))
        //        let numTrick = (difficulty + 10%numPlayers)-1 % Int(floor(10.0 / Double(numPlayers)))
        let numHard = Int(floor(Double(difficulty * numPlayers)/10.0))
        let numTrick = (Double(difficulty * numPlayers)/10.0).truncatingRemainder(dividingBy: 1.0) > 0.5 ? 1 : 0
        let numEasy = numPlayers - numHard - numTrick
        
        var AIPlayers = [Player]()
        
        if(numHard > 0){
            for _ in 1...numHard{
                // choose a token at random
                let i = arc4random_uniform(UInt32(availableChars.count))
                
                //instantiate and remove token from options
                AIPlayers.append(HardAIPlayer(c: availableChars[Int(i)]))
                availableChars.remove(at: Int(i))
                
            }
        }
        
        //cannot have for loop where end < start
        if(numTrick > 0){
            for _ in 1...numTrick{
                // choose a token at random
                let i = arc4random_uniform(UInt32(availableChars.count))
                
                //instantiate and remove token from options
                AIPlayers.append(TricksterAIPlayer(c: availableChars[Int(i)]))
                availableChars.remove(at: Int(i))
                
            }
        }
        if(numEasy > 0){
            for _ in 1...numEasy{
                // choose a token at random
                let i = arc4random_uniform(UInt32(availableChars.count))
                
                //instantiate and remove token from options
                AIPlayers.append(EasyAIPlayer(c: availableChars[Int(i)]))
                availableChars.remove(at: Int(i))
                
            }
        }
        
        while (AIPlayers.count > 0){
            // choose a token at random
            let i = arc4random_uniform(UInt32(AIPlayers.count))
            
            //instantiate and remove token from options
            players.append(AIPlayers[Int(i)])
            AIPlayers.remove(at: Int(i))
            
        }
        
        //distribute cards between players
        while cards.count > 0{
            for i in 0...players.count-1{
                if(cards.count>0)
                {
                    let x = arc4random_uniform(UInt32(cards.count))
                    players[i].hand.append(cards.remove(at: Int(x)))
                }
            }
        }
        
        for p in 1...players.count-1{
            (players[p] as! EasyAIPlayer).markHandCards()
        }
        
        let game = Game(players: players, s: solution, scene: scene, human:players[0] as! HumanPlayer)
        game.roomCards = rooms
        
        
        //init roomscene for game
        let roomScene = RoomScene(fileNamed: "RoomScene")
        roomScene?.size = self.size
        roomScene?.scaleMode = .aspectFill
        
        
        roomScene?.people = people
        roomScene?.weapons = weapons
        roomScene?.rooms = rooms
        game.roomScene = roomScene
        
        game.currentPlayer = game.allPlayers[Int(arc4random_uniform(UInt32(game.allPlayers.count)))]
        
        
        //assigng start positions at all players
        for p in Game.getGame().allPlayers{
            p.sprite = (scene.childNode(withName: "BoardBackground")!.childNode(withName: p.character.name) as! SKSpriteNode)
            
            switch p.character.name {
            case "Miss Scarlett":
                p.position = scene.board["scarlett start"]!
            case "Prof. Plum":
                p.position = scene.board["plum start"]!
            case "Mrs Peacock":
                p.position = scene.board["peacock start"]!
            case "Mr Green":
                p.position = scene.board["green start"]!
            case "Col. Mustard":
                p.position = scene.board["mustard start"]!
            case "Mrs White":
                p.position = scene.board["white start"]!
                
            default: break
                
            }
        }
        
        if(game.currentPlayer is HumanPlayer)
        {
            game.state = State.startOfTurn
        }else{
            game.state = State.waitingForTurn
        }
        
        return game
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
