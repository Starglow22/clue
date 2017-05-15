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
    static let DOWN = CGFloat(-295)
    static let UP = CGFloat(340)
    
    var rootSprite: SKSpriteNode
    
    var selected: SKLabelNode?
    
    var up: Bool
    
    init(sprite: SKSpriteNode) {
        rootSprite = sprite
        up = false
        rootSprite.run(SKAction.moveTo(y: NoteCard.DOWN, duration: 0.4))
        rootSprite.texture = SKTexture(imageNamed: "notecard-up-texture")
    }
    
    func clicked()
    {
        up = !up
        if(up)
        {
            rootSprite.run(SKAction.moveTo(y: NoteCard.UP, duration: 0.4))
            rootSprite.texture = SKTexture(imageNamed: "notecard-down-texture")
        }else{
            rootSprite.run(SKAction.moveTo(y: NoteCard.DOWN, duration: 0.4))
            rootSprite.texture = SKTexture(imageNamed: "notecard-up-texture")
            clearSelected()
        }
    }
    
    func set(_ value: Bool)
    {
        up = value
        if(up)
        {
            rootSprite.run(SKAction.moveTo(y: NoteCard.UP, duration: 0.4))
            rootSprite.texture = SKTexture(imageNamed: "notecard-down-texture")
        }else{
            rootSprite.run(SKAction.moveTo(y: NoteCard.DOWN, duration: 0.4))
            rootSprite.texture = SKTexture(imageNamed: "notecard-up-texture")
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
