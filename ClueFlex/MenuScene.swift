//
//  GameScene.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-07-10.
//  Copyright (c) 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var lastClicked: SKNode?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        for child in self.children
        {
            child.alpha = 0.0;
        }
        
        fadePlayerIcons()
        resizeCharacterIcons()
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        var numPlayers = 0
        var difficulty = 0
        var characterName: String
        
        
        
        let location = theEvent.locationInNode(self)
        let node = self.nodeAtPoint(location)
        if(lastClicked != node)
        {
        switch node.name {
        case "P1"?:
                selectNode(node)
                numPlayers = 1
            
        case "P2"?:
                selectNode(node)
                numPlayers = 2
            
        case "P3"?:
            selectNode(node)
                numPlayers = 3
            
        case "P4"?:
                selectNode(node)
                numPlayers = 4
            
        case "P5"?:
                selectNode(node)
                numPlayers = 5
            
        case "D1"?, "D2"?, "D3"?, "D4"?, "D5"?, "D6"?, "D7"?, "D8"?, "D9"?, "D10"?:
            resetNumbers()
             let label = node as? SKLabelNode
            label?.fontSize = 64
            difficulty = ((label?.text)! as NSString).integerValue
            
        case "C1"?:
            selectCharacter(node)
            characterName = "red"
            
        case "C2"?:
            selectCharacter(node)
            characterName = "blue"
            
        case "C3"?:
            selectCharacter(node)
            characterName = "green"
            
        case "C4"?:
            selectCharacter(node)
            characterName = "yellow"
            
        case "C5"?:
            selectCharacter(node)
            characterName = "lilac"
            
        case "C6"?:
            selectCharacter(node)
            characterName = "cyan"
            
            
        default: break
            // do nothing
            }
            
        }
        lastClicked = node
        
    }
    
    func selectCharacter(node: SKNode)
    {
        resizeCharacterIcons()
       node.runAction(SKAction.scaleTo(1.4, duration: 0.1))
    }
    
    func resetNumbers()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("D") == true)
            {
                let label = node as? SKLabelNode
                label?.fontSize = 32
            }
            
        }
    }
    
    func selectNode(node: SKNode)
    {
        fadePlayerIcons()
        node.runAction(SKAction.colorizeWithColor(NSColor.redColor(), colorBlendFactor: 0.5, duration: 0.1))
    }
    
    func fadePlayerIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("P") == true)
            {
                node.runAction(SKAction.colorizeWithColor(NSColor.clearColor(), colorBlendFactor: 0.5, duration: 0.1))
            }
            
        }
    }
    
    func resizeCharacterIcons()
    {
        for node in self.children
        {
            if(node.name?.hasPrefix("C") == true)
            {
                node.runAction(SKAction.scaleTo(1.0, duration: 0.1))
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
