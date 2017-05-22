//
//  EndScene.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-05-14.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {

    override func mouseDown(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        let node = self.atPoint(location)
        if(node.name == "Restart")
        {
            Game.getGame().restart(self)
        }
    }
}
