//
//  GameScene.swift
//  Acorn_Drop
//
//  Created by Jesse Luangaphayvong on 11/8/19.
//  Copyright © 2019 Jesse Luangaphayvong. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerMovement: SKScene, SKPhysicsContactDelegate
{
    var contactQueue = [SKPhysicsContact]()
    //var backgroundPicture: SKEmitterNode
    var player : SKSpriteNode!
    var playerColor = UIColor.blue
    var backgroundColorCustom = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    var playerSize = CGSize(width: 50, height: 50)
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    
    var gameTimer:Timer!
    var possibleFallingObjects = ["acorn"]
    
    let acornCategory:UInt32 = 0x1 << 1
    let squirrelCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView)
    {
        physicsWorld.contactDelegate = self
        // set background
        // background = SKEmitterNode(fileNamed:"")
        self.backgroundColor = backgroundColorCustom
        spawnPlayer()
        spawnScoreLabel()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAcorn), userInfo: nil, repeats: true)
    }
    
    func spawnPlayer()
    {
        //first line is place holder, replace color with imageNamed: "FileString"
        player = SKSpriteNode(imageNamed: "Squirrel")
        player.name = "squirrel"
        //player.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 520)
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        
        player.physicsBody?.categoryBitMask = squirrelCategory
        player.physicsBody?.contactTestBitMask = acornCategory
        player.physicsBody?.collisionBitMask = 1
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(player)
    }
    
    func spawnScoreLabel()
    {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: self.frame.size.width/2.5 * -1, y: self.frame.size.height/2.3)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        scoreLabel.name = "score"
        self.addChild(scoreLabel)
    }
    
    func adjustScore(by points: Int)
    {
        score += points
        if let score = childNode(withName: "score") as? SKLabelNode
        {
            print("score \(score)")
            score.text = String(format: "Score: %01u", self.score)
        }
    }
    
    @objc func addAcorn()
    {
        let acorn = SKSpriteNode(imageNamed: "acorn-1")
        
        let randomAcornPosition = GKRandomDistribution(lowestValue: -414, highestValue: 414)
        let position = CGFloat(randomAcornPosition.nextInt())
        
        acorn.name = "acorn"
        acorn.size = CGSize(width: 50, height: 50)
        acorn.position = CGPoint(x: position, y: self.frame.size.height - acorn.size.height)
        
        acorn.physicsBody = SKPhysicsBody(circleOfRadius: acorn.size.width/2)
        acorn.physicsBody?.isDynamic = true
        
        acorn.physicsBody?.categoryBitMask = acornCategory
        acorn.physicsBody?.contactTestBitMask = squirrelCategory
        acorn.physicsBody?.collisionBitMask = 1
        
        self.addChild(acorn)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -acorn.size.height), duration: animationDuration))
        
        //actionArray.append(SKAction.removeFromParent())
        
        acorn.run(SKAction.sequence(actionArray))
    }
    
    func collisionBetween(acorn: SKNode, object: SKNode)
    {
        if object.name == "squirrel"
        {
            destroy(acorn : acorn)
        }
        else if (object.name == "acorn")
        {
            destroy(acorn : acorn)
        }
    }
    
    func destroy(acorn: SKNode)
    {
        acorn.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        contactQueue.append(contact)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            player.position.x = touchLocation.x
        }
    }
    
    func handle(_ contact: SKPhysicsContact)
    {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil
        {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if nodeNames.contains("acorn") && nodeNames.contains("squirrel")
        {
            adjustScore(by: 1)
            contact.bodyB.node!.removeFromParent()
        }
        else if nodeNames.contains("acorn") && nodeNames.contains("ground")
        {
            contact.bodyB.node!.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        processContacts(forUpdate: currentTime)
    }
    
    func processContacts(forUpdate currentTime: CFTimeInterval)
    {
        for contact in contactQueue
        {
            handle(contact)
            
            if let index = contactQueue.firstIndex(of: contact)
            {
                contactQueue.remove(at: index)
            }
        }
    }

}
