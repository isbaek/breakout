import SpriteKit
 
class GameScene: SKScene, SKPhysicsContactDelegate {
    let brick = SKShapeNode(rectOf: CGSize(width: 200, height: 50))
    let ball = SKShapeNode(circleOfRadius: 15)
    var isFingerOnPaddle = false

    
    // categories
    let BallCategory   : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let BrickCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        brick.name = "brick"
        brick.position = CGPoint(x: size.width/2 - 100, y: 50)
        brick.zPosition = 3
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
        brick.physicsBody!.friction = 0
        brick.physicsBody!.isDynamic = false
        brick.physicsBody!.restitution = 1
        addChild(brick)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.zPosition = 2
        ball.strokeColor = SKColor.white
        ball.fillColor = SKColor.white
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        ball.physicsBody!.affectedByGravity = false
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.friction = 0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.angularDamping = 0

        addChild(ball)
        ball.physicsBody!.applyImpulse(CGVector(dx: 10.0, dy: -10.0))
        

        // Bottom of the screen
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        

        // Barrier around the screen
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        // set up category bit masks
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        brick.physicsBody!.categoryBitMask = BrickCategory
        borderBody.categoryBitMask = BorderCategory
        
        // ball touched bottom of the screen
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory
        
        // set up blocks
        let blockWidth = CGFloat(50)
        let numOfBlocks = 6
        let totalBlocksWidth = blockWidth * CGFloat(numOfBlocks)
        let xOffset = (frame.width - totalBlocksWidth) / 2
        for i in 0..<numOfBlocks {
          let block = SKShapeNode(rectOf: CGSize(width: blockWidth, height: 20))
          block.name = "block"
          block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth,
            y: frame.height * 0.8)
          block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
          block.physicsBody!.allowsRotation = false
          block.physicsBody!.friction = 0.0
          block.physicsBody!.affectedByGravity = false
          block.physicsBody!.isDynamic = false

          block.physicsBody!.categoryBitMask = BlockCategory
          block.zPosition = 2
          addChild(block)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
          
        if let body = physicsWorld.body(at: touchLocation) {
          if body.node!.name == "brick" {
            print("Began touch on brick")
            isFingerOnPaddle = true
          }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle {
          let touch = touches.first
          let touchLocation = touch!.location(in: self)
          let previousLocation = touch!.previousLocation(in: self)
          let brick = childNode(withName: "brick") as! SKShapeNode
          var brickX = brick.position.x + (touchLocation.x - previousLocation.x)

            brickX = max(brickX, brick.frame.width/2)
            brickX = min(brickX, size.width - brick.frame.width/2)
            brick.position = CGPoint(x: brickX, y: brick.position.y)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          isFingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
        print("Hit bottom. First contact has been made.")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            print("Hit block. Block should break")
            secondBody.node!.removeFromParent()
          //TODO: check if the game has been won
        }
    }
    
    func breakBlock(node: SKNode) {
      let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
      particles.position = node.position
      particles.zPosition = 3
      addChild(particles)
      particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
        SKAction.removeFromParent()]))
      node.removeFromParent()
    }
}
