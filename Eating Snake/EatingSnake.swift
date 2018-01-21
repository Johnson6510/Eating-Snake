//
//  EatingSnake.swift
//  Eating Snake
//
//  Created by 黃健偉 on 2018/1/8.
//  Copyright © 2018年 黃健偉. All rights reserved.
//

import UIKit
import AVFoundation

class EatingSnake: UIViewController {

    var voiceEat :AVAudioPlayer! = nil
    var voiceDie :AVAudioPlayer! = nil

    struct location {
        var x: Int = 0
        var y: Int = 0
        mutating func value (newX: Int, newY: Int) {
            x = newX
            y = newY
        }
    }
    
    var timer = Timer()

    var pixel = [[UILabel]]()
    var pixelValue = [[Int]]()
    var snakeArray = [location()]
    var isSnakeMove: Bool = true

    var score = 0
    var level = 1
    var sick = 0
    var fast = 0
    var sickLevel = -1
    var fastLevel = -1
    var timeInterval: Double = 0.0
    
    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var snakeView: UIView!

    @IBOutlet weak var allView: UIView!
    
    var isPause = false
    @IBAction func btnPause(_ sender: UIBarButtonItem) {
        isPause = !isPause
        
        if (isPause) {
            sender.title = "開始"
            timer.fireDate = NSDate.distantFuture
        } else {
            sender.title = "暫停"
            timer.fireDate = NSDate.distantPast
        }
    }
    
