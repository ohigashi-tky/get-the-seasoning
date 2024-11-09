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
    
    var level: Int
    
    // 初期処理
    init(size: CGSize, level: Int) {
        self.level = level
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var audioPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?
    
    var flooring: SKSpriteNode!
    var monitor: SKSpriteNode!
    var desk: SKSpriteNode!
    var arm: SKSpriteNode!
    var soysauce: SKSpriteNode!
    var messageImage: SKSpriteNode!
    var positions: [CGPoint]!
    
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
        static let cooking: UInt32 = 0x1 << 3
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
        if level <= 1 {
            _ = createObject(textureName: "flooring", size: CGSize(width: 750, height: 1334), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: -2)
        } else if level == 2 {
            _ = createObject(textureName: "floor_gray", size: CGSize(width: 750, height: 1334), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: -2)
        } else if level == 3 {
            _ = createObject(textureName: "floor_mix", size: CGSize(width: 750, height: 1334), position: CGPoint(x: frame.midX, y: frame.midY), zPosition: -2)
        }
            
        // モニター
        _ = createObject(textureName: "monitor", size: CGSize(width: 570, height: 650), position: CGPoint(x: frame.midX, y: frame.maxY - 280), zPosition: -1)
        
        // 机
        if level <= 1 {
            _ = createObject(textureName: "desk", size: CGSize(width: 550, height: 600), position: CGPoint(x: frame.midX, y: frame.midY - 50), zPosition: 0)
        } else if level == 2 {
            _ = createObject(textureName: "desk_black", size: CGSize(width: 550, height: 600), position: CGPoint(x: frame.midX, y: frame.midY - 50), zPosition: 0)
        } else if level == 3 {
            _ = createObject(textureName: "desk_4mix2", size: CGSize(width: 550, height: 600), position: CGPoint(x: frame.midX, y: frame.midY - 50), zPosition: 0)
        }

        // 料理の座標を設定
        positions = [
            CGPoint(x: frame.minX + 160, y: frame.midY - 10),
            CGPoint(x: frame.minX + 305, y: frame.midY - 10),
            CGPoint(x: frame.minX + 450, y: frame.midY - 10),
            CGPoint(x: frame.minX + 595, y: frame.midY - 10),
            CGPoint(x: frame.minX + 160, y: frame.midY - 190),
            CGPoint(x: frame.minX + 305, y: frame.midY - 190),
            CGPoint(x: frame.minX + 450, y: frame.midY - 190),
            CGPoint(x: frame.minX + 595, y: frame.midY - 190)
        ]
        // 料理
        if level > 0 {
            createCookingObject()
        }
        
        // 男性
        _ = createObject(textureName: "father", size: CGSize(width: 400, height: 400), position: CGPoint(x: frame.midX - 150, y: frame.midY - 500), zPosition: 0)
        
        // 女性
//        _ = createObject(textureName: "mother", size: CGSize(width: 400, height: 400), position: CGPoint(x: frame.midX + 150, y: frame.midY - 500), zPosition: 0)
        _ = createObject(textureName: "female", size: CGSize(width: 300, height: 300), position: CGPoint(x: frame.midX + 150, y: frame.midY - 550), zPosition: 0)
        
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
        arm.physicsBody?.categoryBitMask = PhysicsCategory.arm
        arm.physicsBody?.contactTestBitMask = 0
        arm.physicsBody?.collisionBitMask = PhysicsCategory.wall
        arm.physicsBody?.restitution = 0.0 // 衝突時の反発
        arm.physicsBody?.friction = 0.0 // 摩擦
        addChild(arm)
        
        // 醤油を表示
        spawnSoysauce()
        // 指示
        startMessageTimer()
    }
    
    // 机の上の料理を生成（ランダム）
    func createCookingObject() {
        // 既存の料理を削除
        removeExistingNode(name: "cooking")
        
        let cookingNames: [String] = [
            "pasuta_meat", "medamayaki", "sanma", "korokke",
            "syougayaki", "rice", "tonnjiru", "udon"
        ]

        // 8つの中からランダムに表示 横一列の最大個数は3つ（醤油が取れるように）
        var firstRange: ArraySlice<Int>
        var secondRange: ArraySlice<Int>
        var indexs: [Int] = [0]
        if level == 1 {
            indexs = [5,6]
        } else if level == 2 {
            firstRange = Array(0...3).shuffled().prefix(Int.random(in: 1...3))
            secondRange = Array(4...7).shuffled().prefix(4 - firstRange.count)
            indexs = Array(firstRange + secondRange).shuffled()
        } else if level == 3 {
            firstRange = Array(0...3).shuffled().prefix(Int.random(in: 2...3))
            secondRange = Array(4...7).shuffled().prefix(5 - firstRange.count)
            indexs = Array(firstRange + secondRange).shuffled()
        }
        for (index, cookingName) in cookingNames.enumerated() {
            if indexs.contains(index) {
                let position = positions[index]
                _ = createSKPhysicsBody(
                    textureName: cookingName,
                    size: CGSize(width: 135, height: 110),
                    position: position,
                    zPosition: 1,
                    category: PhysicsCategory.soySauce
                )
            }
        }
    }
    
    // 指定した名称のノードを削除
    func removeExistingNode(name: String) {
        if name == "" { return }
        for node in children {
            if node.name == name {
                node.removeFromParent()
            }
        }
    }
    
    // 衝突判定有りの物体を生成
    func createSKPhysicsBody(textureName: String, size: CGSize, position: CGPoint, zPosition: CGFloat, category: UInt32, isAddChild: Bool = true) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName)
        let spriteNode = SKSpriteNode(texture: texture, size: size)
        spriteNode.position = position
        spriteNode.zPosition = zPosition
        spriteNode.name = "cooking" //一旦、全てを料理に固定
        spriteNode.physicsBody = SKPhysicsBody(texture: texture, size: size)
        spriteNode.physicsBody?.isDynamic = false
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
        if level >= 3 {
            // 左右移動のために端に配置
            soysauce.position = CGPoint(x: frame.midX + 200, y: frame.midY + 160)
        } else {
            // 真ん中に配置
            soysauce.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        }
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
        
        // 左右に移動させる
        if level >= 3 {
            let moveLeft = SKAction.moveBy(x: -400, y: 0, duration: 1.0)
            let moveRight = SKAction.moveBy(x: 400, y: 0, duration: 1.0)
            let horizontalSequence = SKAction.sequence([moveLeft, moveRight])
            let repeatHorizontal = SKAction.repeatForever(horizontalSequence)
            
            // 上下に移動させるアクション
            let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.3)
            let moveDown = SKAction.moveBy(x: 0, y: -50, duration: 0.3)
            let verticalSequence = SKAction.sequence([moveUp, moveDown])
            let repeatVertical = SKAction.repeatForever(verticalSequence)
            
            // 左右と上下のアクションを同時に実行
            let combinedAction = SKAction.group([repeatHorizontal, repeatVertical])
            soysauce.run(combinedAction, withKey: "moveSoysauce")
        }
        addChild(soysauce)
    }
    
    func showMessage(_ message: String) {
        // 前回のメッセージを削除
        currentMessageLabel?.removeFromParent()
        
        let messageLabel = SKLabelNode(text: message)
        if talker == 0 {
            // 男性
            messageLabel.position = CGPoint(x: frame.midX + addPosition.messageLabelLeft.x, y: frame.midY + addPosition.messageLabelLeft.y)
        } else {
            // 女性
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

        var character_name: String = ""
        
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
                // 男性
                character_name = "銀芽"
                messageImage.position = CGPoint(x: frame.midX + addPosition.messageBgLeft.x, y: frame.midY + addPosition.messageBgLeft.y)
            } else {
                // 女性
                character_name = "リリンちゃん"
                messageImage.position = CGPoint(x: frame.midX + addPosition.messageBgRight.x, y: frame.midY + addPosition.messageBgRight.y)
            }
            if let messageImage = self.messageImage {
                self.messageImage.zPosition = 1
                self.addChild(messageImage)
            }
            playEffectSound(name: "\(character_name)_しょうゆとって", extension_name: "wav")
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

        // 料理の再配置
        if level >= 2 {
            createCookingObject()
        }
        
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
                // 醤油の動きを停止
                soyNode.removeAction(forKey: "moveSoysauce")
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
        // 料理の再配置
        if level >= 2 {
            createCookingObject()
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
                // 男性
                isReachArea = soyNodePosition.x < frame.midX
            } else {
                // 女性
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
        let wallHeight: CGFloat = frame.height / 2.5
        let wall = SKSpriteNode(color: .clear, size: CGSize(width: frame.width, height: wallHeight))
        wall.position = CGPoint(x: frame.midX, y: frame.maxY)
        
        // 壁に物理ボディを追加
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.arm | PhysicsCategory.soySauce
        wall.physicsBody?.collisionBitMask = PhysicsCategory.arm | PhysicsCategory.soySauce
        addChild(wall)
    }
    
    func removeSoysauce() {
        var character_name: String = ""
        let voice_list = [
             "mesugaki": ["はやすぎでしょ", "やるね", "おそいよ", "ありがとう"]
            ,"father": ["はやいね", "やるね", "おそいな", "ありがとう"]
            ,"mother": ["はやはやいでしょ", "やるね", "おそいな", "ありがとう"]
        ]
        var voices: [String] = []
        
        if let soyNode = self.childNode(withName: "soysauce") {
            soyNode.removeFromParent()
        }

        // メッセージ吹き出しを削除
        messageImage?.removeFromParent()
        // メッセージの吹き出し(柔らかい口調)
        let messageSoftTexture = SKTexture(imageNamed: "message_soft")
        messageImage = SKSpriteNode(texture: messageSoftTexture, size: CGSize(width: 330, height: 110))
        if talker == 0 {
            // 男性
            character_name = "銀芽"
            voices = voice_list["father"]!
            messageImage.position = CGPoint(x: frame.midX + addPosition.messageLabelLeft.x, y: frame.midY + addPosition.messageLabelLeft.y)
        } else {
            // 女性
            character_name = "リリンちゃん"
            voices = voice_list["mesugaki"]!
            messageImage.position = CGPoint(x: frame.midX + addPosition.messageLabelRight.x, y: frame.midY + addPosition.messageLabelRight.y)
        }
        if let messageImage = self.messageImage {
            self.messageImage.zPosition = 1
            self.addChild(messageImage)
        }
        if elapsedTime < 1 {
            playEffectSound(name: "\(character_name)_\(voices[0])", extension_name: "wav")
            showMessage(voices[0])
        } else if elapsedTime < 1.5 {
            playEffectSound(name: "\(character_name)_\(voices[1])", extension_name: "wav")
            showMessage(voices[1])
        } else if elapsedTime > 3 {
            playEffectSound(name: "\(character_name)_\(voices[2])", extension_name: "wav")
            showMessage(voices[2])
        } else {
            playEffectSound(name: "\(character_name)_\(voices[3])", extension_name: "wav")
            showMessage(voices[3])
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
        // 料理の再配置
        if level >= 2 {
            createCookingObject()
        }
        
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
        if level < 1 { return }

        // 整数に変換してスコアとして報告 Int型で送るために変換（12.34秒で登録の場合は1234）
        let leaderboardID = "takuya.TakeSoyGame.level\(level)"
        let scoreValue = Int(totalTime * 100)
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(scoreValue, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
                if let error = error {
                    print("Error reportScore: スコア送信に失敗 \(error.localizedDescription)")
                } else {
                    print("OK reportScore: スコア送信に成功:\(scoreValue) LeaderBoardID:\(leaderboardID)")
                }
            }
        } else {
            print("reportScore: GameCenterにログインしていません")
        }
    }
    
    func showLeaderboard() {
        if level < 1 { return }

        // リーダーボードIDを指定して GKLeaderboard を初期化
        let leaderboardID = "takuya.TakeSoyGame.level\(level)"
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { leaderboards, error in
                if let error = error {
                    print("Error showLeaderboard(): \(error.localizedDescription)")
                    return
                }
                
                // リーダーボードを取得してGameCenterのビューコントローラーを表示
                print("showLeaderboard: リーダーボード表示 LeaderBoardID:\(leaderboardID)")
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
    func playEffectSound(name: String, extension_name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: extension_name) else {
            print("効果音ファイルが見つかりません: \(name)")
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.volume = 0.2
            effectPlayer?.play()
        } catch {
            print("効果音の再生に失敗しました: \(name) \(error.localizedDescription)")
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
