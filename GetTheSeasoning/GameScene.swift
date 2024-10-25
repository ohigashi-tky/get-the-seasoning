//
//  GameScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/23.
//

import SpriteKit

class GameScene: SKScene {
    
    var arm: SKSpriteNode!
    var soysauce: SKSpriteNode!
    var timerLabel: SKLabelNode!
    var gameTimer: Timer?
    var messageTimer: Timer?
    var elapsedTime: TimeInterval = 0
    var currentMessageLabel: SKLabelNode?
    
    // スワイプ開始位置
    var swipeStartPosition: CGPoint?
    
    // 画面が呼び出された時
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        // タイマー表示
        timerLabel = SKLabelNode(text: "タイム: 0秒")
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 130)
        addChild(timerLabel)
        
        // 腕を表示
        let armTexture = SKTexture(imageNamed: "arm")
        arm = SKSpriteNode(texture: armTexture, size: CGSize(width: 150, height: 300))
        arm.position = CGPoint(x: 0, y: -100)
        addChild(arm)
        
        // 醤油を表示(初回)
        spawnSoysauce()
        // 指示
        startMessageTimer()
    }
    
    func spawnSoysauce() {
        // 醤油を新しい位置に生成
//        let randomX = CGFloat.random(in: 0...frame.width)
//        let randomY = CGFloat.random(in: 0...frame.height)
        let soysauceTexture = SKTexture(imageNamed: "soysauce")
        soysauce = SKSpriteNode(texture: soysauceTexture, size: CGSize(width: 170, height: 200))
        soysauce.position = CGPoint(x: 0, y: 0)
        addChild(soysauce)
    }
    
    func showMessage(_ message: String) {
        // 前回のメッセージを削除
        currentMessageLabel?.removeFromParent()
        
        let messageLabel = SKLabelNode(text: message)
        messageLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 250)
        addChild(messageLabel)
        // 現在のメッセージ
        currentMessageLabel = messageLabel

        // 一定時間後にメッセージを消す
        let wait = SKAction.wait(forDuration: 2.0)
        let remove = SKAction.removeFromParent()
        messageLabel.run(SKAction.sequence([wait, remove])) {
            self.currentMessageLabel = nil
        }
    }
    
    func startMessageTimer() {
        let interval = Double.random(in: 5.0...7.0);
        messageTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.showMessage("醤油取って！")
            self?.startTimer()
        }
    }
    
    func startTimer() {
        // 既存のゲームタイマーを無効化
        gameTimer?.invalidate()
        
        elapsedTime = 0
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.01
            self?.timerLabel.text = String(format: "タイム: %.2f秒", self?.elapsedTime ?? 0)
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate() // タイマーを無効化
        gameTimer = nil // タイマーをnilにする
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        swipeStartPosition = touch.location(in: self)

//        let location = touch.location(in: self)
//        // 醤油がタッチされたかをチェック
//        if soysauce.contains(location) {
//            soysauce.removeFromParent() // 醤油を取った（消す）
//            gameTimer?.invalidate() // タイマーを停止
//            showMessage("醤油を取った！")
//            stopTimer()
//            
//            // 新しい醤油を表示
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.spawnSoysauce()
//            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPosition = swipeStartPosition else { return }
        let currentPosition = touch.location(in: self)
        
        // スワイプに合わせて腕を移動
        let deltaX = currentPosition.x - startPosition.x
        let deltaY = currentPosition.y - startPosition.y
        let newPosition = CGPoint(x: arm.position.x + deltaX, y: arm.position.y + deltaY)
        arm.position = newPosition
        
        // スワイプ開始位置を更新
        swipeStartPosition = currentPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // スワイプの終点で醤油に触れたかをチェック
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if soysauce.contains(location) {
            soysauce.removeFromParent()
            gameTimer?.invalidate()
            showMessage("醤油を取った！")
            stopTimer()
            
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
