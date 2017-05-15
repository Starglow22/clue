//
//  GameScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-10.
//  Copyright (c) 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    
    let help = Help()
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        help.hide(self)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let location = theEvent.location(in: self)
        let node = self.atPoint(location)
        if(node.name == "Start")
        {
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
            let nextScene = MenuScene(fileNamed: "MenuScene")
            
            nextScene?.size = self.size
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: reveal)
        }
        
        if(self.childNode(withName: "Help")!.frame.contains(location)) { // self.atPoint uses accumulated bounding rectangle including children but not what I want for help. Fine for other uses.
            help.clicked(self)
        }else if(help.displayed)
        {
            help.hide(self)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
