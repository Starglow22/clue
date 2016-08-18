//
//  NoteCard.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-08-11.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class NoteCard: NSObject {
    //var info: [String : [Character]]
    static let DEFAULT_COLOR = NSColor.whiteColor()
    static let HIGHLIGHT_COLOR = NSColor.redColor()
    
    var rootSprite: SKSpriteNode
    
    var selected: SKLabelNode?
    
    var up: Bool
    
    init(sprite: SKSpriteNode) {
        rootSprite = sprite
        up = false
        /*info = ["Miss Scarlett": [" ", " "," "," "], "Prof. Plum": [" ", " "," "," "], "Mrs Peacock": [" ", " "," "," "], "Mr Green": [" ", " "," "," "], "Col. Mustard": [" ", " "," "," "], "Mrs White": [" ", " "," "," "],
                
        "Candlestick": [" ", " "," "," "], "Knife": [" ", " "," "," "], "Lead Pipe": [" ", " "," "," "], "Revolver": [" ", " "," "," "], "Rope": [" ", " "," "," "], "Wrench": [" ", " "," "," "],
        
        "Kitchen": [" ", " "," "," "], "Ballroom": [" ", " "," "," "], "Conservatory": [" ", " "," "," "], "Dining room": [" ", " "," "," "], "Billard": [" ", " "," "," "], "Library": [" ", " "," "," "], "Lounge": [" ", " "," "," "], "Hall": [" ", " "," "," "], "Study": [" ", " "," "," "]]
 */
    }
    
    func clicked()
    {
        up = !up
        if(up)
        {
            rootSprite.runAction(SKAction.moveToY(CGFloat(340), duration: 0.4))
        }else{
            rootSprite.runAction(SKAction.moveToY(CGFloat(-310), duration: 0.4))
            clearSelected()
        }
    }
    
    func selectBox(node: SKLabelNode)
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
    
    func handleKey(event: NSEvent)
    {
        if(selected != nil && event.characters != "" && event.characters != " ") // is vallid key
        {
            selected?.text = event.characters
        }
    }

}