    func reStartAlarm() {
        let alert = UIAlertController(title: "好慘！吃到自己了", message: "要重生嗎？", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "重生", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.reStartGame()
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        present(alert, animated: true, completion: nil)
    }

        
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EatingSnake.upCommand(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EatingSnake.downCommand(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EatingSnake.leftCommand(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EatingSnake.rightCommand(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc(up:)
    func upCommand(_ r: UIGestureRecognizer!) {
        if direction == moveDirection.left || direction == moveDirection.right {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Up")
                    direction = moveDirection.up
                } else {
                    print("Swipe - Up (sick to down)")
                    direction = moveDirection.down
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer!) {
        if direction == moveDirection.left || direction == moveDirection.right {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Down")
                    direction = moveDirection.down
                } else {
                    print("Swipe - Down (sick to up)")
                    direction = moveDirection.up
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer!) {
        if direction == moveDirection.up || direction == moveDirection.down {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Left")
                    direction = moveDirection.left
                } else {
                    print("Swipe - Left (sick to right)")
                    direction = moveDirection.right
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer!) {
        if direction == moveDirection.up || direction == moveDirection.down {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Right")
                    direction = moveDirection.right
                } else {
                    print("Swipe - Right (sick to left)")
                    direction = moveDirection.left
                }
                isSnakeMove = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setup voice - eat

        //initial background image
        allView.addBackground()
        snakeView.addSnakeBackground()
        //snakeView.transform = CGAffineTransform(translationX: (UIScreen.main.bounds.size.width-300)/2, y: (UIScreen.main.bounds.size.height-300)/2)
        //snakeView.backgroundColor = UIColor(patternImage: UIImage(named: "ground")!)
        //imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill


        //initial sound
        let soundPath1 = Bundle.main.path(forResource: "eat", ofType: "mp3")
        do {
            voiceEat = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: soundPath1!))
            voiceEat.numberOfLoops = 0 // 重複播放次數 設為 0 則是只播放一次 不重複
        } catch {
            print("error")
        }

        let soundPath2 = Bundle.main.path(forResource: "woman-die", ofType: "mp3")
        do {
            voiceDie = try AVAudioPlayer(contentsOf: NSURL.fileURL(withPath: soundPath2!))
            voiceDie.numberOfLoops = 0 // 重複播放次數 設為 0 則是只播放一次 不重複
        } catch {
            print("error")
        }

        //initial swip control
        setupSwipeControls()
        
        //initial game
        scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
        pixelInit()
        setTimer(level: level)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setTimer(level: Int) {
        timer.invalidate()
        timeInterval = 0.5 - Double(level - 1) * 0.005
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(EatingSnake.snakeWalk), userInfo: nil, repeats: true)
    }
    
    var direction = moveDirection.left
    enum moveDirection: Int {
        case up = 1
        case left = 2
        case down = 3
        case right = 4
    }

    enum item: String {
        case snakeHeadUp = "snakeHeadUp"
        case snakeHeadLeft = "snakeHeadLeft"
        case snakeHeadDown = "snakeHeadDown"
        case snakeHeadRight = "snakeHeadRight"
        case snakeBodyUp = "snakeBodyUp"
        case snakeBodyUpLeft = "snakeBodyUpLeft"
        case snakeBodyUpRight = "snakeBodyUpRight"
        case snakeBodyLeft = "snakeBodyLeft"
        case snakeBodyLeftUp = "snakeBodyLeftUp"
        case snakeBodyLeftDown = "snakeBodyLeftDown"
        case snakeBodyDown = "snakeBodyDown"
        case snakeBodyDownLeft = "snakeBodyDownLeft"
        case snakeBodyDownRight = "snakeBodyDownRight"
        case snakeBodyRight = "snakeBodyRight"
        case snakeBodyRightUp = "snakeBodyRightUp"
        case snakeBodyRightDown = "snakeBodyRightDown"
        case snakeTailUp = "snakeTailUp"
        case snakeTailLeft = "snakeTailLeft"
        case snakeTailDown = "snakeTailDown"
        case snakeTailRight = "snakeTailRight"
        case toxicMushroom = "🍄"
        case pufferFish = "🐡"
        case food = "🍖"
        case none = " "
    }
    
    //10位數 = 蛇的部位，個位數 = 方向
    enum itemValue: Int {
        case snakeHead = 50
        case snakeBody = 40
        case snakeTail = 30

        case toxicMushroom = 77
        case pufferFish = 88
        case food = 99
        case none = 0

        case snakeHeadUp = 51
        case snakeHeadLeft = 52
        case snakeHeadDown = 53
        case snakeHeadRight = 54
        case snakeBodyUp = 41
        case snakeBodyLeft = 42
        case snakeBodyDown = 43
        case snakeBodyRight = 44
        case snakeTailUp = 31
        case snakeTailLeft = 32
        case snakeTailDown = 33
        case snakeTailRight = 34
    }
    
    func pixelInit() {
        pixel.removeAll()
        pixelValue.removeAll()
        for x in 0...14 {
            pixel.append([UILabel]())
            pixelValue.append([Int]())
            for y in 0...14 {
                pixel[x].append(addPixel(location: (x, y)))
                pixelValue[x].append(0)
                snakeView.addSubview(pixel[x][y])
            }
        }
        //clear snake array
        snakeArray.removeAll()
        
        //snake head defined
        pixel[7][7].image(name: item.snakeHeadLeft.rawValue)
        pixelValue[7][7] = itemValue.snakeHead.rawValue + moveDirection.left.rawValue
        snakeArray.append(.init(x: 7, y: 7))

        //snake tail defined
        pixel[8][7].image(name: item.snakeTailLeft.rawValue)
        pixelValue[8][7] = itemValue.snakeTail.rawValue + moveDirection.left.rawValue
        snakeArray.append(.init(x: 8, y: 7))

        //food defined
        //addFood()
    }
    
    func pixelReset() {
        for x in 0...14 {
            for y in 0...14 {
                pixel[x][y].text = item.none.rawValue
                pixelValue[x][y] = itemValue.none.rawValue
            }
        }
        //clear snake array
        snakeArray.removeAll()
        
        //snake head defined
        pixel[7][7].image(name: item.snakeHeadLeft.rawValue)
        pixelValue[7][7] = itemValue.snakeHead.rawValue + moveDirection.left.rawValue
        snakeArray.append(.init(x: 7, y: 7))
        
        //snake tail defined
        pixel[8][7].image(name: item.snakeTailLeft.rawValue)
        pixelValue[8][7] = itemValue.snakeTail.rawValue + moveDirection.left.rawValue
        snakeArray.append(.init(x: 8, y: 7))
        
        //food defined
        //addFood()
    }

    func addPixel(location: (Int, Int)) -> UILabel {
        let (x, y) = location
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.center = CGPoint(x: x*20+10, y: y*20+10)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = item.none.rawValue

        return label
    }
    
    func addFood() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixelValue[x][y] == itemValue.none.rawValue {
                pixelValue[x][y] = itemValue.food.rawValue
                pixel[x][y].text = item.food.rawValue
                ret = true
            }
            ret = false
        } while ret == true
    }

    func addPufferFish() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixelValue[x][y] == itemValue.none.rawValue {
                pixelValue[x][y] = itemValue.pufferFish.rawValue
                pixel[x][y].text = item.pufferFish.rawValue
                ret = true
            }
            ret = false
        } while ret == true
    }
    
    func addToxicMushroom() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixelValue[x][y] == itemValue.none.rawValue {
                pixelValue[x][y] = itemValue.toxicMushroom.rawValue
                pixel[x][y].text = item.toxicMushroom.rawValue
                ret = true
            }
            ret = false
        } while ret == true
    }
    
