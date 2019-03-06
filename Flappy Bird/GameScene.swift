//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Naoki Arakawa on 2019/03/04.
//  Copyright © 2019 Naoki Arakawa. All rights reserved.
//

import SpriteKit
import GameplayKit

//物体と物体がぶつかった時に呼ばれるデリゲートメソッドを使うためのもの
class GameScene: SKScene, SKPhysicsContactDelegate {

    //SpriteKitにはスプライトと呼ばれるゲームのキャラクターや武器など、画像でほ表現する１つのオブジェクトがある
    var bird = SKSpriteNode()
    var gameOverImage = SKSpriteNode()
    
    //画面をタップして、鳥が飛ぶときになる音楽
    //これらは魔王魂からダウンロードした
    let jumpSound = SKAction.playSoundFileNamed("sound.mp3", waitForCompletion: false)
    let backSound = SKAction.playSoundFileNamed("backSound.mp3", waitForCompletion: false)
    
    
    //パイプに衝突したらパイプが止まる変数
    //SKNodeは物体のみで、画像を使うことはできない、見えない
    var blockingObjects = SKNode()
    
    //タイマーが格納される変数
    var score = Int(0)
    
    //var scoreのタイマーの時間を格納するための変数
    var scoreLbl = SKLabelNode()
    
    //上の障害物で、画像を当てはめるので、SKSpriteNode()となる
    var pipeTop = SKSpriteNode()
    
    //背景画像を動かしていくためのタイマー
    var timer : Timer = Timer()
    
    //ゲームがどれだけ進行しているかを測定するためのタイマー
    var gameTimer: Timer = Timer()
    
    //最終的にはここにスコアが入る
    var timeString = String()
    
    
    override func didMove(to view: SKView) {
    
    //ここでバッググランドのサウンドを流す
    self.run(backSound, withKey: "back")
        
    //runの後が、junpSoundではなくて、backSoundになっていた
    self.run(jumpSound, withKey: "jumpSound")
        
    createParts()
        
    }
    
