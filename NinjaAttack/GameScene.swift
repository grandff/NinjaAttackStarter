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
    
    // determine spped of the monster
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // create the action
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))   // sprite 이동 처리
    let actionMoveDone = SKAction.removeFromParent()
    
    monster.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
}