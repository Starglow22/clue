//
//  File.swift
//  Clue
//
//  Created by Gina Bolognesi on 2016-07-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit


class Game: NSObject {
    // Singleton design pattern
    static var instance: Game?
    
    static func getGame() -> Game{
        return instance!
    }
    
    
    var allPlayers: [Player]
    var remainingPlayers: [Player]
    var currentPlayer: Player
    var humanPlayer: Player
    
    var solution: Trio
    var state: State
    
    var boardScene: BoardScene
    var roomScene: RoomScene?
    var endScene: SKScene?
    
    var roomCards: [Card]?
    
    var noteCard: NoteCard
    
    
    init(players: [Player], s:Trio, scene:BoardScene, human:HumanPlayer)
    {
        self.allPlayers = players
        self.remainingPlayers = players
        currentPlayer = players[Int(arc4random_uniform(UInt32(players.count)))]
        
        solution = s
        state = State.waitingForTurn
        boardScene = scene
        noteCard = NoteCard(sprite: boardScene.childNode(withName: "NoteCard") as! SKSpriteNode)
        humanPlayer = human
        
        //Backdoor to test AI accusing wrong in UI
//        if(allPlayers[0] is HumanPlayer)
//        {
//            (allPlayers[1] as! EasyAIPlayer).roomSoln = s.location
//            (allPlayers[1] as! EasyAIPlayer).weaponSoln = Card(n: "Rope", t: Type.weapon, file: "rope")
//            (allPlayers[1] as! EasyAIPlayer).charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
//        }else{
//            (allPlayers[0] as! EasyAIPlayer).roomSoln = s.location
//            (allPlayers[0] as! EasyAIPlayer).weaponSoln = Card(n: "Rope", t: Type.weapon, file: "rope")
//            (allPlayers[0] as! EasyAIPlayer).charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
//        }
        
        super.init()
        Game.instance = self;
    }
    
    func restart(_ scene: SKScene)
    {
        Game.instance = nil
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
        let nextScene = MenuScene(fileNamed: "MenuScene")
        
        nextScene?.size = scene.size
        nextScene?.scaleMode = .aspectFill
        scene.view?.presentScene(nextScene!, transition: reveal)
    }
    
    func accuse(guess: Trio)
    {
        let result = guess == solution
        let moveToEndScene = result || Game.getGame().currentPlayer is HumanPlayer
        
        let display : SKNode
        
        // If correct, move to new scene, else display on room scene
        if(moveToEndScene)
        {
            let reveal = SKTransition.flipVertical(withDuration: 0.5)
            endScene = SKScene(fileNamed: "EndScene")
            endScene?.size = roomScene!.size
            endScene?.scaleMode = .aspectFill
            endScene!.childNode(withName: "AnswerPanel")!.run(SKAction.hide())
            roomScene?.view?.presentScene(endScene!, transition: reveal)
            
            display = endScene!.childNode(withName: "QuestionPanel")!
        }else{
            display = Game.getGame().roomScene!.childNode(withName: "QuestionPanel")!
        }
        
        if(Game.getGame().currentPlayer is HumanPlayer)
        {
            (display.childNode(withName: "Ask") as! SKLabelNode).text = "You accused:"
        }else{
            (display.childNode(withName: "Ask") as! SKLabelNode).text = (Game.getGame().currentPlayer.character.name) + " accuses!"
        }
        
        (display.childNode(withName: "Person") as! SKLabelNode).text = guess.person.name
        (display.childNode(withName: "Weapon") as! SKLabelNode).text = guess.weapon.name
        (display.childNode(withName: "Location") as! SKLabelNode).text = guess.location.name
        
        // end game: if human or last player; display real soln, else remove player, display guess
        if(moveToEndScene)
        {
            if(Game.getGame().currentPlayer is HumanPlayer)
            {
                if(result)
                {
                    (display.childNode(withName: "Result") as! SKLabelNode).text = "You won!"
                    (endScene!.childNode(withName: "Bkg")! as! SKSpriteNode).color = SKColor.init(red: 0, green: 142, blue: 0, alpha: 1)
                    
                }else{
                    (display.childNode(withName: "Result") as! SKLabelNode).text = "Game over."
                    (endScene!.childNode(withName: "Bkg")! as! SKSpriteNode).color = SKColor.init(red: 148, green: 17, blue: 0, alpha: 1)
                    
                    showAnswer(display)
                }
                
            }else {
                display.run(SKAction.unhide())
                (display.childNode(withName: "Result") as! SKLabelNode).text = "Game over. " + Game.getGame().currentPlayer.character.name + " won."
            }
            (endScene as! EndScene).setBackground()
        }else{
            (display.childNode(withName: "Accuse") as! SKLabelNode).text = "Unfortunately, it was wrong!"
            display.childNode(withName: "Accuse")?.run(SKAction.unhide())
            
            display.run(SKAction.unhide())
            
            Game.getGame().remainingPlayers.remove(at: Game.getGame().remainingPlayers.index(of: Game.getGame().currentPlayer)!)
            
            returnToStart(Game.getGame().currentPlayer)
            
            Game.getGame().state = State.waitingForDoneWithNoteTaking
            Game.getGame().roomScene?.updateState()
        }
        
    }
    
    private func returnToStart(_ p : Player)
    {
        let scene = Game.getGame().boardScene
        
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
        
        p.moveToken(newPos: p.position!, p: [p.position!])
    }
    
    private func showAnswer(_ display: SKNode)
    {
        let answer = display.scene!.childNode(withName: "AnswerPanel")!
        answer.run(SKAction.unhide())
        
        (answer.childNode(withName: "Person") as! SKLabelNode).text = solution.person.name
        (answer.childNode(withName: "Weapon") as! SKLabelNode).text = solution.weapon.name
        (answer.childNode(withName: "Location") as! SKLabelNode).text = solution.location.name
    }
    
    func updatePList()
    {
        boardScene.highlightCurrentPlayer()
    }
    
    func moveToBoardView()
    {
        roomScene?.switchToBoardView()
    }
    
    func moveToRoomView()
    {
        boardScene.switchToRoomView()
    }
    
}
