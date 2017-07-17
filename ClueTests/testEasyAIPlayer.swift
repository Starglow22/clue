//
//  testEasyAIPlayer.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-03-27.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//
import XCTest
@testable import Clue

class testEasyAIPlayer: XCTestCase {
    
    var player : EasyAIPlayer?
    var mockPlayer : Player?
    
    var people : [Card]?
    var weapons : [Card]?
    var rooms : [Card]?
    
    func testReplyHasOneNotShownAlready() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![1])
        let reply = player!.reply(trio, p: mockPlayer!)
        XCTAssert(reply == rooms![1], "Reply was " + reply!.name)
    }
    
    func testReplyHasManyNotShownAlready() {
        let trio = Trio(person: people![1], weapon: weapons![3], location: rooms![1])
        let reply = player!.reply(trio, p: mockPlayer!)
        XCTAssert(reply == rooms![1] || reply == people![1], "Reply was " + reply!.name)
        
        //assert response is random
        var person = 0
        var weapon = 0
        var room = 0
        for _ in 0...10 {
            let trio = Trio(person: people![1], weapon: weapons![1], location: rooms![1])
            let reply = player!.reply(trio, p: mockPlayer!)
            XCTAssert(reply == rooms![1] || reply == weapons![3] || reply == people![1], "Reply was not in question")
            
            if (reply == rooms![1])
            {
                person += 1
            }else if (reply == weapons![1])
            {
                weapon += 1
            }else if (reply == rooms![1])
            {
                room += 1
            }
        }
        XCTAssert((person == 0 && weapon == 0) || (person == 0 && room == 0) || (room == 0 && weapon == 0), "Always returns same answer")
    }
    
    func testReplyNone() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![3])
        let reply = player!.reply(trio, p: mockPlayer!)
        XCTAssert(reply == nil)
    }
    
    func testReplyShownOne() {
        let trio = Trio(person: people![1], weapon: weapons![3], location: rooms![3])
        let reply1 = player!.reply(trio, p: mockPlayer!)
        XCTAssert(player!.shown[mockPlayer!.character.name]!.contains(people![1]), "Did not take note of showing card")
        
        let trio2 = Trio(person: people![1], weapon: weapons![1], location: rooms![1])
        let reply2 = player!.reply(trio2, p: mockPlayer!)
        XCTAssert(reply2 == reply1)
        
        let reply3 = player!.reply(trio2, p: mockPlayer!)
        XCTAssert(reply2 == reply3)
    }
    
    func testSuspectChoosesRandomly() {
        var person = Set<Card>.init()
        var weapon = Set<Card>.init()
        for _ in 0...10{
            let guess = player!.selectPersonWeapon()
            person.insert(guess.person)
            weapon.insert(guess.weapon)
        }
        XCTAssert(person.count > 1, "Always returns same person")
        XCTAssert(weapon.count > 1, "Always returns same weapon")
    }
    
    func testDoesNotSuspectKnown() {
        player!.charInfo[Constant.PEACOCK_NAME] = mockPlayer!
        player!.charInfo[Constant.GREEN_NAME] = mockPlayer!
        player!.weaponInfo["Lead Pipe"] = mockPlayer!
        player!.weaponInfo["Revolver"] = mockPlayer!
        
        for _ in 0...5{
            let guess = player!.selectPersonWeapon()
            
            XCTAssert(guess.person == people![5] || guess.person == people![4], "Guessed a person known already " + guess.person.name)
            XCTAssert(guess.weapon == weapons![5] || guess.weapon == weapons![4], "Guessed a weapon known already " + guess.weapon.name)
        }
    }
    
    func testAccuseInWrongRoom(){ // shouldn't accuse, should ask for combination of hand and solution cards
        player!.charSoln = people![3]
        player!.weaponSoln = weapons![3]
        player!.roomSoln = rooms![3]
        
        player!.chooseToSuspect()
        XCTAssertTrue(player!.suspect, "Accusing in wrong room")
        let question = player!.selectPersonWeapon()
        XCTAssert(people![0] == question.person || people![1] == question.person || people![3] == question.person, question.person.name)
        XCTAssert(weapons![0] == question.weapon || weapons![1] == question.weapon || weapons![3] == question.weapon, question.weapon.name)
    }
    
    func testTakeNotes() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![3])
        player?.takeNotes(Answer(card: people![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo[Constant.GREEN_NAME]! == mockPlayer!, "Did not take correct note - person")
        // does not take extraneous notes
        for s in player!.charInfo
        {
            if(s.key != Constant.GREEN_NAME && s.key != Constant.SCARLETT_NAME && s.key != Constant.PLUM_NAME){
                XCTAssert(s.value == nil, "Took other notes")
            }
        }
        
        player?.takeNotes(Answer(card: weapons![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.weaponInfo["Revolver"]! == mockPlayer!, "Did not take correct note - weapon")
        
        player?.takeNotes(Answer(card: rooms![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.roomInfo["Dining room"]! == mockPlayer!, "Did not take correct note - room")
    }
    
    func testTakeNotesNoAnswerOne() {
        let trio = Trio(person: people![3], weapon: weapons![1], location: rooms![1])
        player?.takeNotes(Answer(card: nil, person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo[Constant.GREEN_NAME]! == nil, "Took wrong note - person")
        XCTAssert(player!.charSoln == people![3], "Did not note solution")
    }
    
    func testTakeNotesNoAnswerMany() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![3])
        player?.takeNotes(Answer(card: nil, person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo[Constant.GREEN_NAME]! == nil, "Took wrong note - person")
        XCTAssert(player!.charSoln == people![3], "Did not note solution")
        
        XCTAssert(player!.weaponInfo["Revolver"]! == nil, "Took wrong note - weapon")
        XCTAssert(player!.weaponSoln == weapons![3], "Did not note solution")
        
        XCTAssert(player!.roomInfo["Dining room"]! == nil, "Did not take correct note - room")
        XCTAssert(player!.roomSoln == rooms![3], "Did not note solution")
    }
    
    func testFindsSolution() {
        player!.charInfo[Constant.PEACOCK_NAME] = mockPlayer!
        player!.charInfo[Constant.GREEN_NAME] = mockPlayer!
        player!.charInfo[Constant.MUSTARD_NAME] = mockPlayer!
        player!.weaponInfo["Lead Pipe"] = mockPlayer!
        player!.weaponInfo["Revolver"] = mockPlayer!
        player!.weaponInfo["Rope"] = mockPlayer!
        
        player!.roomInfo["Dining room"] = mockPlayer!
        player!.roomInfo["Billard Room"] = mockPlayer!
        player!.roomInfo["Library"] = mockPlayer!
        player!.roomInfo["Lounge"] = mockPlayer!
        player!.roomInfo["Hall"] = mockPlayer!
        
        player?.takeNotes(Answer(card: rooms![8], person: mockPlayer), question: Trio(person: people![2], weapon: weapons![3], location: rooms![8]))
        
        XCTAssert(Game.getGame().boardScene.board[Constant.CONSERVATORY_TILE_NAME]!.room == rooms![2])
        XCTAssert(Game.getGame().boardScene.board[Constant.CONSERVATORY_TILE_NAME]!.room!.name == rooms![2].name)
        
        player!.chooseToSuspect()
        XCTAssertFalse(player!.suspect, "Did not choose to accuse")
        
        let accusal = player!.selectPersonWeapon()
        XCTAssert(accusal.person == people![5] && accusal.weapon == weapons![5] && accusal.location == rooms![2], "Made wrong accusal " + accusal.location.name)
    }
    
    func testDiningRoomToConservatoryToAccuse() {
        player!.charSoln = people![1]
        player!.weaponSoln = weapons![1]
        player!.roomSoln = rooms![2]
        
        player?.position = Game.getGame().boardScene.board[Constant.DINING_ROOM_TILE_NAME]
        player?.lastRoomEntered = nil
        
        player?.move(num: 5)
        
        XCTAssert(player?.position?.room == Game.getGame().boardScene.board[Constant.LOUNGE_TILE_NAME]!.room, (player?.position?.sprite.name)!)
        
        player!.chooseToSuspect()
        XCTAssertTrue(player!.suspect, "Chose to accuse")
        
        player?.move(num: 5)
        XCTAssert(player?.position?.room == Game.getGame().boardScene.board[Constant.CONSERVATORY_TILE_NAME]!.room, (player?.position?.sprite.name)!)
    }
    
    func testDiningRoomToConservatoryToAccuseComingFromLounge() {
        player!.charSoln = people![1]
        player!.weaponSoln = weapons![1]
        player!.roomSoln = rooms![2]
        
        player?.position = Game.getGame().boardScene.board[Constant.DINING_ROOM_TILE_NAME]
        player?.lastRoomEntered = Game.getGame().boardScene.board[Constant.LOUNGE_TILE_NAME]
        player?.turnsSinceEntered = 1
        
        player?.move(num: 5)
        player?.move(num: 4)
        
        XCTAssert(player?.position?.room == Game.getGame().boardScene.board[Constant.BALLROOM_TILE_NAME]!.room, (player?.position?.sprite.name)!)
        
        player!.chooseToSuspect()
        XCTAssertTrue(player!.suspect, "Chose to accuse")
        
        player?.move(num: 5)
        XCTAssert(player?.position?.room == Game.getGame().boardScene.board[Constant.CONSERVATORY_TILE_NAME]!.room, (player?.position?.sprite.name)!)
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
        mockPlayer = Player(c: Constant.PLUM_CARD)
        
        player?.hand = [Constant.SCARLETT_CARD, Constant.PLUM_CARD, Constant.CANDLESTICK_CARD, Constant.KNIFE_CARD, Constant.KITCHEN_CARD, Constant.BALLROOM_CARD]
        player?.markHandCards()
        
        player?.position = nextScene?.board[Constant.CONSERVATORY_TILE_NAME]
        
        mockPlayer?.position = nextScene?.board[Constant.PLUM_START]
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
