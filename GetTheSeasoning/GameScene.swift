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
    var currentMessageLabel: SKLabelNode?
    
    // 画面が呼び出された時
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func setupGame() {
        // タイマー表示
        timerLabel = SKLabelNode(text: "タイム: 0秒")
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 130)
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
        bottle = SKSpriteNode(color: .brown, size: CGSize(width: 60, height:170))
        bottle.position = CGPoint(x: 00, y: 0)
        addChild(bottle)
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
        let location = touch.location(in: self)
        
        // ボトルがタッチされたかをチェック
        if bottle.contains(location) {
            bottle.removeFromParent() // ボトルを取った（消す）
            gameTimer?.invalidate() // タイマーを停止
            showMessage("醤油を取った！")
            stopTimer()
            
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
