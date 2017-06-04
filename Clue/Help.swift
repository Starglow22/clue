//
//  Help.swift
//  Clue
//
//  Created by Gina Bolognesi on 2017-05-01.
//  Copyright © 2017 Gina Bolognesi. All rights reserved.
//


import SpriteKit

class Help {
    
    var displayed = false
    
    func clicked(_ scene: SKScene)
    {
        if(displayed)
        {
            hide(scene)
        }else{
            display(scene)
        }
    }
    
    func hide(_ scene: SKScene)
    {
        scene.childNode(withName: "Help")?.childNode(withName: "Help-text")?.run(SKAction.hide())
        displayed = false
    }
    
    func text(_ scene: SKScene) -> String
    {
        if(scene is StartScene)
        {
            return "You were invited to a grand dinner party, but unfortunately your host was murdered! In the most cliché of situations, you and the other guests are stuck at the mansion due to a strong storm. For your own safety and to pass the time, you must now attempt to find the culprit, murder weapon and murder scene by suspecting combinations and seeing if any of your fellow guests can prove you wrong. The culprit could be anyone, even you! Once you think you know the answer, accuse the culprit with the weapon in the correct room, but you only get one shot at accusing. You may click this button at any time during the game to get help with what you need to do at that moment."
        }else if(scene is MenuScene)
        {
            return "Choose how many computerized players you want to play against, how clever you want the opposition to be, and your character to start a game."
        }else if(scene is BoardScene)
        {
            switch Game.getGame().state
            {
            case State.waitingForTurn:
                return "Click on the bar marked “Hand Cards” to view the people, weapons and locations you know aren’t involved in the murder. Click on the bar marked “Notepad” to view and take notes on the information you have so far."
                
            case State.waitingForDieRoll:
                return "Click on the die to roll it."
                
            case State.waitingForMoveDestination:
                return "Select your destination. You cannot move diagonally or through tiles occupied by other players, though any number of people can be in a room at any time. You may not return to a room within 2 turns of entering it. Being a grand old mansion, there are also secret passages connecting the most distant rooms."
                
            default: return ""
            }
        }else{
            switch Game.getGame().state
            {
            case State.waitingForSuspectOrAccuse:
                return "Choose whether you want to suspect, i.e. guess and be shown a piece of evidence by another player, or accuse if you think you know the solution. Be careful, you only get one shot at accusing! Be aware that you do not get to select the room, you must be in the room where you believe the crime has taken place in order to accuse. Click on the bar marked “Hand Cards” to view the people, weapons and locations you know aren’t involved in the murder."
                
            case State.waitingForQuestion:
                return "Select a combination of a person and a weapon you would like to suspect in this room and ask more information about, or to accuse if you chose to do so. When asking a question the player after you will attempt to answer first, and if they cannot show you any evidence the question passes on in play order. Click on the bar marked “Hand Cards” to view the people, weapons and locations you know aren’t involved in the murder. Remeber, all characters can be the murderer, even you!"
                
            case State.waitingForDoneWithNoteTaking:
                return "Click on the bar marked “Notecard” to view and take notes on the information you have so far. Click on one of the spaces in the right columns then press a key to write. Return to the board when you are ready to continue the game."
                
            case State.waitingForAnswer:
                return "Another player is asking for information. If you have evidence that can prove their suspicion wrong, you must show one piece of evidence to them (click on the card). If you do not, the question will be passed on to the next player in turn order."
                
            default: return ""
            }
            
        }

    }
    
    func display(_ scene: SKScene)
    {
        displayed = true
        let text = self.text(scene)
        
        addMultilineText(text: text, parent: scene.childNode(withName: "Help")!.childNode(withName: "Help-text")!)
        scene.childNode(withName: "Help")?.childNode(withName: "Help-text")?.run(SKAction.unhide())
        
    }
    
    //adapted from https://xcodenoobies.blogspot.ca/2014/12/multiline-sklabelnode-hell-yes-please-xd.html
    func addMultilineText(text: String, parent: SKNode)
    {
        let bkg = parent.childNode(withName: "Help-bkg")! as! SKSpriteNode
        parent.removeAllChildren()
        
        // y pos of first line
        var yCoord = CGFloat(20)
        // parse through the string and put each words into an array.
        let separators = NSCharacterSet.whitespaces
        let words = text.components(separatedBy: separators)
        let width = 80; // specify your own width to fit the device screen
        // get the number of labelnode we need.
        var currentWordIndex = 0; // used to parse through the words array
        var maxWidth = 0
        var lineNum = 0
        // here is the for loop that create all the SKLabelNode that we need to
        // display the string.
        while currentWordIndex < words.count - 1
        {
            var charsInLine = 0
            var lineStr = ""
            while charsInLine < width
            {
                if currentWordIndex > words.count-1
                {
                    break
                }
                else
                {
                    lineStr = " \(lineStr) \(words[currentWordIndex])"
                    charsInLine = lineStr.characters.count
                    currentWordIndex+=1
                }
            }
            // creation of the SKLabelNode itself
            let multiLineLabel = SKLabelNode(fontNamed: "Helvetica Neue Thin")
            parent.addChild(multiLineLabel)
            multiLineLabel.text = lineStr;
            multiLineLabel.zPosition = 1
            // name each label node so you can animate it
            multiLineLabel.name = "line\(lineNum)"
            multiLineLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            multiLineLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            multiLineLabel.fontSize = 32;
            multiLineLabel.fontColor = NSColor.white
            yCoord = yCoord-40
            multiLineLabel.position = CGPoint(x:0 , y:CGFloat(yCoord))
            
            lineNum += 1
            if(charsInLine > maxWidth)
            {
                maxWidth = charsInLine
            }
        }
        parent.addChild(bkg)
        bkg.position = CGPoint(x: 0, y: 0)
        bkg.size.width = CGFloat(maxWidth * 15 + 30)
        bkg.size.height = CGFloat(lineNum + 1)*40
    }
    
}