    @objc func snakeWalk() {
        switch direction {
        case moveDirection.up:
            //print("walk - up")
            let headOrgX = snakeArray[0].x
            let headOrgY = snakeArray[0].y
            let headNewX = snakeArray[0].x
            var headNewY = snakeArray[0].y - 1
            if headNewY < 0 {
                headNewY = 14
            }
            let tailOrgX = snakeArray[snakeArray.count-1].x
            let tailOrgY = snakeArray[snakeArray.count-1].y
            let tailNewX = snakeArray[snakeArray.count-2].x
            let tailNewY = snakeArray[snakeArray.count-2].y
            snakeBodyMove(headOrg: (headOrgX, headOrgY), headNew: (headNewX, headNewY), tailOrg: (tailOrgX, tailOrgY), tailNew: (tailNewX, tailNewY))
        case moveDirection.down:
            //print("walk - down")
            let headOrgX = snakeArray[0].x
            let headOrgY = snakeArray[0].y
            let headNewX = snakeArray[0].x
            var headNewY = snakeArray[0].y + 1
            if headNewY > 14 {
                headNewY = 0
            }
            let tailOrgX = snakeArray[snakeArray.count-1].x
            let tailOrgY = snakeArray[snakeArray.count-1].y
            let tailNewX = snakeArray[snakeArray.count-2].x
            let tailNewY = snakeArray[snakeArray.count-2].y
            snakeBodyMove(headOrg: (headOrgX, headOrgY), headNew: (headNewX, headNewY), tailOrg: (tailOrgX, tailOrgY), tailNew: (tailNewX, tailNewY))
        case moveDirection.left:
            //print("walk - left")
            let headOrgX = snakeArray[0].x
            let headOrgY = snakeArray[0].y
            var headNewX = snakeArray[0].x - 1
            if headNewX < 0 {
                headNewX = 14
            }
            let headNewY = snakeArray[0].y
            let tailOrgX = snakeArray[snakeArray.count-1].x
            let tailOrgY = snakeArray[snakeArray.count-1].y
            let tailNewX = snakeArray[snakeArray.count-2].x
            let tailNewY = snakeArray[snakeArray.count-2].y
            snakeBodyMove(headOrg: (headOrgX, headOrgY), headNew: (headNewX, headNewY), tailOrg: (tailOrgX, tailOrgY), tailNew: (tailNewX, tailNewY))
        case moveDirection.right:
            //print("walk - right")
            let headOrgX = snakeArray[0].x
            let headOrgY = snakeArray[0].y
            var headNewX = snakeArray[0].x + 1
            if headNewX > 14 {
                headNewX = 0
            }
            let headNewY = snakeArray[0].y
            let tailOrgX = snakeArray[snakeArray.count-1].x
            let tailOrgY = snakeArray[snakeArray.count-1].y
            let tailNewX = snakeArray[snakeArray.count-2].x
            let tailNewY = snakeArray[snakeArray.count-2].y
            snakeBodyMove(headOrg: (headOrgX, headOrgY), headNew: (headNewX, headNewY), tailOrg: (tailOrgX, tailOrgY), tailNew: (tailNewX, tailNewY))
        }
        isSnakeMove = true
    }
    
