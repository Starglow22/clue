//
//  NoteCard.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-08-11.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class NoteCard: NSObject {
    static let DEFAULT_COLOR = NSColor.white
    static let HIGHLIGHT_COLOR = NSColor.red
    
    var rootSprite: SKSpriteNode
    
    var selected: SKLabelNode?
    
    var up: Bool
    
    init(sprite: SKSpriteNode) {
        rootSprite = sprite
        up = false
    }
    
    func clicked()
    {
        up = !up
        if(up)
        {
            rootSprite.run(SKAction.moveTo(y: CGFloat(340), duration: 0.4))
        }else{
            rootSprite.run(SKAction.moveTo(y: CGFloat(-310), duration: 0.4))
            clearSelected()
        }
    }
    
    func selectBox(_ node: SKLabelNode)
    {
        if(node.name == "1" || node.name == "2" || node.name == "3" || node.name == "4")
        {
            selected = node
            selected?.fontColor = NoteCard.HIGHLIGHT_COLOR
        }
    }
    
    func clearSelected()
    {
        selected?.fontColor = NoteCard.DEFAULT_COLOR
        selected = nil
    }
    
    func handleKey(_ event: NSEvent)
    {
        if(selected != nil && event.characters != "" && event.characters != " ") // is vallid key
        {
            selected?.text = event.characters
        }
    }

}
