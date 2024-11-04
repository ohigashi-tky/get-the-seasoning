//
//  GameScene.swift
//  GetTheSeasoning
//
//  Created by 大東拓也 on 2024/10/23.
//

import SpriteKit
import AVFoundation
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?
    
    var flooring: SKSpriteNode!
    var monitor: SKSpriteNode!
    var desk: SKSpriteNode!
    var mother: SKSpriteNode!
    var father: SKSpriteNode!
    var arm: SKSpriteNode!
    var soysauce: SKSpriteNode!
    var messageImage: SKSpriteNode!
    
    var talker: Int!
    
    var playCount: Int = 0
    let oneGamePlayCount: Int = 3
    
    var isArmMoveRestriction: Bool = true  // 腕のY軸移動制限
    
    var timerLabel: SKLabelNode!
    var bestTime: TimeInterval = Double.greatestFiniteMagnitude
    var bestTimeLabel: SKLabelNode!
    var totalTimeLabel: SKLabelNode!
    var currentMessageLabel: SKLabelNode?
    var returnButton: SKShapeNode!
    var resetButton: SKShapeNode!
    var closeButtonBg: SKShapeNode!
    var rankingButtonBg: SKShapeNode!
    
    var gameTimer: Timer?
    var messageTimer: Timer?
    var elapsedTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    
    var isIndicatingFlag: Bool = false  // 指示中フラグ
    var isHoldingSoy: Bool = false // 醤油を掴んでいるかどうかを追跡
    
    var label : SKLabelNode?
    var spinnyNode : SKShapeNode?
    
    var resultDialog: SKSpriteNode?
    
    // スワイプ開始位置
    var swipeStartPosition: CGPoint?
    
    struct PhysicsCategory {
        static let arm: UInt32 = 0x1 << 0 // 腕のカテゴリ
        static let soySauce: UInt32 = 0x1 << 1 // 醤油のカテゴリ
        static let wall: UInt32 = 0x1 << 2 // 壁のカテゴリ
        static let cooking: UInt32 = 0x1 << 2
    }
    
    // 定数
    enum addPosition {
        static let messageBgLeft: (x: CGFloat, y: CGFloat) = (-150, -285)
        static let messageBgRight: (x: CGFloat, y: CGFloat) = (150, -285)
        static let messageLabelLeft: (x: CGFloat, y: CGFloat) = (-150, -300)
        static let messageLabelRight: (x: CGFloat, y: CGFloat) = (150, -300)
    }
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFill

        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // 重力無し
        physicsWorld.contactDelegate = self // 衝突判定を使用するために
        setupReturnButton()
        setupResetButton()
        setupGame()
    }

    func createObject(textureName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, isAddChild: Bool = true) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName)
        let spriteNode = SKSpriteNode(texture: texture, size: size)
        spriteNode.position = position
        spriteNode.zPosition = zPosition
        if isAddChild { addChild(spriteNode) }
        return spriteNode
    }
    
    func setupGame() {
        // 上部の透明な壁
        createInvisibleWall()

        // 床
        _ = createObject(textureName: "flooring", size: CGSize(width: 750, height: 1334), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: -2)
        
        // モニター
        _ = createObject(textureName: "monitor", size: CGSize(width: 570, height: 650), position: CGPoint(x: frame.midX, y: frame.maxY - 280), zPosition: -1)
        
        // 机
        _ = createObject(textureName: "desk", size: CGSize(width: 550, height: 600), position: CGPoint(x: frame.midX, y: frame.midY - 50), zPosition: 0)
        
        // 料理（障害物）
        createCookingObject()
        
        // お父さん
        _ = createObject(textureName: "father", size: CGSize(width: 400, height: 400), position: CGPoint(x: frame.midX - 150, y: frame.midY - 500), zPosition: 0)
        
        // お母さん
        _ = createObject(textureName: "mother", size: CGSize(width: 400, height: 400), position: CGPoint(x: frame.midX + 150, y: frame.midY - 500), zPosition: 0)
        
        // タイム計測
        timerLabel = SKLabelNode(text: "タイム: 0秒")
        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 180)
        timerLabel.fontSize = 40
        timerLabel.fontColor = SKColor.white
        addChild(timerLabel)
        
        // 最高タイム
        bestTimeLabel = SKLabelNode(text: "最高タイム:")
        bestTimeLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 260)
        bestTimeLabel.fontSize = 40
        bestTimeLabel.fontColor = SKColor.yellow
        addChild(bestTimeLabel)

        // 合計タイム(1ゲーム)
        totalTimeLabel = SKLabelNode(text: "合計タイム:")
        totalTimeLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 340)
        totalTimeLabel.fontSize = 40
        totalTimeLabel.fontColor = SKColor.green
        addChild(totalTimeLabel)

        // 腕を表示
        let armTexture = SKTexture(imageNamed: "arm")
        arm = SKSpriteNode(texture: armTexture, size: CGSize(width: 150, height: 300))
        arm.position = CGPoint(x: frame.midX, y: frame.midY - 400)
        arm.zPosition = 2
        // 腕に物理ボディを追加
        arm.physicsBody = SKPhysicsBody(texture: armTexture, size: arm.size)
        arm.physicsBody?.isDynamic = true