    func snakeBodyMove(headOrg: (x: Int, y: Int), headNew: (x: Int, y: Int), tailOrg:  (x: Int, y: Int), tailNew:  (x: Int, y: Int)) {
        var isRemoveTail: Bool = true
        
        if fast > 0 {
            fast -= 1
        }
        if fast == 0 {
            setTimer(level: level)
        }
        
        if sick > 0 {
            sick -= 1
        }

        //head move
        switch direction.rawValue {
        case moveDirection.up.rawValue:
            if sick > 0 {
                pixel[headNew.x][headNew.y].imageColorInvert(name: item.snakeHeadUp.rawValue)
            } else if fast > 0 {
                pixel[headNew.x][headNew.y].imageFalseColor(name: item.snakeHeadUp.rawValue)
            } else {
                pixel[headNew.x][headNew.y].image(name: item.snakeHeadUp.rawValue)
            }
        case moveDirection.left.rawValue:
            if sick > 0 {
                pixel[headNew.x][headNew.y].imageColorInvert(name: item.snakeHeadLeft.rawValue)
            } else if fast > 0 {
                pixel[headNew.x][headNew.y].imageFalseColor(name: item.snakeHeadLeft.rawValue)
            } else {
                pixel[headNew.x][headNew.y].image(name: item.snakeHeadLeft.rawValue)
            }
        case moveDirection.down.rawValue:
            if sick > 0 {
                pixel[headNew.x][headNew.y].imageColorInvert(name: item.snakeHeadDown.rawValue)
            } else if fast > 0 {
                pixel[headNew.x][headNew.y].imageFalseColor(name: item.snakeHeadDown.rawValue)
            } else {
                pixel[headNew.x][headNew.y].image(name: item.snakeHeadDown.rawValue)
            }
        case moveDirection.right.rawValue:
            if sick > 0 {
                pixel[headNew.x][headNew.y].imageColorInvert(name: item.snakeHeadRight.rawValue)
            } else if fast > 0 {
                pixel[headNew.x][headNew.y].imageFalseColor(name: item.snakeHeadRight.rawValue)
            } else {
                pixel[headNew.x][headNew.y].image(name: item.snakeHeadRight.rawValue)
            }
        default:
            if sick > 0 {
                pixel[headNew.x][headNew.y].imageColorInvert(name: item.snakeHeadUp.rawValue)
            } else if fast > 0 {
                pixel[headNew.x][headNew.y].imageFalseColor(name: item.snakeHeadUp.rawValue)
            } else {
                pixel[headNew.x][headNew.y].image(name: item.snakeHeadUp.rawValue)
            }
        }
        //judegement head eat food or body
        if pixelValue[headNew.x][headNew.y] == itemValue.food.rawValue {
            //eat food (head = food)
            voiceEat.play()
            print("eat food")
            score += 10
            level += 1
            scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
            isRemoveTail = false
            setTimer(level: level)
        } else if pixelValue[headNew.x][headNew.y] == itemValue.toxicMushroom.rawValue {
            //eat Toxic Mushroom (head = Toxic Mushroom)
            voiceEat.play()
            print("eat Toxic Mushroom")
            if score > 10 {
                score -= 10
            } else {
                score = 0
            }
            fast = 10
            fastLevel = level
            scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
            setTimer(level: level + 20)
        } else if pixelValue[headNew.x][headNew.y] == itemValue.pufferFish.rawValue {
            //eat Puffer Fish (head = Puffer Fish)
            voiceEat.play()
            print("eat Puffer Fish")
            if score > 50 {
                score -= 50
            } else {
                score = 0
            }
            sick = 10
            sickLevel = level
            scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
        } else if Int(pixelValue[headNew.x][headNew.y]/10) == itemValue.snakeBody.rawValue/10 || Int(pixelValue[headNew.x][headNew.y]/10) == itemValue.snakeTail.rawValue/10 {
            //eat body (die...)
            voiceDie.play()
            print("eat body")
            timer.fireDate = NSDate.distantFuture
            reStartAlarm()
        }
        pixelValue[headNew.x][headNew.y] = itemValue.snakeHead.rawValue + direction.rawValue
        snakeArray.insert(.init(x: headNew.x, y: headNew.y), at: 0)

        //Body move
        switch pixelValue[headOrg.x][headOrg.y]%10 {
        case moveDirection.up.rawValue:
            if direction == moveDirection.up {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyUp.rawValue)
            } else if direction == moveDirection.left {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyUpLeft.rawValue)
            } else if direction == moveDirection.right {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyUpRight.rawValue)
            }
        case moveDirection.left.rawValue:
            if direction == moveDirection.left {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyLeft.rawValue)
            } else if direction == moveDirection.up {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyLeftUp.rawValue)
            } else if direction == moveDirection.down {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyLeftDown.rawValue)
            }
        case moveDirection.down.rawValue:
            if direction == moveDirection.down {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyDown.rawValue)
            } else if direction == moveDirection.left {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyDownLeft.rawValue)
            } else if direction == moveDirection.right {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyDownRight.rawValue)
            }
        case moveDirection.right.rawValue:
            if direction == moveDirection.right {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyRight.rawValue)
            } else if direction == moveDirection.up {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyRightUp.rawValue)
            } else if direction == moveDirection.down {
                pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyRightDown.rawValue)
            }
        default:
            pixel[headOrg.x][headOrg.y].image(name: item.snakeBodyUp.rawValue)
        }
        pixelValue[headOrg.x][headOrg.y] = itemValue.snakeBody.rawValue + direction.rawValue

        //tail move
        if isRemoveTail {
            switch pixelValue[tailNew.x][tailNew.y]%10 {
            case moveDirection.up.rawValue:
                pixel[tailNew.x][tailNew.y].image(name: item.snakeTailUp.rawValue)
            case moveDirection.left.rawValue:
                pixel[tailNew.x][tailNew.y].image(name: item.snakeTailLeft.rawValue)
            case moveDirection.down.rawValue:
                pixel[tailNew.x][tailNew.y].image(name: item.snakeTailDown.rawValue)
            case moveDirection.right.rawValue:
                pixel[tailNew.x][tailNew.y].image(name: item.snakeTailRight.rawValue)
            default:
                pixel[tailNew.x][tailNew.y].image(name: item.snakeTailUp.rawValue)
            }
            pixelValue[tailNew.x][tailNew.y] = itemValue.snakeTail.rawValue + pixelValue[tailNew.x][tailNew.y]%10
            pixel[tailOrg.x][tailOrg.y].image(name: "none")
            pixelValue[tailOrg.x][tailOrg.y] = itemValue.none.rawValue
            snakeArray.removeLast()
        } else {
            isRemoveTail = true
        }

        //check and generate food
        var hadFood: Bool = false
        var hadMushroom: Bool = false
        var hadFish: Bool = false
        for i in 0...14 {
            if pixelValue[i].contains(where: { $0 == itemValue.food.rawValue }) {
                hadFood = true
            }
            if pixelValue[i].contains(where: { $0 == itemValue.toxicMushroom.rawValue }) {
                hadMushroom = true
            }
            if pixelValue[i].contains(where: { $0 == itemValue.pufferFish.rawValue }) {
                hadFish = true
            }
        }
        if !hadFood {
            addFood()
        }
        if level%3 == 0 && !hadMushroom && fastLevel != level {
            addToxicMushroom()
        }
        if level%10 == 0 && !hadFish && sickLevel != level {
            addPufferFish()
        }
    }
    
    func reStartGame() {
        score = 0
        level = 1
        scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
        pixelReset()
        direction = moveDirection.left
        setTimer(level: level)
    }

    
}

