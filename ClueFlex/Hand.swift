//
//  Hand.swift
//  ClueFlex
//
//  Created by Gina Bolognesi on 2016-08-12.
//  Copyright © 2016 Gina Bolognesi. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            let i = Int((card.name?.substring(from: (card.name?.characters.index(before: (card.name?.endIndex)!))!))!)
            if(i > self.cards.count)
            {
                card.run(SKAction.hide())
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
            rootSprite.run(SKAction.moveTo(y: CGFloat(175), duration: 0.2))
        }else{
            rootSprite.run(SKAction.moveTo(y: CGFloat(-120), duration: 0.2))
        }
    }
    
    func getCard(_ node: SKNode) -> Card
    {
    
        let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)
        return cards[i!]
    }
}
