//
//  RoomScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-18.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class RoomScene: SKScene {
    var game : Game?
    
    var people: [Card]?
    var weapons: [Card]?
    var rooms: [Card]?
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        game = Game.getGame()
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if(node.name == "Start")
        {

            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func switchToBoardView()
    {
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 0.5)
        let nextScene = game?.boardScene
        nextScene?.size = self.size
        nextScene?.scaleMode = .AspectFill
        self.view?.presentScene(nextScene!, transition: reveal)
    }


}
