//
//  testPosition.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2017-04-03.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
@testable import ClueFlex
class testPosition: XCTestCase {
    
    var boardScene : BoardScene?
    var player : EasyAIPlayer?

    override func setUp() {
        super.setUp()
        
        boardScene = BoardScene(fileNamed: "BoardScene")
        boardScene?.scaleMode = .aspectFill
        boardScene?.setUpTiles()
        
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.characterName = "Miss Scarlett"
        scene.numPlayers = 2
        scene.difficulty = 1
        
        let gameObj = scene.initialize(scene: boardScene!)
        gameObj.boardScene = boardScene!
        boardScene?.game = gameObj
        boardScene?.setUpTiles()
        
        player = EasyAIPlayer(c: Card(n: "Miss Scarlett", t: Type.character, file: "scarlett"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testClosestWhenWithin2Turns() {
        //board["study"]?.adjacent = [board["tile19"]!, board["kitchen"]!]
        
        let result = boardScene?.board["tile19"]?.closestRoom(lastVisited: boardScene?.board["study"], numTurns: 1)
        XCTAssert(result == boardScene!.board["hall"], "Returned: " + (result?.room?.name)!)
    }
    
    func testTakesPassageWay() {
        let result = boardScene?.board["conservatory"]?.closestRoom(lastVisited: boardScene?.board["study"], numTurns: 1)
        XCTAssert(result == boardScene!.board["lounge"], "Returned: " + (result?.room?.name)!)
    }
    
    func testDoesntTakesPassageWay() {
        let result = boardScene?.board["tile18"]?.closestRoom(lastVisited: boardScene?.board["study"], numTurns: 1)
        XCTAssert(result! == boardScene!.board["hall"]!, "Returned: " + (result?.sprite.name)!)
    }
    
    func testCaseKnowsPersonAndWeaponPassageWay() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.character, file: "rope")
        player?.position = boardScene?.board["conservatory"]
        
        XCTAssert(player?.move(num: 5) == 1, "Took too long path")
        XCTAssert(player?.position == boardScene!.board["lounge"], "Returned: " + (player?.position?.room?.name)!)
    }
    
    func testCaseKnowsPersonAndWeapon() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.character, file: "rope")
        player?.lastRoomEntered = boardScene?.board["lounge"]
        player?.turnsSinceEntered = 1
        player?.position = boardScene?.board["tile38"]
        
        player?.move(num: 5)
        XCTAssert(player?.position == boardScene!.board["dining"], "Returned: " + (player?.position?.room?.name)!)
    }
    
    func testCaseAccuseFromRoom() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.weapon, file: "rope")
        player?.roomSoln = Card(n: "Lounge", t: Type.location, file: "lounge")
        player?.lastRoomEntered = boardScene?.board["lounge"]
        player?.turnsSinceEntered = 0
        player?.chooseToSuspect()
        player?.position = boardScene?.board["lounge"]
        
//      Closest room without passage
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene!.board["dining"], "Returned: " + (player?.position?.room?.name)!)
    }
    
    func testCaseAccuseFromOutsideRoomClose() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.character, file: "rope")
        player?.roomSoln = Card(n: "Study", t: Type.character, file: "Study")
        player?.chooseToSuspect()
        player?.position = boardScene?.board["tile19"]
        player?.lastRoomEntered = boardScene?.board["lounge"]
        player?.turnsSinceEntered = 1
        
        player?.move(num: 7)
        XCTAssert(player?.position == boardScene!.board["hall"], "Returned: " + (player?.position?.room?.name)!)
    }
    
    func testCaseAccuseFromOutsideRoomFar() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.character, file: "rope")
        player?.roomSoln = boardScene?.board["lounge"]?.room!
        player?.chooseToSuspect()
        XCTAssertTrue(player!.suspect, "Chose to accuse even if not in right room.")
        XCTAssertFalse(player!.notReadyToAccuse())
        player?.position = boardScene?.board["tile37"]
        player?.lastRoomEntered = boardScene?.board["lounge"]
        player?.turnsSinceEntered = 1
        
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board["tile39"], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testNoExit() {
        //board["study"]?.adjacent = [board["tile19"]!, board["kitchen"]!]
        
        player?.position = boardScene?.board["study"]
        player?.lastRoomEntered = boardScene?.board["kitchen"]
        player?.turnsSinceEntered = 1
        
        boardScene?.board["tile19"]?.isOccupied = true
        
        let closest = boardScene?.board["study"]?.closestRoom(lastVisited: boardScene?.board["kitchen"], numTurns: 1)
        XCTAssert(closest == boardScene?.board["hall"], closest!.room!.name)
        
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board["study"], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testHumanNoExit() {
        //board["study"]?.adjacent = [board["tile19"]!, board["kitchen"]!]
        
        boardScene?.board["tile19"]?.isOccupied = true
        let options = boardScene!.board["study"]!.reachablePositions(3, true, lastRoomEntered: boardScene?.board["kitchen"], turnsSinceEntered: 1)
        XCTAssert(options.count == 0, String(options.count))
    }

}