extension UILabel {
    func image(name: String) {
        let attributedString = NSMutableAttributedString(string: " ")
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: name)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.replaceCharacters(in: NSMakeRange(0, 1), with: attrStringWithImage)
        self.attributedText = attributedString
    }
    
    func imageColorInvert(name: String) {
        let beginImage = CIImage(image: UIImage(named: name)!)
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            
            let attributedString = NSMutableAttributedString(string: " ")
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(ciImage: filter.outputImage!)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: NSMakeRange(0, 1), with: attrStringWithImage)
            self.attributedText = attributedString
        }
    }
    
    func imageFalseColor(name: String) {
        let beginImage = CIImage(image: UIImage(named: name)!)
        if let filter = CIFilter(name: "CIFalseColor") {
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            
            let attributedString = NSMutableAttributedString(string: " ")
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(ciImage: filter.outputImage!)
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: NSMakeRange(0, 1), with: attrStringWithImage)
            self.attributedText = attributedString
        }
    }
}

extension UIView {
    func addBackground() {
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        imageViewBackground.image = UIImage(named: "grassland")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }
    
    func addSnakeBackground() {
        self.transform = CGAffineTransform(translationX: (UIScreen.main.bounds.size.width-300)/2, y: (UIScreen.main.bounds.size.height-300)/2)
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageViewBackground.image = UIImage(named: "ground")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }


}


