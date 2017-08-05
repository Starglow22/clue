//
//  testComplexPlayers.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-07-23.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import XCTest
@testable import Clue

class testComplexPlayers: XCTestCase {

    var player : HardAIPlayer?
    var mockPlayer : Player?
    var mockPlayer2 : Player?
    
    var people : [Card]?
    var weapons : [Card]?
    var rooms : [Card]?
    
    var nextScene : BoardScene?
    
    func testPlayersDistibution(){
        let menu = MenuScene(fileNamed: "MenuScene")!
        menu.characterName = Constant.WHITE_NAME
        menu.numPlayers = 2
        menu.difficulty = 1
        XCTAssertEqual(numEachTypeOfPlayer(menu.initialize(scene: nextScene!)).0, 2)
        
        menu.difficulty = 2
        var result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 2)
        
        menu.difficulty = 4
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 1)
        XCTAssertEqual(result.1, 1)
        
        menu.difficulty = 5
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 1)
        XCTAssertEqual(result.2, 1)
        
        menu.difficulty = 8
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.1, 1)
        XCTAssertEqual(result.2, 1)
        
        menu.difficulty = 10
        XCTAssertEqual(numEachTypeOfPlayer(menu.initialize(scene: nextScene!)).2, 2)
        
        //
        
        menu.numPlayers = 5
        menu.difficulty = 1
        XCTAssertEqual(numEachTypeOfPlayer(menu.initialize(scene: nextScene!)).0, 5)
        
        menu.difficulty = 4
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 3)
        XCTAssertEqual(result.1, 0)
        XCTAssertEqual(result.2, 2)
        
        menu.difficulty = 5
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 2)
        XCTAssertEqual(result.1, 1)
        XCTAssertEqual(result.2, 2)
        
        menu.difficulty = 7
        result = numEachTypeOfPlayer(menu.initialize(scene: nextScene!))
        XCTAssertEqual(result.0, 1)
        XCTAssertEqual(result.1, 1)
        XCTAssertEqual(result.2, 3)
        
        menu.difficulty = 10
        XCTAssertEqual(numEachTypeOfPlayer(menu.initialize(scene: nextScene!)).2, 5)
    }
    
    func numEachTypeOfPlayer(_ game: Game) -> (Int, Int, Int)
    {
        var easy = 0, trick = 0, hard = 0
        for p in game.allPlayers
        {
            if p is HardAIPlayer
            {
                hard += 1
            }else if p is TricksterAIPlayer
            {
                trick += 1
            }else if p is EasyAIPlayer
            {
                easy += 1
            }
        }
        
        return (easy, trick, hard)
    }
    
    func testDoesntGoToRoomShownByNextPlayerButGoesToShownBySecondNext() {
        player?.position = nextScene?.board[Constant.BILLARD_ROOM_TILE_NAME]
        XCTAssertEqual(player!.position!.room!, Constant.BILLARD_ROOM_CARD)
        player?.roomInfo[Constant.LIBRARY_CARD.name] = mockPlayer
        player?.roomInfo[Constant.BALLROOM_CARD.name] = mockPlayer2
        let _ = player?.move(num: 6)
        XCTAssertEqual(player!.position!.room!.name, Constant.BALLROOM_CARD.name)
    }
    
    func testGoesToSecondRoomIfCanReach()
    {
        player?.position = nextScene?.board[Constant.BILLARD_ROOM_TILE_NAME]
        XCTAssertEqual(player!.position!.room!, Constant.BILLARD_ROOM_CARD)
        let _ = player?.move(num: 6)
        XCTAssertEqual(player!.position!.room!.name, Constant.BALLROOM_CARD.name)
    }
    
    func testGoesToClosestOnNormalMove(){
        player?.position = nextScene?.board[Constant.BILLARD_ROOM_TILE_NAME]
        XCTAssertEqual(player!.position!.room!, Constant.BILLARD_ROOM_CARD)
        let _ = player?.move(num: 3)
        XCTAssertEqual(player!.position!, nextScene?.board["tile83"]!)
    }
    
    func testObserveNothingShownNotEnoughInfo()
    {
        mockPlayer2?.hand = [Constant.MUSTARD_CARD, Constant.LEAD_PIPE_CARD, Constant.CONSERVATORY_CARD]
        player?.charInfo[Constant.GREEN_CARD.name] = mockPlayer
        XCTAssertEqual(mockPlayer?.ask(Trio(person: Constant.GREEN_CARD, weapon: Constant.ROPE_CARD, location: Constant.DINING_ROOM_CARD)), Answer(card: nil, person: nil))
        
        XCTAssertEqual(player!.charInfo[Constant.GREEN_CARD.name]!, mockPlayer)
        XCTAssertNil(player!.charSoln)
        XCTAssertNil(player!.weaponInfo[Constant.ROPE_CARD.name]!)
        XCTAssertNil(player!.weaponSoln)
        XCTAssertNil(player!.roomInfo[Constant.DINING_ROOM_CARD.name]!)
        XCTAssertNil(player!.roomSoln)
    }
    
    func testObserveNothingShownPersonAskingHas2Of3()
    {
        mockPlayer2?.hand = [Constant.MUSTARD_CARD, Constant.LEAD_PIPE_CARD, Constant.CONSERVATORY_CARD]
        mockPlayer?.hand = [Constant.GREEN_CARD, Constant.WRENCH_CARD, Constant.BILLARD_ROOM_CARD]
        player?.charInfo[Constant.GREEN_CARD.name] = mockPlayer
        player?.weaponInfo[Constant.WRENCH_CARD.name] = mockPlayer
        player?.roomInfo[Constant.BILLARD_ROOM_CARD.name] = mockPlayer
        XCTAssertEqual(mockPlayer?.ask(Trio(person: Constant.GREEN_CARD, weapon: Constant.ROPE_CARD, location: Constant.BILLARD_ROOM_CARD)), Answer(card: nil, person: nil))
        
        XCTAssertEqual(player!.charInfo[Constant.GREEN_CARD.name]!, mockPlayer)
        XCTAssertNil(player!.charSoln)
        XCTAssertNil(player!.weaponInfo[Constant.ROPE_CARD.name]!)
        XCTAssertEqual(player!.weaponSoln, Constant.ROPE_CARD)
        XCTAssertEqual(player!.roomInfo[Constant.BILLARD_ROOM_CARD.name]!, mockPlayer)
    }
    
    func testObserveNothingShownTakesNotesKnowAllCardsOfPersonAsking()
    {
        mockPlayer2?.hand = [Constant.MUSTARD_CARD, Constant.LEAD_PIPE_CARD, Constant.CONSERVATORY_CARD]
        mockPlayer?.hand = [Constant.GREEN_CARD, Constant.WRENCH_CARD, Constant.BILLARD_ROOM_CARD]
        player?.charInfo[Constant.GREEN_CARD.name] = mockPlayer
        player?.weaponInfo[Constant.WRENCH_CARD.name] = mockPlayer
        player?.roomInfo[Constant.BILLARD_ROOM_CARD.name] = mockPlayer
        XCTAssertEqual(mockPlayer?.ask(Trio(person: Constant.GREEN_CARD, weapon: Constant.ROPE_CARD, location: Constant.DINING_ROOM_CARD)), Answer(card: nil, person: nil))
        
        XCTAssertEqual(player!.charInfo[Constant.GREEN_CARD.name]!, mockPlayer)
        XCTAssertNil(player!.charSoln)
        XCTAssertNil(player!.weaponInfo[Constant.ROPE_CARD.name]!)
        XCTAssertEqual(player!.weaponSoln, Constant.ROPE_CARD)
        XCTAssertNil(player!.roomInfo[Constant.DINING_ROOM_CARD.name]!)
        XCTAssertEqual(player!.roomSoln, Constant.DINING_ROOM_CARD)
    }
    
    func testObserveTakesNoNotesWhenPersonShowingHasCardAskedFor(){
        mockPlayer2?.hand = [Constant.MUSTARD_CARD, Constant.LEAD_PIPE_CARD, Constant.CONSERVATORY_CARD]
        (mockPlayer2 as! EasyAIPlayer).shown[player!.character.name]! = [Constant.MUSTARD_CARD]
        player!.charInfo[Constant.MUSTARD_CARD.name] = mockPlayer2
        XCTAssertEqual(mockPlayer?.ask(Trio(person: Constant.MUSTARD_CARD, weapon: Constant.ROPE_CARD, location: Constant.CONSERVATORY_CARD)), Answer(card: Constant.MUSTARD_CARD, person: mockPlayer2))
        
        XCTAssertEqual(player!.charInfo[Constant.MUSTARD_CARD.name]!, mockPlayer2)
        XCTAssertNil(player!.weaponInfo[Constant.ROPE_CARD.name]!)
        XCTAssertNil(player!.roomInfo[Constant.CONSERVATORY_CARD.name]!)
    }
    
    func testObserveTakesNoteWhenShown(){
        mockPlayer2?.hand = [Constant.MUSTARD_CARD, Constant.ROPE_CARD, Constant.CONSERVATORY_CARD]
        XCTAssertEqual(mockPlayer?.ask(Trio(person: Constant.SCARLETT_CARD, weapon: Constant.ROPE_CARD, location: Constant.BALLROOM_CARD)), Answer(card: Constant.ROPE_CARD, person: mockPlayer2))
        
        XCTAssertEqual(player!.charInfo[Constant.SCARLETT_CARD.name]!, player)
        XCTAssertEqual(player!.weaponInfo[Constant.ROPE_CARD.name]!, mockPlayer2)
        XCTAssertEqual(player!.roomInfo[Constant.BALLROOM_CARD.name]!, player)
    }

    func testTricksterTricks() {
        let trickster = TricksterAIPlayer(c: Constant.SCARLETT_CARD)
        trickster.hand = [Constant.SCARLETT_CARD, Constant.PLUM_CARD, Constant.CANDLESTICK_CARD, Constant.KNIFE_CARD, Constant.KITCHEN_CARD, Constant.BALLROOM_CARD]
        trickster.markHandCards()
        trickster.position = nextScene?.board[Constant.BALLROOM_TILE_NAME]
        
        var tricked = false
        
        for _ in 1...50
        {
            let guess = trickster.selectPersonWeapon()
            if(trickster.hand.contains(guess.person) && trickster.hand.contains(guess.weapon))
            {
                if(!tricked)
                {
                    XCTAssertTrue(trickster.hasTricked)
                    tricked = true
                }else{
                    XCTFail("Tricked twice")
                }
            }
        }
        
        XCTAssertTrue(tricked)
        
    }
    
    override func setUp() {
        super.setUp()
        
        nextScene = BoardScene(fileNamed: "BoardScene")
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
        
        player = HardAIPlayer(c: Constant.SCARLETT_CARD)
        mockPlayer = EasyAIPlayer(c: Constant.PLUM_CARD)
        mockPlayer2 = EasyAIPlayer(c: Constant.GREEN_CARD)
        
        player?.hand = [Constant.SCARLETT_CARD, Constant.PLUM_CARD, Constant.CANDLESTICK_CARD, Constant.KNIFE_CARD, Constant.KITCHEN_CARD, Constant.BALLROOM_CARD]
        player?.markHandCards()
        
        player?.position = nextScene?.board[Constant.CONSERVATORY_TILE_NAME]
        
        mockPlayer?.position = nextScene?.board[Constant.PLUM_START]
        mockPlayer2?.position = nextScene?.board[Constant.GREEN_START]
        
        Game.getGame().allPlayers = [player!, mockPlayer!, mockPlayer2!]
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
