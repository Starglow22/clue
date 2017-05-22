//
//  testPosition.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-04-03.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
@testable import Clue
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
        XCTAssert(result == boardScene!.board["lounge"], "Returned: " + (result?.sprite.name)!)
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
        XCTAssert(player?.position == boardScene!.board["lounge"], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testCaseKnowsPersonAndWeapon() {
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        player?.weaponSoln = Card(n: "Rope", t: Type.character, file: "rope")
        player?.lastRoomEntered = boardScene?.board["lounge"]
        player?.turnsSinceEntered = 1
        player?.position = boardScene?.board["tile38"]
        
        player?.move(num: 5)
        XCTAssert(player?.position == boardScene!.board["dining"], "Returned: " + (player?.position?.sprite.name)!)
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
        XCTAssert(player?.position == boardScene!.board["dining"], "Returned: " + (player?.position?.sprite.name)!)
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
        XCTAssert(player?.position == boardScene!.board["hall"], "Returned: " + (player?.position?.sprite.name)!)
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
    
    func testRoomEndOfMove() {
        player?.roomSoln = Card(n: "Library", t: Type.location, file: "library")
        player?.weaponSoln = Card(n: "Rope", t: Type.weapon, file: "rope")
        player?.charSoln = Card(n: "Miss Scarlett", t: Type.character, file: "scarlett")
        
        player?.position = boardScene!.board["tile106"] // door of billard
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board["billard"], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testShortestPath() {
        let path = boardScene!.board["tile51"]?.shortestPathTo(boardScene!.board["hall"]!, lastVisited: nil, numTurns: 1) // right of right part of double door to hall
        XCTAssert(path! == [boardScene!.board["tile50"]!, boardScene!.board["hall"]!], "\(path![0].sprite.name), \(path![1].sprite.name), \(path![2].sprite.name)")
    }
    
    func testHallConnections() {
        let options = boardScene!.board["tile54"]?.reachablePositions(5, true, lastRoomEntered: nil, turnsSinceEntered: 0)
        XCTAssert(options!.contains(boardScene!.board["hall"]!))
        
        let path = boardScene!.board["tile54"]?.shortestPathTo(boardScene!.board["hall"]!, lastVisited: nil, numTurns: 0) // right of right part of double door to hall
        XCTAssert(path! == [boardScene!.board["tile53"]!, boardScene!.board["tile52"]!, boardScene!.board["tile51"]!, boardScene!.board["tile50"]!, boardScene!.board["hall"]!], "\(path![0].sprite.name), \(path![1].sprite.name), \(path![2].sprite.name)")
    }

}