    //鳥と背景、オブジェクトを作っていく
    func createParts() {
        
    //背景について
    //画像を扱うためSKSpriteNodeを使う
    let backView = SKSpriteNode(imageNamed: "bg.png")
        backView.position = CGPoint(x: 0, y: 0)
        backView.run(SKAction.repeatForever(SKAction.sequence([
        
            //右から左にバックビューが流れる、目の錯覚を作っている
            //画面から消えたらまた戻るという動き
            //画像１枚だけだと背景が見えてしまうため、画像２枚を動かしていく
            //13秒かけて、幅の分だけ動いてくださいという内容
            SKAction.moveTo(x: -self.size.width, duration: 13.0),
            
            //その後に、そのままもとに戻ってくださいという処理をここに書いている
            //ここのyをxに変更している
            SKAction.moveTo(x: 0, duration: 0.0)
            
            
            ])))
        
        //これらを画面につけていく
        self.addChild(backView)
       
        
        //画像を扱うためSKSpriteNodeを使う
        let backView2 = SKSpriteNode(imageNamed: "bg.png")
        backView2.position = CGPoint(x: self.frame.width, y: 0)
        backView2.run(SKAction.repeatForever(SKAction.sequence([
            
            //右から左にバックビューが流れる、目の錯覚を作っている
            //画面から消えたらまた戻るという動き
            //画像１枚だけだと背景が見えてしまうため、画像２枚を動かしていく
            //13秒かけて、幅の分だけ動いてくださいという内容
            SKAction.moveTo(x: 0, duration: 13.0),
            
            //その後に、そのままもとに戻ってくださいという処理をここに書いている
            SKAction.moveTo(x: self.frame.width, duration: 0.0)
            
            
            ])))
        
        //これらを画面につけていく
        self.addChild(backView2)
        
        //birdを初期化していく
        bird = SKSpriteNode()
        
        //gameOverImageを初期化する
        gameOverImage = SKSpriteNode()
        
        //同じく初期化する
        //TODO-ここはSKNodeではなくて、SKSpriteNodeなのか?????
        blockingObjects = SKSpriteNode()
        
        score = Int(0)
        scoreLbl = SKLabelNode()
        scoreLbl = self.childNode(withName: "scoreLbl") as! SKLabelNode
        scoreLbl.text = "\(score)"
        scoreLbl.color = UIColor.white
        
        //土管と鳥がぶつかった時に、どっちが画面の前なのか、Zは奥行き
        //Z positionの値を大きくすればするほど、物体が手前にくる
        scoreLbl.zPosition = 17
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        
        //ここの数字を変更することで形が変わる
        //width: CGFloat(100)がマイナスになっていた
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y:CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        
        let scoreBgColor = UIColor.gray
        scoreBg.alpha = 0.5
        scoreBg.strokeColor = UIColor.clear
        
        scoreBg.fillColor = scoreBgColor
        
        //数字の方が下にきてほしいため、１４よりも小さな数字
        scoreBg.zPosition = 13
        scoreLbl.addChild(scoreBg)
        
        
        //Timerを初期化していく
        timer = Timer()
        gameTimer = Timer()
        
        //物理現象は自分が支配する？というコードを書いていく
        self.physicsWorld.contactDelegate = self
        
        //重量に関して定義している
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        
        //中に入っているものを全て排除する
        //ゲームの進行上、再スタートする際に、今までのものを全て除去する必要がある
        blockingObjects.removeAllChildren()
        
        //ゲームを再スタートする際に初期化する必要があるため
        gameOverImage = SKSpriteNode()
        
        self.addChild(blockingObjects)
        
        
        //ゲームオーバーイメージを作っていく
        //まず初めにテクスチャーを作る
        //SKSpriteNodeは画像を処理できるため、SKNodeではない
        //画像を直接spriteNodeにつけることはできないため、Textureにつける
        let gameOverTexture = SKTexture(imageNamed: "GameOverImage.jpg")
        gameOverImage = SKSpriteNode(texture: gameOverTexture)
        
         //位置を決める
        gameOverImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverImage.zPosition = 11
        self.addChild(gameOverImage)
        
        //まずは消しておく、gameOverImageを消しておく
        gameOverImage.isHidden = true
        
        
        //birdを作成していく
        let birdTexture = SKTexture(imageNamed: "bird.png")
        
        //textureをbirdに取り込む
        bird = SKSpriteNode(texture: birdTexture)
        
        //birdの位置を決める
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        //鳥の大きさの半分を半径とした円として、鳥の体を持たせる
        //丸として物体を認識させる
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        
        //ここでのisDynamicは鳥を動かすのか、動かさないのかということを定義している
        bird.physicsBody?.isDynamic = true
        
        //くるくる回ることを許可するか、しないかということを定義
        bird.physicsBody?.allowsRotation = false
        
        //衝突判定をするため、それぞれのPhysocsbody、つまり鳥や土管に対してカテゴリーをつけていく
        //つまりどの数字のものとぶつかったのかということを判定する
        bird.physicsBody?.categoryBitMask = 1
        
        //この鳥がどのようなものにぶつかった場合に衝突判定するのかを定義していく
        bird.physicsBody?.collisionBitMask = 2
        
        bird.physicsBody?.contactTestBitMask = 2
        
        bird.zPosition = 10
        
        //これで鳥を完成させることができた
        self.addChild(bird)
        
        //鳥が落ちた時に弾むように
        let ground = SKNode()
        ground.position = CGPoint(x: -325, y: -700)
        
        //groundの幅と高さを決めていく
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        
        //groundは動かさないようにしたい
        //重量の設定がされているため、ここでfalseにしないと下に落ちてしまう
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody?.categoryBitMask = 2
        blockingObjects.addChild(ground)
        
        //パイプが次々にランダムに表示されるようにしたい
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(createPipe), userInfo: nil, repeats: true)
        
        
        //ここのtimeIntervalが4になっていた
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateScore), userInfo: nil, repeats: true)

        
        
        
        
    }
    
    
    @objc func updateScore() {
        
        //スコアをカウントアップしていく
        score += 1
        scoreLbl.text = "\(score)"
        
        
        
    }
    
    
    
    @objc func createPipe(){
        
        //パイプを生成,ランダムにする
        //randomLengthが0の時に、1/4のサイズにする
        
        let randomLength = arc4random() % UInt32(self.frame.size.height/2)
        let offset = CGFloat(randomLength) - self.frame.size.height/4
        
        //土管と土管の間をあけたい
        let gap = bird.size.height*3
        
        //上のパイプを生成する
        let pipeTopTexture = SKTexture(imageNamed: "pipeTop.png")
        pipeTop = SKSpriteNode(texture: pipeTopTexture)
        
        //画面からは出ていない状況
        //gapの半分だけ、パイプを上に上げている
        pipeTop.position = CGPoint(x: self.frame.midX + self.frame.width/2, y: self.frame.midY + pipeTop.size.height/2 + gap/2 + offset)
        
        pipeTop.physicsBody = SKPhysicsBody(rectangleOf: pipeTop.size)
        
        //鳥がぶつかった時には動いてもらったら困る、重量を無視する
        pipeTop.physicsBody?.isDynamic = false
        
        //衝突判定で鳥以外のものは全て２にする
        pipeTop.physicsBody?.categoryBitMask = 2
        blockingObjects.addChild(pipeTop)
        
        
         //下のパイプを生成する,piptTopwをPipeBottomに置き換える
        let pipeBottomTexture = SKTexture(imageNamed: "pipeBottom.png")
        let pipeBottom = SKSpriteNode(texture: pipeBottomTexture)
        //gapの半分だけ、パイプを上に上げている
        pipeBottom.position = CGPoint(x: self.frame.midX + self.frame.width/2, y: self.frame.midY - pipeBottom.size.height/2 - gap/2 + offset)
        
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOf: pipeBottom.size)
        
        //鳥がぶつかった時には動いてもらったら困る、重量を無視する
        pipeBottom.physicsBody?.isDynamic = false
        
        //衝突判定で鳥以外のものは全て２にする
        pipeBottom.physicsBody?.categoryBitMask = 2
        
        //ここがpipeTopになっていた
        blockingObjects.addChild(pipeBottom)
        
        //パイプに動きをつけていく
        //-70の分だけ、左に寄っている
        //４秒かけて、画面の幅分だけ移動してください
        let pipeMove = SKAction.moveBy(x: -self.frame.size.width - 70, y: 0, duration: 4)
        
        //Moveを実行させる,これでpipeが生成されてきながら動く
        pipeTop.run(pipeMove)
        pipeBottom.run(pipeMove)
    }
    
    //SKPhysicsContactDelegateを定義したため衝突判定が有効になり、それを有効にするためのメソッドを記入する
    //衝突が発生する度に呼ばれる
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        blockingObjects.speed = 0
        
        //game overの画面を表示する
        gameOverImage.isHidden = false
        
        //Timerも止める
        timer.invalidate()
        gameTimer.invalidate()
        
        //スコアを０にする
        score = 0
        
        //スコアラベルについているものを全て消去する
        scoreLbl.removeAllChildren()
        
        blockingObjects.removeAllActions()
        blockingObjects.removeAllChildren()
        
        //ユーザーデフォルトが初期化される
        let ud = UserDefaults.standard
        
        //ここで取り出している
        self.timeString = ud.object(forKey: "saveData") as! String
        
        //現状のデータが、今回叩き出したデータよりも小さかった場合
        //つまり、最高得点が出たらデータを入れ替えるということを行なっている
        //ただしif文では文字列どうしを比較することができないため、Int型にキャストする必要がある
        if Int(self.timeString)! < Int(scoreLbl.text!)! {
            
            ud.set(scoreLbl.text!, forKey: "saveData")
            
        }
        
        self.removeAction(forKey: "backSound")
        self.removeAction(forKey: "jumpSound")
        
    }
        
        //画面をタッチした時に飛び跳ねるアクションをつける
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            
            if gameOverImage.isHidden == false {
                
                //ゲームを始めからやり直す時の処理
                gameOverImage.isHidden = true
                bird.removeFromParent()
                
                createParts()
                
          //ゲームプレイ中の場合
            } else {
                
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
                run(jumpSound)
                
            }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
