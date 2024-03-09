//
//  GameScene.swift
//  ProjectBounce
//
//  Created by Michael Stang on 3/8/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var ball: SKShapeNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // My code below
        self.backgroundColor = .red;
        
        ball = SKShapeNode(circleOfRadius: 30);
        ball?.fillColor = .white;
        ball?.position = CGPoint(x: frame.midX, y: frame.midY)
        
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        ball?.physicsBody?.isDynamic = true
        ball?.physicsBody?.restitution = 1.0 // Bounciness factor
        ball?.physicsBody?.friction = 0.0
        ball?.physicsBody?.linearDamping = 0.0
        ball?.physicsBody?.allowsRotation = true
        ball?.physicsBody?.affectedByGravity = false
        
        if let ball = ball {
            addChild(ball)
        }
            
        // Adjust boundary to be slightly further away from the edge
        let insetRect = frame.insetBy(dx: 10.0, dy: 10.0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: insetRect)
            
        // Give the ball an initial push
        ball?.physicsBody?.applyImpulse(CGVector(dx: 20, dy: -20))
        
    }
    
    
    func touchDown(atPoint pos: CGPoint) {
        // Ensure the ball exists and has a physics body to apply force to
        guard let ball = self.ball, let ballPhysicsBody = ball.physicsBody else { return }
        
        // Calculate the distance between the touch point and the ball's position
        let distance = sqrt(pow(ball.position.x - pos.x, 2) + pow(ball.position.y - pos.y, 2))
        
        // Define a threshold for how close the touch must be to the ball to apply force
        let threshold: CGFloat = 50.0
        
        // Check if the distance is within the threshold
        if distance <= threshold {
            // Apply force to the ball
            ballPhysicsBody.applyForce(CGVector(dx: ball.path.dx * 10, dy: 100))
        }
    }

    
    func touchMoved(toPoint pos : CGPoint) {
        guard let ball = self.ball, let ballPhysicsBody = ball.physicsBody else { return }
        
        // Calculate the distance between the touch point and the ball's position
        let distance = sqrt(pow(ball.position.x - pos.x, 2) + pow(ball.position.y - pos.y, 2))
        
        // Define a threshold for how close the touch must be to the ball to apply force
        let threshold: CGFloat = 50.0
        
        // Check if the distance is within the threshold
        if distance <= threshold {
            // Apply force to the ball
            ballPhysicsBody.applyForce(CGVector(dx: 100, dy: 100))
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
