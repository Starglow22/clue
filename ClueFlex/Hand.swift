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
    var isBoard : Bool
    
    init(sprite: SKSpriteNode, cards: [Card], isBoard: Bool) {
        rootSprite = sprite
        up = false
        self.cards = cards
        self.isBoard = isBoard
        
        //1140 full width, card 150 - 900 just for cards, 30 for each small gap * 5 + 2 big gaps (45 each)
        rootSprite.size.width = CGFloat(60 + 180*self.cards.count) //90 + (150*self.cards.count) + 30*(self.cards.count - 1)
        
        rootSprite.position = CGPoint(x:0, y:175)
        for x in 0...rootSprite.children.count-1
        {
            let card = rootSprite.childNode(withName: "Card "+(x+1).description)!
            //let i = Int((card.name?.substring(from: (card.name?.characters.index(before: (card.name?.endIndex)!))!))!)
            if(x >= self.cards.count)
            {
                card.run(SKAction.hide())
            }else{
                let sprite = card as! SKSpriteNode
                sprite.texture = SKTexture(imageNamed: cards[x].imageName)
            }
        }
        
        if(isBoard)
        {
            up = false
            rootSprite.run(SKAction.moveTo(y: CGFloat(-150), duration: 0))
        }
    }
    
    func clicked(value: Bool?)
    {
        if(value != nil)
        {
            up = value!
        }else{
            up = !up
        }
        
        if(up)
        {
            rootSprite.run(SKAction.moveTo(y: CGFloat(175), duration: 0.2))
        }else{
            if(isBoard)
            {
                rootSprite.run(SKAction.moveTo(y: CGFloat(-150), duration: 0.2))
            }else{
            rootSprite.run(SKAction.moveTo(y: CGFloat(-120), duration: 0.2))
            }
        }
    }
    
    func getCard(_ node: SKNode) -> Card
    {
        // Cards named "Card 1" etc so want last char
        let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)! - 1
        return cards[i]
    }
}
