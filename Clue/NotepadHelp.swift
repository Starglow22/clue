//
//  NotepadHelp.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-05-28.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class NotepadHelp: Help {
    
    override func text(_ scene: SKScene) -> String
    {
        return "Click on the bar marked “Notepad” to view and take notes on the information you have so far. Click on one of the spaces in the right columns then press a key to write in it."
    }
    
    override func hide(_ scene: SKScene)
    {
        scene.childNode(withName: ".//Notepad-Help")?.childNode(withName: "Help-text")?.run(SKAction.hide())
        displayed = false
    }
    
    override func display(_ scene: SKScene)
    {
        displayed = true
        let text = self.text(scene)
        
        addMultilineText(text: text, parent: scene.childNode(withName: ".//Notepad-Help")!.childNode(withName: "Help-text")!)
        scene.childNode(withName: ".//Notepad-Help")?.childNode(withName: "Help-text")?.run(SKAction.unhide())
        scene.childNode(withName: ".//Notepad-Help")?.childNode(withName: "Help-text")?.run(SKAction.move(to: scene.convert(CGPoint(x:600, y:760), to: scene.childNode(withName: "//Notepad-Help")!), duration: 0))
        
        }
}
