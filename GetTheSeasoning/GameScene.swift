//
//  GameScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/23.
//

import SpriteKit

class GameScene: SKScene {
    
    var bottle: SKSpriteNode!
    var timerLabel: SKLabelNode!
    var gameTimer: Timer?
    var messageTimer: Timer?
    var elapsedTime: TimeInterval = 0
    
    // 画面が呼び出された時
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        // タイマー表示
        timerLabel = SKLabelNode(text: "タイム: 0秒")
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(timerLabel)
        
        // 最初に醤油を表示
        spawnSoysauce()

        // 指示
        startMessageTimer()
    }
    
    func spawnSoysauce() {
        // 醤油を新しい位置に生成
//        let randomX = CGFloat.random(in: 0...frame.width)
//        let randomY = CGFloat.random(in: 0...frame.height)
        bottle = SKSpriteNode(color: .brown, size: CGSize(width: 50, height: 100))
        bottle.position = CGPoint(x: 100, y: 200)
        addChild(bottle)
    }
    
    func showMessage(_ message: String) {
        let messageLabel = SKLabelNode(text: message)
        messageLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(messageLabel)
        
        // 一定時間後にメッセージを消す
        let wait = SKAction.wait(forDuration: 2.0)
        let remove = SKAction.removeFromParent()
        messageLabel.run(SKAction.sequence([wait, remove]))
    }
    
    func startMessageTimer() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            let randomDelay = Double.random(in: 5.0...7.0)
            self?.showMessage("醤油取って！")
            // 次のメッセージ表示のために、再度タイマーを設定
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                self?.startMessageTimer()
            }
        }
    }
    
    func startTimer() {
        elapsedTime = 0
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.timerLabel.text = "タイム: \(Int(self?.elapsedTime ?? 0))秒"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // ボトルがタッチされたかをチェック
        if bottle.contains(location) {
            bottle.removeFromParent() // ボトルを取った（消す）
            gameTimer?.invalidate() // タイマーを停止
            showMessage("醤油を取った！")
            
            // 新しい醤油を表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.spawnSoysauce()
            }
        }
    }
    
    override func willMove(from view: SKView) {
        // タイマーを無効化
        gameTimer?.invalidate()
        messageTimer?.invalidate()
    }
}
