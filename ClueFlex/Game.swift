//
//  File.swift
//  ClueFlex
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
    
    
    var players: [Player]
    var currentPlayer: Player
    var humanPlayer: Player
    
    var solution: Trio
    var state: State
    
    var boardScene: BoardScene
    var roomScene: RoomScene?
    
    var roomCards: [Card]?
    
    var noteCard: NoteCard
    
    
    init(players: [Player], s:Trio, scene:BoardScene, human:HumanPlayer)
    {
        self.players = players
        currentPlayer = players[Int(arc4random_uniform(UInt32(players.count)))]
        
        solution = s
        state = State.waitingForTurn
        boardScene = scene
        noteCard = NoteCard(sprite: boardScene.childNodeWithName("NoteCard") as! SKSpriteNode)
        humanPlayer = human
        
        super.init()
        Game.instance = self;
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
