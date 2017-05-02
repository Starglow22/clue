//
//  testAccuse.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2017-04-14.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
import SpriteKit
@testable import ClueFlex

class testAccuse: XCTestCase {
    
    var player : EasyAIPlayer?
    
    var people : [Card]?
    var weapons : [Card]?
    var rooms : [Card]?

    func testAccuseCorrectly() {
        
        let game = Game.getGame()
        player?.roomSoln = rooms![2]
        player?.weaponSoln = weapons![2]
        player?.charSoln = people![2]
        
        game.endScene = nil
        
        game.solution = Trio(person: people![2], weapon: weapons![2], location: rooms![2])
        
        player?.chooseToSuspect()
        game.accuse(guess: player!.selectPersonWeapon())
        
        let scene = game.endScene
        XCTAssert(scene?.childNode(withName: "AnswerPanel") != nil)
        XCTAssert(((scene?.childNode(withName: "QuestionPanel")?.childNode(withName: "Result") as! SKLabelNode).text?.contains("Game over. "))!)
    }
    
    func testAccuseWrongly() {
        let game = Game.getGame()
        game.endScene = nil
        
        let mockPlayer = Player(c: people![2])
        let mock2 = Player(c: people![3])
        
        game.allPlayers = [player!, mockPlayer, mock2]
        
        player?.roomSoln = rooms![2]
        player?.weaponSoln = weapons![2]
        player?.charSoln = people![2]
        
        game.solution = Trio(person: people![3], weapon: weapons![2], location: rooms![2])
        
        player?.chooseToSuspect()
        
        XCTAssert(Trio(person: people![3], weapon: weapons![2], location: rooms![2]) != player!.selectPersonWeapon())
        
        game.accuse(guess: player!.selectPersonWeapon())
        
        let scene = game.endScene
        XCTAssert(scene == nil)
        XCTAssert(game.remainingPlayers.count == game.allPlayers.count-1)
        XCTAssert(game.state == State.waitingForDoneWithNoteTaking)
        
    }

    override func setUp() {
        super.setUp()
        
        let nextScene = BoardScene(fileNamed: "BoardScene")
        nextScene?.scaleMode = .aspectFill
        nextScene?.setUpTiles()
        
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.characterName = "Miss Scarlett"
        scene.numPlayers = 2
        scene.difficulty = 1
        
        let gameObj = scene.initialize(scene: nextScene!)
        gameObj.boardScene = nextScene!
        nextScene?.game = gameObj
        nextScene?.setUpTiles()
        
        
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
        
        people = [p1, p2, p3, p4, p5, p6]
        weapons = [w1, w2, w3, w4, w5, w6]
        rooms = [r1, r2, r3, r4, r5, r6, r7, r8, r9]
        
        player = EasyAIPlayer(c: p1)
        
        player?.hand = [p1, p2, w1, w2, r1, r2]
        player?.markHandCards()
        
        player?.position = nextScene?.board["conservatory"]
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
