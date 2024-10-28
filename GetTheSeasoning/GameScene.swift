//
//  GameScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/23.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var audioPlayer: AVAudioPlayer?
    
    var desk: SKSpriteNode!
    var arm: SKSpriteNode!
    var soysauce: SKSpriteNode!
    var messageImage: SKSpriteNode!
    
    var timerLabel: SKLabelNode!
    var bestTime: TimeInterval = Double.greatestFiniteMagnitude
    var bestTimeLabel: SKLabelNode!
    var currentMessageLabel: SKLabelNode?
    var resetButton: SKLabelNode!
    
    var gameTimer: Timer?
    var messageTimer: Timer?
    var elapsedTime: TimeInterval = 0
    
    var isIndicatingFlag: Bool = false
    
    // スワイプ開始位置
    var swipeStartPosition: CGPoint?
    
    struct PhysicsCategory {
        static let arm: UInt32 = 0x1 << 0 // 腕のカテゴリ
        static let soySauce: UInt32 = 0x1 << 1 // 醤油のカテゴリ
    }
    
    // 画面が呼び出された時
    override func didMove(to view: SKView) {
        playBackgroundMusic()
        
        self.scaleMode = .aspectFill

        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // 重力無し
        physicsWorld.contactDelegate = self // 衝突判定を使用するために
        setupResetButton()
        setupGame()
    }
    
    func playBackgroundMusic() {
        // 音声ファイルのパスを取得
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else {
            print("BGM file not exist")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // -1:無限ループ
            audioPlayer?.volume = 0.1
            audioPlayer?.play()
        } catch {
            print("error Playing BGM: \(error.localizedDescription)")
        }
    }
    
    func setupGame() {
        // 机
        let deskTexture = SKTexture(imageNamed: "desk")
        desk = SKSpriteNode(texture: deskTexture, size: CGSize(width: 550, height: 600))
        desk.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        desk.zPosition = 0
        addChild(desk)
        
        // タイム計測
        timerLabel = SKLabelNode(text: "タイム: 0秒")
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 170)
        timerLabel.fontSize = 40
        timerLabel.fontColor = SKColor.white
        addChild(timerLabel)
        
        // 最高タイム
        bestTimeLabel = SKLabelNode(text: "最高タイム:")
        bestTimeLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 250)
        bestTimeLabel.fontSize = 40
        bestTimeLabel.fontColor = SKColor.yellow
        addChild(bestTimeLabel)
        
        // 腕を表示
        let armTexture = SKTexture(imageNamed: "arm")
        arm = SKSpriteNode(texture: armTexture, size: CGSize(width: 150, height: 300))
        arm.position = CGPoint(x: frame.midX, y: frame.midY - 400)
        arm.zPosition = 2
        // 腕に物理ボディを追加
        arm.physicsBody = SKPhysicsBody(texture: armTexture, size: arm.size)
        arm.physicsBody?.isDynamic = true
        arm.physicsBody?.categoryBitMask = PhysicsCategory.arm
        arm.physicsBody?.contactTestBitMask = PhysicsCategory.soySauce
        arm.physicsBody?.collisionBitMask = PhysicsCategory.soySauce
        addChild(arm)
        
        // 醤油を表示(初回)
        spawnSoysauce()
        // 指示
        startMessageTimer()
    }
    
    // リセットボタン
    func setupResetButton() {
        let background = SKSpriteNode(color: SKColor.gray, size: CGSize(width: 120, height: 50))
        background.position = CGPoint(x: frame.midX + 200, y: frame.maxY - 75)
        addChild(background)

        resetButton = SKLabelNode(text: "リセット")
        resetButton.position = CGPoint(x: frame.midX + 200, y: frame.maxY - 85)
        resetButton.fontSize = 30
        resetButton.fontColor = SKColor.white
        addChild(resetButton)
    }
    
    // 醤油を生成
    func spawnSoysauce() {
        let soysauceTexture = SKTexture(imageNamed: "soysauce")
        soysauce = SKSpriteNode(texture: soysauceTexture, size: CGSize(width: 170, height: 200))
        soysauce.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        soysauce.zPosition = 1
        
        // 醤油に物理ボディを追加
        soysauce.physicsBody = SKPhysicsBody(texture: soysauceTexture, size: soysauce.size)
        soysauce.physicsBody?.isDynamic = true
        soysauce.physicsBody?.categoryBitMask = PhysicsCategory.soySauce
        soysauce.physicsBody?.contactTestBitMask = PhysicsCategory.arm  // 接触したときに腕に通知
        soysauce.physicsBody?.collisionBitMask = PhysicsCategory.arm    // 腕と背色すると衝突として判定される
        soysauce.name = "soysauce"
        addChild(soysauce)
    }
    
    func showMessage(_ message: String) {
        // 前回のメッセージを削除
        currentMessageLabel?.removeFromParent()
        
        let messageLabel = SKLabelNode(text: message)
        messageLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 350)
        messageLabel.fontSize = 40
        messageLabel.fontColor = SKColor.white
        messageLabel.zPosition = 2
        addChild(messageLabel)
        // 現在のメッセージ
        currentMessageLabel = messageLabel
    }
    
    func startMessageTimer() {
        // 指示中でないなら指示を行う
        guard !isIndicatingFlag else { return }
        isIndicatingFlag = true;

        let interval = Double.random(in: 6.0...8.0);
        messageTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // メッセージの吹き出し
            let messageImageTexture = SKTexture(imageNamed: "messageImage")
            messageImage = SKSpriteNode(texture: messageImageTexture, size: CGSize(width: 450, height: 110))
            messageImage.position = CGPoint(x: frame.midX, y: frame.maxY - 330)
            if let messageImage = self.messageImage {
                self.messageImage.zPosition = 1
                self.addChild(messageImage)
            }
            self.showMessage("醤油取って！")
            self.startTimer()
        }
    }
    
    // タイム計測
    func startTimer() {
        print("タイム計測START!!")
        gameTimer?.invalidate()

        elapsedTime = 0
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.01
            self?.timerLabel.text = String(format: "タイム: %.2f秒", self?.elapsedTime ?? 0)
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    // 接触を始めたときに呼び出される
    func didBegin(_ contact: SKPhysicsContact) {
        // 醤油を掴んでる間は処理を行わない
        if let existSoysauce = arm.children.first(where: { $0.name == "soysauce" }) {
            return
        }

        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        // 腕と醤油が接触したとき
        let isContact = (bodyA.categoryBitMask == PhysicsCategory.arm && bodyB.categoryBitMask ==           PhysicsCategory.soySauce) || (bodyA.categoryBitMask == PhysicsCategory.soySauce && bodyB.categoryBitMask == PhysicsCategory.arm)
        if isContact {
            if let soyNode = bodyB.categoryBitMask == PhysicsCategory.soySauce ? bodyB.node : bodyA.node {
                // 醤油を手に固定
                soyNode.removeFromParent()
                arm.addChild(soyNode)
                // TODO 醤油が離れた位置に固定されてしまう
                soyNode.position = CGPoint(x: arm.position.x, y: arm.position.y + 100)
                soyNode.physicsBody?.isDynamic = false
                soyNode.name = "soysauce"
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // スワイプ開始位置
        swipeStartPosition = touch.location(in: self)
        
        // リセットボタン
        if resetButton.contains(location) {
            resetGame() // リセット処理を呼び出す
        }
    }
    
    func resetGame() {
        currentMessageLabel?.removeFromParent()
        messageImage?.removeFromParent()
        elapsedTime = 0
        timerLabel.text = String(format: "タイム: %.2f秒", elapsedTime)
        stopTimer()
        bestTimeLabel.text = "最高タイム:"
        arm.position = CGPoint(x: frame.midX, y: -400)
        resetArmPosition()
        // 醤油の初期化
        if let soyNode = arm.childNode(withName: "soysauce") {
            isIndicatingFlag = false;
            soyNode.removeFromParent()
            self.spawnSoysauce()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPosition = swipeStartPosition else { return }
        let currentPosition = touch.location(in: self)

        // スワイプに合わせて腕を移動
        if arm.contains(currentPosition) {
            let diffX = currentPosition.x - startPosition.x
            let diffY = currentPosition.y - startPosition.y
            let newPosition = CGPoint(x: arm.position.x + diffX, y: arm.position.y + diffY)
            arm.position = newPosition
        }
        
        // 醤油を掴んだ状態で下部に到達したら取ったことにする
        if let soyNode = arm.children.first(where: { $0.name == "soysauce" }) {
            let soyNodeGlobalPosition = soyNode.convert(soyNode.position, to: self) // グローバル座標に変換
            if soyNodeGlobalPosition.y < frame.minY + (frame.height / 3.3) {
                removeSoysauce()
            }
        }
    
        // スワイプ開始位置を更新
        swipeStartPosition = currentPosition
    }
    
    func removeSoysauce() {
        if let soyNode = arm.childNode(withName: "soysauce") {
            soyNode.removeFromParent()
        }

        // メッセージ吹き出しを削除
        messageImage?.removeFromParent()
        if elapsedTime < 0.5 {
            showMessage("早すぎぃ！")
        } else if elapsedTime < 1 {
            showMessage("早い！")
        } else if elapsedTime > 3 {
            showMessage("遅い！")
        } else {
            showMessage("ありがとう！")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentMessageLabel?.removeFromParent()
            self.currentMessageLabel = nil
        }
        
        // 最高タイムの更新
        if elapsedTime < bestTime {
            bestTime = elapsedTime
            bestTimeLabel.text = String(format: "最高タイム: %.2f秒", bestTime)
        }
        
        // 指示中フラグの解除
        isIndicatingFlag = false;
        // 腕を初期位置に戻す
        resetArmPosition()
        // タイマーを初期化
        elapsedTime = 0
        timerLabel.text = String(format: "タイム: %.2f秒", elapsedTime)
        stopTimer()

        // 2秒後に醤油を再生成
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.spawnSoysauce()
        }
    }
    
    func resetArmPosition() {
        // 腕を初期位置に戻す
        arm.position = CGPoint(x: frame.midX, y: frame.midY - 400)
        arm.zRotation = 0
    }
    
    override func willMove(from view: SKView) {
        // タイマーを無効化
        gameTimer?.invalidate()
        messageTimer?.invalidate()
    }
}
