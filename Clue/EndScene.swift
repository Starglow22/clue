//
//  EndScene.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-05-14.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {

    func setBackground() {
        if((self.childNode(withName: Constant.QUESTION_PANEL)!.childNode(withName: "Result") as! SKLabelNode).text!.contains("You won")){
            (self.childNode(withName: "Bkg")! as! SKSpriteNode).texture = SKTexture(imageNamed: "win")
            //color = NSColor.init(red: 0, green: 142, blue: 0, alpha: 1)
        }else{
            (self.childNode(withName: "Bkg")! as! SKSpriteNode).texture = SKTexture(imageNamed: "lose")
            //color = NSColor.init(red: 148, green: 17, blue: 0, alpha: 1)
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        let node = self.atPoint(location)
        if(node.name == "Restart")
        {
            Game.getGame().restart(self)
        }
    }
}
