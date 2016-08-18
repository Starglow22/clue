//
//  Hand.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-08-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit

class Hand: NSObject {
    
    var rootSprite: SKSpriteNode
    var up: Bool
    let cards: [Card]
    
    init(sprite: SKSpriteNode, cards: [Card]) {
        rootSprite = sprite
        up = false
        self.cards = cards
        
        //1140 full width, card 150 - 900 just for cards, 30 for each small gap * 5 + 2 big gaps (45 each)
        rootSprite.size.width = CGFloat(60 + 180*self.cards.count) //90 + (150*self.cards.count) + 30*(self.cards.count - 1)
        
        
        var x = 0;
        for card in rootSprite.children
        {
            let i = Int((card.name?.substringFromIndex((card.name?.endIndex.predecessor())!))!)
            if(i > self.cards.count)
            {
                card.runAction(SKAction.hide())
            }else{
                let sprite = card as! SKSpriteNode
                sprite.texture = SKTexture(imageNamed: cards[x].imageName)
                x += 1

            }
        }
    }
    
    func clicked()
    {
        up = !up
        if(up)
        {
            rootSprite.runAction(SKAction.moveToY(CGFloat(175), duration: 0.2))
        }else{
            rootSprite.runAction(SKAction.moveToY(CGFloat(-120), duration: 0.2))
        }
    }
    
    func getCard(node: SKNode) -> Card
    {
    
        let i = Int((node.name?.substringFromIndex((node.name?.endIndex.predecessor())!))!)
        return cards[i!]
    }
}
