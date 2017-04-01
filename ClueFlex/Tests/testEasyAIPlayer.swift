//
//  testEasyAIPlayer.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2017-03-27.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
@testable import ClueFlex

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
        player!.charInfo["Mrs Peacock"] = mockPlayer!
        player!.charInfo["Mr Green"] = mockPlayer!
        player!.weaponInfo["Lead Pipe"] = mockPlayer!
        player!.weaponInfo["Revolver"] = mockPlayer!
        
        for _ in 0...5{
            let guess = player!.selectPersonWeapon()
        
        XCTAssert(guess.person == people![5] || guess.person == people![4], "Guessed a person known already " + guess.person.name)
        XCTAssert(guess.weapon == weapons![5] || guess.weapon == weapons![4], "Guessed a weapon known already " + guess.weapon.name)
        }
    }
    
    func testTakeNotes() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![3])
        player?.takeNotes(Answer(card: people![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo["Mr Green"]! == mockPlayer!, "Did not take correct note - person")
        
        player?.takeNotes(Answer(card: weapons![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.weaponInfo["Revolver"]! == mockPlayer!, "Did not take correct note - weapon")
        
        player?.takeNotes(Answer(card: rooms![3], person: mockPlayer!), question: trio)
        XCTAssert(player!.roomInfo["Dining room"]! == mockPlayer!, "Did not take correct note - room")
    }
    
    func testTakeNotesNoAnswerOne() {
        let trio = Trio(person: people![3], weapon: weapons![1], location: rooms![1])
        player?.takeNotes(Answer(card: nil, person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo["Mr Green"]! == nil, "Took wrong note - person")
        XCTAssert(player!.charSoln == people![3], "Did not note solution")
    }
    
    func testTakeNotesNoAnswerMany() {
        let trio = Trio(person: people![3], weapon: weapons![3], location: rooms![3])
        player?.takeNotes(Answer(card: nil, person: mockPlayer!), question: trio)
        XCTAssert(player!.charInfo["Mr Green"]! == nil, "Took wrong note - person")
        XCTAssert(player!.charSoln == people![3], "Did not note solution")
        
    
        XCTAssert(player!.weaponInfo["Revolver"]! == mockPlayer!, "Took wrong note - weapon")
        XCTAssert(player!.weaponSoln == weapons![3], "Did not note solution")
        
        XCTAssert(player!.roomInfo["Dining room"]! == mockPlayer!, "Did not take correct note - room")
        XCTAssert(player!.roomSoln == rooms![3], "Did not note solution")
    }
    
    func testFindsSolution() {
        player!.charInfo["Mrs Peacock"] = mockPlayer!
        player!.charInfo["Mr Green"] = mockPlayer!
        player!.charInfo["Col. Mustard"] = mockPlayer!
        player!.weaponInfo["Lead Pipe"] = mockPlayer!
        player!.weaponInfo["Revolver"] = mockPlayer!
        player!.weaponInfo["Rope"] = mockPlayer!
        //am in conservatory
        player!.roomInfo["Dining room"] = mockPlayer!
        player!.roomInfo["Billard"] = mockPlayer!
        player!.roomInfo["Library"] = mockPlayer!
        player!.roomInfo["Lounge"] = mockPlayer!
        player!.roomInfo["Hall"] = mockPlayer!
        
        player?.takeNotes(Answer(card: rooms![8], person: mockPlayer), question: Trio(person: people![2], weapon: weapons![3], location: rooms![8]))
        
        player!.chooseToSuspect()
        XCTAssertFalse(player!.suspect, "Did not choose to accuse")
        
        let accusal = player!.selectPersonWeapon()
        XCTAssert(accusal.person == people![5] && accusal.weapon == weapons![5] && accusal.location == rooms![2], "Made wrong accusal")
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
        mockPlayer = Player(c: p2)
        
        player?.hand = [p1, p2, w1, w2, r1, r2]
        player?.markHandCards()
        
        player?.position = nextScene?.board["conservatory"]
        
        mockPlayer?.position = nextScene?.board["plum start"]
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
