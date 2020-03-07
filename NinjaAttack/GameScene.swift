/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

// x and y offset
func + (left: CGPoint, right : CGPoint) -> CGPoint{
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left : CGPoint, right : CGPoint) -> CGPoint{
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point : CGPoint, scalar : CGFloat) -> CGPoint{
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point : CGPoint, scalar : CGFloat) -> CGPoint{
  return CGPoint(x: point.x / scalar, y : point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a : CGFloat) -> CGFloat{
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint{
  func length() -> CGFloat{
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint{
    return self / length()
  }
}

// struct - 물리 범주에 대한 상수들
struct PhysicsCategory {
  static let none : UInt32 = 0
  static let all : UInt32 = UInt32.max
  static let monster : UInt32 = 0b1
  static let projectile : UInt32 = 0b10
}

class GameScene: SKScene {
  // Adding sprite
  // 1
  let player = SKSpriteNode(imageNamed: "player")   // 캐릭터로 쓸 노드 생성
  
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.white   // 게임 배경 설정
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    // 3
    addChild(player)  // 캐릭터를 씬 에 추가
    
    // delegate
    physicsWorld.gravity = .zero        // no gravity
    physicsWorld.contactDelegate = self
    
    // Call the method to create monsters
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: 0.1)])))
  }
  
  // Moving Monsters
  func random() -> CGFloat{
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min : CGFloat, max : CGFloat) -> CGFloat{
    return random() * (max - min) + min
  }
  
  func addMonster() {
    // Create sprite
    let monster = SKSpriteNode(imageNamed: "monster")
    
    // Determine where to spawn the monster along the Y axis
    let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height / 2)
    
    // Position the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
    
    // add the monster to the scene
    addChild(monster)
    
    // setting monster physics
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)    // physicsbody 생성
    monster.physicsBody?.isDynamic = true   // 다이나믹 설정을 하면 sprite 의 움직임을 제어하지 않음..?
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none
    
    // determine spped of the monster
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // create the action
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))   // sprite 이동 처리
    let actionMoveDone = SKAction.removeFromParent()
    
    monster.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  // shooting
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else{return}
    let touchLocation = touch.location(in: self)
    
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position   // projectile을 player위치에 설정
    
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - projectile.position
    
    // 4 - Bail out if you are shooting down of backwards
    if offset.x < 0 {return}
    
    // 5 - OK to add now - you've double checked position
    addChild(projectile)
    
    // setting projectile physics
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    // 6 - Get the direction of where to shoot
    let direction = offset.normalized()
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
    
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + projectile.position
    
    // 9 - Create the actions
    let actionMode = SKAction.move(to: realDest, duration: 2.0)
    let actionModeDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMode, actionModeDone]))
  }
  
  func projectileDidCollideWithMonstr(projectile : SKSpriteNode, monster : SKSpriteNode){
    print("Hit")
    projectile.removeFromParent()
    monster.removeFromParent()
  }
}

extension GameScene : SKPhysicsContactDelegate{
  func didBegin(_ contact: SKPhysicsContact) {
    
  }
}
