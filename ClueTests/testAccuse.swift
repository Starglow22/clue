//
//  testAccuse.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-04-14.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
import SpriteKit
@testable import Clue

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
        XCTAssert(((scene?.childNode(withName: Constant.QUESTION_PANEL)?.childNode(withName: "Result") as! SKLabelNode).text?.contains("Game over. "))!)
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
        scene.characterName = Constant.SCARLETT_NAME
        scene.numPlayers = 2
        scene.difficulty = 1
        
        let gameObj = scene.initialize(scene: nextScene!)
        gameObj.boardScene = nextScene!
        nextScene?.game = gameObj
        nextScene?.setUpTiles()
        
        
        people = [Constant.SCARLETT_CARD, Constant.PLUM_CARD, Constant.PEACOCK_CARD, Constant.GREEN_CARD, Constant.MUSTARD_CARD, Constant.WHITE_CARD]
        weapons = [Constant.CANDLESTICK_CARD, Constant.KNIFE_CARD, Constant.LEAD_PIPE_CARD, Constant.REVOLVER_CARD, Constant.ROPE_CARD, Constant.WRENCH_CARD]
        rooms = [Constant.KITCHEN_CARD, Constant.BALLROOM_CARD, Constant.CONSERVATORY_CARD, Constant.DINING_ROOM_CARD, Constant.BILLARD_ROOM_CARD, Constant.LIBRARY_CARD, Constant.LOUNGE_CARD, Constant.HALL_CARD, Constant.STUDY_CARD]
        
        player = EasyAIPlayer(c: Constant.SCARLETT_CARD)
        
        player?.hand = [Constant.SCARLETT_CARD, Constant.PLUM_CARD, Constant.CANDLESTICK_CARD, Constant.KNIFE_CARD, Constant.KITCHEN_CARD, Constant.BALLROOM_CARD]
        player?.markHandCards()
        
        player?.position = nextScene?.board[Constant.CONSERVATORY_TILE_NAME]
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
