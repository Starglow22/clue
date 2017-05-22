//
//  Hand.swift
//  Clue
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
    static let DOWN_BOARD = CGFloat(-130)
    static let DOWN_ROOM = -120
    static let UP = 175
    
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
        rootSprite.size.width = CGFloat(60 + 180*self.cards.count)
        //100 = full width = 1140
        let ratio = rootSprite.size.width / 1140
        rootSprite.childNode(withName: "Title")!.position = CGPoint(x:50*ratio, y:43)
        rootSprite.childNode(withName: "Left arrow")!.position = CGPoint(x:5, y:43)
        rootSprite.childNode(withName: "Right arrow")!.position = CGPoint(x:95*ratio, y:43)
        rootSprite.childNode(withName: "Left arrow")!.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-up")))
        rootSprite.childNode(withName: "Right arrow")!.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-up")))
        
        rootSprite.position = CGPoint(x:0, y:Hand.UP)
        for x in 0...5
        {
            let card = rootSprite.childNode(withName: "Card \(x+1)")!
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
            rootSprite.run(SKAction.moveTo(y: Hand.DOWN_BOARD, duration: 0))
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
            rootSprite.run(SKAction.moveTo(y: CGFloat(Hand.UP), duration: 0.2))
            rootSprite.childNode(withName: "Left arrow")?.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-down")))
            rootSprite.childNode(withName: "Right arrow")?.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-down")))
        }else{
            if(isBoard)
            {
                rootSprite.run(SKAction.moveTo(y: CGFloat(Hand.DOWN_BOARD), duration: 0.2))
            }else{
            rootSprite.run(SKAction.moveTo(y: CGFloat(Hand.DOWN_ROOM), duration: 0.2))
            }
            rootSprite.childNode(withName: "Left arrow")?.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-up")))
            rootSprite.childNode(withName: "Right arrow")?.run(SKAction.setTexture(SKTexture(imageNamed: "arrow-up")))
        }
    }
    
    func getCard(_ node: SKNode) -> Card
    {
        // Cards named "Card 1" etc so want last char
        let i = Int((node.name?.substring(from: (node.name?.characters.index(before: (node.name?.endIndex)!))!))!)! - 1
        return cards[i]
    }
}