//        arm.physicsBody?.allowsRotation = false // 回転しない 動作が若干不安定になる
        arm.physicsBody?.categoryBitMask = PhysicsCategory.arm
//        arm.physicsBody?.contactTestBitMask = PhysicsCategory.soySauce | PhysicsCategory.wall
//        arm.physicsBody?.collisionBitMask = PhysicsCategory.soySauce | PhysicsCategory.wall
        arm.physicsBody?.contactTestBitMask = 0
        arm.physicsBody?.collisionBitMask = 0
        arm.physicsBody?.restitution = 0.0 // 衝突時の反発
        arm.physicsBody?.friction = 0.0 // 摩擦
        addChild(arm)
        
        // 醤油を表示(初回)
        spawnSoysauce()
        // 指示
        startMessageTimer()
    }
    
    // 机の上の料理を生成（ランダム）
    func createCookingObject() {
        let cookingNames: [String] = [
              "pasuta_meat"
            , "medamayaki"
            , "sanma"
            , "korokke"
            , "syougayaki"
            , "rice"
            , "tonnjiru"
            , "udon"
        ]
        // 生成する範囲
        
        // 料理一覧をループして生成
        for (index, cookingName) in cookingNames.enumerated() {
            let addXPos = if index < 4 { index * 145 } else { (index - 4) * 145 };
            let addYPos = if index < 4 { 0 } else { 150 };
            // 障害物として定義
            _ = createSKPhysicsBody(textureName: cookingName, size: CGSize(width: 135, height: 110), position: CGPoint(x: frame.minX + CGFloat(160 + addXPos), y: frame.midY - CGFloat(35 + addYPos)), zPosition: 1, category: PhysicsCategory.soySauce)
        }
    }
    
    // 衝突判定有りの物体を生成
    func createSKPhysicsBody(textureName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, category: UInt32, isAddChild: Bool = true) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName)
        let spriteNode = SKSpriteNode(texture: texture, size: size)
        spriteNode.position = position
        spriteNode.zPosition = zPosition
        spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
        spriteNode.physicsBody?.isDynamic = true
        spriteNode.physicsBody?.categoryBitMask = PhysicsCategory.cooking
        spriteNode.physicsBody?.contactTestBitMask = category   // 接触したときの通知先
        spriteNode.physicsBody?.collisionBitMask = category    // 指定した物体と衝突判定
        if isAddChild { addChild(spriteNode) }

        return spriteNode
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 腕の位置を制限する
        if isArmMoveRestriction {
            arm.position.y = min(frame.midY - 400, arm.position.y) // 初期位置より上には移動不可
        }
    }
    
    // 戻るボタン
    func setupReturnButton() {
        let buttonSize = CGSize(width: 120, height: 50)
        returnButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        returnButton.fillColor = SKColor.white
        returnButton.strokeColor = SKColor.black
        returnButton.lineWidth = 1
        returnButton.zPosition = 1
        returnButton.position = CGPoint(x: frame.midX - 200, y: frame.maxY - 75)
        addChild(returnButton)
        let returnButtonLabel = SKLabelNode(text: "戻る")
        returnButtonLabel.position = CGPoint(x: frame.midX - 200, y: frame.maxY - 85)
        returnButtonLabel.fontSize = 30
        returnButtonLabel.fontColor = SKColor.black
        returnButtonLabel.zPosition = 1
        addChild(returnButtonLabel)
    }
    
    // リセットボタン
    func setupResetButton() {
        let buttonSize = CGSize(width: 120, height: 50)
        resetButton = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        resetButton.fillColor = SKColor.white
        resetButton.strokeColor = SKColor.black
        resetButton.lineWidth = 1
        resetButton.zPosition = 1
        resetButton.position = CGPoint(x: frame.midX + 200, y: frame.maxY - 75)
        addChild(resetButton)
        let resetButtonLabel = SKLabelNode(text: "リセット")
        resetButtonLabel.position = CGPoint(x: frame.midX + 200, y: frame.maxY - 85)
        resetButtonLabel.fontSize = 30
        resetButtonLabel.fontColor = SKColor.black
        resetButtonLabel.zPosition = 1
        addChild(resetButtonLabel)
    }
    
    // 醤油を生成
    func spawnSoysauce() {
        let soysauceTexture = SKTexture(imageNamed: "soysauce")
        soysauce = SKSpriteNode(texture: soysauceTexture, size: CGSize(width: 150, height: 180))
        soysauce.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        soysauce.zPosition = 1
        
        // 醤油に物理ボディを追加
        soysauce.physicsBody = SKPhysicsBody(texture: soysauceTexture, size: soysauce.size)
        soysauce.physicsBody?.isDynamic = true
        soysauce.physicsBody?.categoryBitMask = PhysicsCategory.soySauce
        // 接触で指定した物体に通知
        soysauce.physicsBody?.contactTestBitMask = PhysicsCategory.arm | PhysicsCategory.cooking
        // 指定した物体と接触で衝突判定
        soysauce.physicsBody?.collisionBitMask = PhysicsCategory.arm | PhysicsCategory.cooking
        soysauce.name = "soysauce"
        addChild(soysauce)
    }
    
    func showMessage(_ message: String) {
        // 前回のメッセージを削除
        currentMessageLabel?.removeFromParent()
        
        let messageLabel = SKLabelNode(text: message)
        if talker == 0 {
            // father
            messageLabel.position = CGPoint(x: frame.midX + addPosition.messageLabelLeft.x, y: frame.midY + addPosition.messageLabelLeft.y)
        } else {
            // mother
            messageLabel.position = CGPoint(x: frame.midX + addPosition.messageLabelRight.x, y: frame.midY + addPosition.messageLabelRight.y)
        }
        messageLabel.fontSize = 40
        messageLabel.fontColor = SKColor.black
        messageLabel.zPosition = 2
        addChild(messageLabel)
        // 現在のメッセージ
        currentMessageLabel = messageLabel
    }
    
    func startMessageTimer() {
        // 指示中でないなら指示を行う
        guard !isIndicatingFlag else { return }

        let interval = Double.random(in: 7.0...10.0);
        messageTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            if self?.isPaused == true || self?.isIndicatingFlag == true { return }
            guard let self = self else { return }
            talker = Int.random(in: 0...1)  // 指示を出す人
            // メッセージの吹き出し
            self.messageImage?.removeFromParent()
            let messageHardTexture = SKTexture(imageNamed: "message_hard")
            messageImage = SKSpriteNode(texture: messageHardTexture, size: CGSize(width: 370, height: 110))
            if talker == 0 {
                // father
                messageImage.position = CGPoint(x: frame.midX + addPosition.messageBgLeft.x, y: frame.midY + addPosition.messageBgLeft.y)
            } else {
                // mother
                messageImage.position = CGPoint(x: frame.midX + addPosition.messageBgRight.x, y: frame.midY + addPosition.messageBgRight.y)
            }
            if let messageImage = self.messageImage {
                self.messageImage.zPosition = 1
                self.addChild(messageImage)
            }
            self.showMessage("醤油取って！")
            self.startTimer()
            isArmMoveRestriction = false
            isIndicatingFlag = true
            if playCount < oneGamePlayCount {
                playCount += 1
            } else {
                playCount = 1
            }
        }
    }
    
    // 1ゲームごとの結果を表示
    func showResultDialog() {
        isPaused = true
        
        let resultDialogObject = createObject(textureName: "board", size: CGSize(width: 600, height: 650), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: 100, isAddChild: false)

        let titleLabel = SKLabelNode(text: "結果")
        titleLabel.position = CGPoint(x: 0, y: 200)
        titleLabel.zPosition = 101
        titleLabel.fontColor = SKColor.black
        titleLabel.fontSize = 50
        resultDialogObject.addChild(titleLabel)
        
        let timeLabel = SKLabelNode(text: String(format: "合計タイム: %.2f秒", totalTime))
        timeLabel.position = CGPoint(x: 0, y: 0)
        timeLabel.zPosition = 101
        timeLabel.fontColor = SKColor.black
        timeLabel.fontSize = 50
        resultDialogObject.addChild(timeLabel)

        let rankingbuttonSize = CGSize(width: 400, height: 70)
        rankingButtonBg = SKShapeNode(rectOf: rankingbuttonSize, cornerRadius: 10)
        rankingButtonBg.fillColor = SKColor.white
        rankingButtonBg.strokeColor = SKColor.black
        rankingButtonBg.lineWidth = 1
        rankingButtonBg.zPosition = 101
        rankingButtonBg.position = CGPoint(x: 0, y: -110)
        resultDialogObject.addChild(rankingButtonBg)
        let rankingButton = SKLabelNode(text: "ランキングを見る")
        rankingButton.position = CGPoint(x: 0, y: -130)
        rankingButton.zPosition = 101
        rankingButton.fontColor = SKColor.black
        rankingButton.fontSize = 50
        rankingButton.name = "rankingButton"
        resultDialogObject.addChild(rankingButton)
        
        let buttonSize = CGSize(width: 160, height: 70)
        closeButtonBg = SKShapeNode(rectOf: buttonSize, cornerRadius: 10)
        closeButtonBg.fillColor = SKColor.white
        closeButtonBg.strokeColor = SKColor.black
        closeButtonBg.lineWidth = 1
        closeButtonBg.zPosition = 101
        closeButtonBg.position = CGPoint(x: 0, y: -220)
        resultDialogObject.addChild(closeButtonBg)
        let closeButton = SKLabelNode(text: "閉じる")
        closeButton.position = CGPoint(x: 0, y: -240)
        closeButton.zPosition = 101
        closeButton.fontColor = SKColor.black
        closeButton.fontSize = 50
        closeButton.name = "closeButton"
        resultDialogObject.addChild(closeButton)
        
        addChild(resultDialogObject)
        resultDialog = resultDialogObject
    }
    
    func closeResultDialog() {
        // ダイアログを削除
        resultDialog?.removeFromParent()
        resultDialog = nil
        
        // ゲームの挙動を再開
        isPaused = false
    }
    
    // タイム計測
    func startTimer() {
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
        if isHoldingSoy {
            return
        }

        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        // 腕と醤油が接触したとき
        let isContact = (bodyA.categoryBitMask == PhysicsCategory.arm && bodyB.categoryBitMask ==           PhysicsCategory.soySauce) || (bodyA.categoryBitMask == PhysicsCategory.soySauce && bodyB.categoryBitMask == PhysicsCategory.arm)
        if isContact {
            if let soyNode = bodyB.categoryBitMask == PhysicsCategory.soySauce ? bodyB.node : bodyA.node {
                // 手に醤油を固定する
                let handPosition = CGPoint(x: arm.position.x, y: arm.position.y + (arm.size.height / 2))
                let joint = SKPhysicsJointFixed.joint(withBodyA: arm.physicsBody!, bodyB: soyNode.physicsBody!, anchor: handPosition)
                self.physicsWorld.add(joint)
                
                isHoldingSoy = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if (!isPaused) {
            // スワイプ開始位置
            swipeStartPosition = touch.location(in: self)
            // 戻るボタン
            if returnButton.contains(location) {
                returnTitle()
            }
            // リセットボタン
            if resetButton.contains(location) {
                resetGame() // リセット処理を呼び出す
            }
        }
        
        // 結果ダイアログの各種ボタン
        if let dialog = resultDialog, dialog.contains(location) {
            let nodesAtPoint = nodes(at: location)
            for node in nodesAtPoint {
                if node.name == "rankingButton" {
                    showLeaderboard()
                    break
                }
                if node.name == "closeButton" {
                    closeResultDialog()
                    break
                }
            }
        }
    }
    
    func returnTitle () {
        let titleScene = TitleScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(titleScene, transition: transition)
    }
    
    // TODO: リファクタリング
    func resetGame() {
        playCount = 0   // プレイ回数
        currentMessageLabel?.removeFromParent()
        messageImage?.removeFromParent()
        elapsedTime = 0
        timerLabel.text = String(format: "タイム: %.2f秒", elapsedTime)
        stopTimer()
        bestTimeLabel.text = "最高タイム:"
        bestTime = Double.greatestFiniteMagnitude
        totalTimeLabel.text = "合計タイム:"
        totalTime = 0
        arm.position = CGPoint(x: frame.midX, y: -400)
        resetArmPosition()
        // 醤油の初期化
        if let soyNode = self.childNode(withName: "soysauce") {
            isIndicatingFlag = false;
            soyNode.removeFromParent()
            self.spawnSoysauce()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self)
        
        // スワイプによる移動量を計算
        let diffX = currentPosition.x - arm.position.x
        let diffY = currentPosition.y - arm.position.y
        
        // 腕の位置を更新
        let speedFactor: CGFloat = 1 // 移動の滑らかさ調整
        arm.position = CGPoint(x: arm.position.x + diffX * speedFactor, y: arm.position.y + diffY * speedFactor)

        // 醤油を掴んだ状態で下部に到達すると取ったことにする 指示を出した人物側に到達でOK
        if let soyNode = self.childNode(withName: "soysauce" ) {
            let soyNodePosition = soyNode.position
            let isBottom = soyNodePosition.y < frame.height / 3.2
            if !isBottom { return }
            
            var isReachArea = false
            if talker == 0 {
                // father
                isReachArea = soyNodePosition.x < frame.midX
            } else {
                // mother
                isReachArea = soyNodePosition.x > frame.midX
            }
            
            if isReachArea {
                removeSoysauce()
            }
        }
        
        // スワイプ開始位置を更新
        swipeStartPosition = currentPosition
    }
    
    func createInvisibleWall() {
        let wallHeight: CGFloat = frame.height / 3
        let wall = SKSpriteNode(color: .clear, size: CGSize(width: frame.width, height: wallHeight))
        wall.position = CGPoint(x: frame.midX, y: frame.maxY - wallHeight / 3.2) // 壁の位置を設定
        
        // 壁に物理ボディを追加
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.arm | PhysicsCategory.soySauce
        wall.physicsBody?.collisionBitMask = PhysicsCategory.arm | PhysicsCategory.soySauce
        addChild(wall)
    }
    
    func removeSoysauce() {
        if let soyNode = self.childNode(withName: "soysauce") {
            soyNode.removeFromParent()
        }

        // 効果音
        playEffectSound()

        // メッセージ吹き出しを削除
        messageImage?.removeFromParent()
        // メッセージの吹き出し(柔らかい口調)
        let messageSoftTexture = SKTexture(imageNamed: "message_soft")
        messageImage = SKSpriteNode(texture: messageSoftTexture, size: CGSize(width: 330, height: 110))
        if talker == 0 {
            // father
            messageImage.position = CGPoint(x: frame.midX + addPosition.messageLabelLeft.x, y: frame.midY + addPosition.messageLabelLeft.y)
        } else {
            // mother
            messageImage.position = CGPoint(x: frame.midX + addPosition.messageLabelRight.x, y: frame.midY + addPosition.messageLabelRight.y)
        }
        if let messageImage = self.messageImage {
            self.messageImage.zPosition = 1
            self.addChild(messageImage)
        }
        if elapsedTime < 0.5 {
            showMessage("はやっ！")
        } else if elapsedTime < 1 {
            showMessage("早いねー")
        } else if elapsedTime > 3 {
            showMessage("遅いッ！")
        } else {
            showMessage("ありがとね")
        }
        // メッセージを削除
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.messageImage?.removeFromParent()
            self.currentMessageLabel?.removeFromParent()
            self.currentMessageLabel = nil
        }
        
        // 最高タイムの更新
        if elapsedTime < bestTime {
            bestTime = elapsedTime
            bestTimeLabel.text = String(format: "最高タイム: %.2f秒", bestTime)
        }
        // 合計タイム
        totalTime += elapsedTime
        totalTimeLabel.text = String(format: "合計タイム: %.2f秒", totalTime)
        
        // 指示中フラグの解除
        isIndicatingFlag = false;
        // 腕を初期状態にする
        resetArmPosition()
        isHoldingSoy = false
        isArmMoveRestriction = true

        stopTimer()
        
        // 1ゲームごとに結果を表示
        if playCount == oneGamePlayCount {
            showResultDialog()
            reportScore(totalTime: totalTime)
            resetGame()
        }
        
        // 2秒後にタイマーを初期化、醤油を再生成
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.elapsedTime = 0
            self.timerLabel.text = String(format: "タイム: %.2f秒", self.elapsedTime)
            self.spawnSoysauce()
        }
    }
    
    // GameCenterランキングを表示
    func reportScore(totalTime: TimeInterval) {
        // 整数に変換してスコアとして報告 Int型で送るために変換（12.34秒で登録の場合は1234）
        let scoreValue = Int(totalTime * 100)
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(scoreValue, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["takuya.TakeSoyGame.leaderboard"]) { error in
                if let error = error {
                    print("Error reportScore: スコア送信に失敗 \(error.localizedDescription)")
                } else {
                    print("OK reportScore: スコア送信に成功 \(scoreValue)")
                }
            }
        } else {
            print("reportScore: GameCenterにログインしていません")
        }
    }
    
    func showLeaderboard() {
        // リーダーボードIDを指定して GKLeaderboard を初期化
        if GKLocalPlayer.local.isAuthenticated {
            print("showLeaderboard: リーダーボード表示前")
            GKLeaderboard.loadLeaderboards(IDs: ["takuya.TakeSoyGame.leaderboard"]) { leaderboards, error in
                if let error = error {
                    print("Error showLeaderboard(): \(error.localizedDescription)")
                    return
                }
                
                // リーダーボードを取得してGameCenterのビューコントローラーを表示
                print("showLeaderboard: リーダーボード表示")
                if let leaderboard = leaderboards?.first {
                    let gcViewController = GKGameCenterViewController(leaderboard: leaderboard, playerScope: .global)
                    gcViewController.gameCenterDelegate = self
                    
                    if let presentingVC = self.view?.window?.rootViewController {
                        presentingVC.present(gcViewController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            print("reportScore: GameCenterにログインしていません")
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // 効果音を再生する
    func playEffectSound() {
        guard let url = Bundle.main.url(forResource: "effect_take_soy", withExtension: "mp3") else {
            print("効果音ファイルが見つかりません:effect_take_soy")
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.volume = 0.1
            effectPlayer?.play()
        } catch {
            print("効果音の再生に失敗しました:effect_take_soy \(error.localizedDescription)")
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
