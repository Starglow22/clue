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
        scene.characterName = Constant.SCARLETT_NAME
        scene.numPlayers = 2
        scene.difficulty = 1
        
        let gameObj = scene.initialize(scene: boardScene!)
        gameObj.boardScene = boardScene!
        boardScene?.game = gameObj
        boardScene?.setUpTiles()
        
        player = EasyAIPlayer(c: Constant.SCARLETT_CARD)    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testClosestWhenWithin2Turns() {
        //board[Constant.STUDY_TILE_NAME]?.adjacent = [board["tile19"]!, board[Constant.KITCHEN_TILE_NAME]!]
        
        let result = boardScene?.board["tile19"]?.closestRoom(lastVisited: boardScene?.board[Constant.STUDY_TILE_NAME], numTurns: 1)
        XCTAssert(result == boardScene!.board[Constant.HALL_TILE_NAME], "Returned: " + (result?.room?.name)!)
    }
    
    func testTakesPassageWay() {
        let result = boardScene?.board[Constant.CONSERVATORY_TILE_NAME]?.closestRoom(lastVisited: boardScene?.board[Constant.STUDY_TILE_NAME], numTurns: 1)
        XCTAssert(result == boardScene!.board[Constant.LOUNGE_TILE_NAME], "Returned: " + (result?.sprite.name)!)
    }
    
    func testDoesntTakesPassageWay() {
        let result = boardScene?.board["tile18"]?.closestRoom(lastVisited: boardScene?.board[Constant.STUDY_TILE_NAME], numTurns: 1)
        XCTAssert(result! == boardScene!.board[Constant.HALL_TILE_NAME]!, "Returned: " + (result?.sprite.name)!)
    }
    
    func testCaseKnowsPersonAndWeaponPassageWay() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.position = boardScene?.board[Constant.CONSERVATORY_TILE_NAME]
        
        XCTAssert(player?.move(num: 5) == 1, "Took too long path")
        XCTAssert(player?.position == boardScene!.board[Constant.LOUNGE_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testCaseKnowsPersonAndWeapon() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.lastRoomEntered = boardScene?.board[Constant.LOUNGE_TILE_NAME]
        player?.turnsSinceEntered = 1
        player?.position = boardScene?.board["tile38"]
        
        player?.move(num: 5)
        XCTAssert(player?.position == boardScene!.board[Constant.DINING_ROOM_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testCaseAccuseFromRoom() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.roomSoln = Constant.LOUNGE_CARD
        player?.lastRoomEntered = boardScene?.board[Constant.LOUNGE_TILE_NAME]
        player?.turnsSinceEntered = 0
        player?.chooseToSuspect()
        player?.position = boardScene?.board[Constant.LOUNGE_TILE_NAME]
        
//      Closest room without passage
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene!.board[Constant.DINING_ROOM_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testCaseAccuseFromOutsideRoomClose() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.roomSoln = Constant.STUDY_CARD
        player?.chooseToSuspect()
        player?.position = boardScene?.board["tile19"]
        player?.lastRoomEntered = boardScene?.board[Constant.STUDY_TILE_NAME]
        player?.turnsSinceEntered = 1
        
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene!.board[Constant.HALL_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testCaseAccuseFromOutsideRoomFar() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.roomSoln = Constant.LOUNGE_CARD
        player?.chooseToSuspect()
        XCTAssertTrue(player!.suspect, "Chose to accuse even if not in right room.")
        XCTAssertFalse(player!.notReadyToAccuse())
        player?.position = boardScene?.board["tile37"]
        player?.lastRoomEntered = boardScene?.board[Constant.LOUNGE_TILE_NAME]
        player?.turnsSinceEntered = 1
        
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board["tile39"], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testNoExit() {
        //board[Constant.STUDY_TILE_NAME]?.adjacent = [board["tile19"]!, board[Constant.KITCHEN_TILE_NAME]!]
        
        player?.position = boardScene?.board[Constant.STUDY_TILE_NAME]
        player?.lastRoomEntered = boardScene?.board[Constant.KITCHEN_TILE_NAME]
        player?.turnsSinceEntered = 1
        
        boardScene?.board["tile19"]?.isOccupied = true
        
        let closest = boardScene?.board[Constant.STUDY_TILE_NAME]?.closestRoom(lastVisited: boardScene?.board[Constant.KITCHEN_TILE_NAME], numTurns: 1)
        XCTAssert(closest == boardScene?.board[Constant.HALL_TILE_NAME], closest!.room!.name)
        
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board[Constant.STUDY_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testHumanNoExit() {
        //board[Constant.STUDY_TILE_NAME]?.adjacent = [board["tile19"]!, board[Constant.KITCHEN_TILE_NAME]!]
        
        boardScene?.board["tile19"]?.isOccupied = true
        let options = boardScene!.board[Constant.STUDY_TILE_NAME]!.reachablePositions(3, true, lastRoomEntered: boardScene?.board[Constant.KITCHEN_TILE_NAME], turnsSinceEntered: 1)
        XCTAssert(options.count == 0, String(options.count))
    }
    
    func testRoomEndOfMove() {
        player?.charSoln = Constant.SCARLETT_CARD
        player?.weaponSoln = Constant.ROPE_CARD
        player?.roomSoln = Constant.LIBRARY_CARD
        
        player?.position = boardScene!.board["tile106"] // door of billard
        player?.move(num: 4)
        XCTAssert(player?.position == boardScene?.board[Constant.BILLARD_ROOM_TILE_NAME], "Returned: " + (player?.position?.sprite.name)!)
    }
    
    func testShortestPath() {
        let path = boardScene!.board["tile51"]?.shortestPathTo(boardScene!.board[Constant.HALL_TILE_NAME]!, lastVisited: nil, numTurns: 1) // right of right part of double door to hall
        XCTAssert(path! == [boardScene!.board["tile50"]!, boardScene!.board[Constant.HALL_TILE_NAME]!], "\(path![0].sprite.name), \(path![1].sprite.name), \(path![2].sprite.name)")
    }
    
    func testHallConnections() {
        let options = boardScene!.board["tile54"]?.reachablePositions(5, true, lastRoomEntered: nil, turnsSinceEntered: 0)
        XCTAssert(options!.contains(boardScene!.board[Constant.HALL_TILE_NAME]!))
        
        let path = boardScene!.board["tile54"]?.shortestPathTo(boardScene!.board[Constant.HALL_TILE_NAME]!, lastVisited: nil, numTurns: 0) // right of right part of double door to hall
        XCTAssert(path! == [boardScene!.board["tile53"]!, boardScene!.board["tile52"]!, boardScene!.board["tile51"]!, boardScene!.board["tile50"]!, boardScene!.board[Constant.HALL_TILE_NAME]!], "\(path![0].sprite.name ?? "nil"), \(path![1].sprite.name ?? "nil"), \(path![2].sprite.name ?? "nil")")
    }
    
    func testBillardConnections() {
        let options = boardScene!.board["tile119"]?.reachablePositions(5, true, lastRoomEntered: boardScene!.board[Constant.BALLROOM_TILE_NAME]!, turnsSinceEntered: 2)
        XCTAssert(options!.contains(boardScene!.board[Constant.BILLARD_ROOM_TILE_NAME]!))
        
//        let path = boardScene!.board["tile54"]?.shortestPathTo(boardScene!.board[Constant.HALL_TILE_NAME]!, lastVisited: nil, numTurns: 0) // right of right part of double door to hall
//        XCTAssert(path! == [boardScene!.board["tile53"]!, boardScene!.board["tile52"]!, boardScene!.board["tile51"]!, boardScene!.board["tile50"]!, boardScene!.board[Constant.HALL_TILE_NAME]!], "\(path![0].sprite.name ?? "nil"), \(path![1].sprite.name ?? "nil"), \(path![2].sprite.name ?? "nil")")
    }
    
    func testDiningNPE() {
        let path = boardScene!.board[Constant.DINING_ROOM_TILE_NAME]!.shortestPathTo(boardScene!.board[Constant.CONSERVATORY_TILE_NAME]!, lastVisited: boardScene!.board[Constant.LOUNGE_TILE_NAME]!, numTurns: 0)
        
        XCTAssert(path != nil)
    }
    
    func testDiningNPE2() {
        let path = boardScene!.board[Constant.DINING_ROOM_TILE_NAME]!.shortestPathTo(boardScene!.board[Constant.CONSERVATORY_TILE_NAME]!, lastVisited: boardScene!.board[Constant.LOUNGE_TILE_NAME]!, numTurns: 1)
        
        XCTAssert(path != nil)
    }

}
