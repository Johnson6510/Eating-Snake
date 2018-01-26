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
    var snakeArray = [location()]
    var isSnakeMove: Bool = true

    var level: Int = 1
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: " + String(score) + ", Lv: " + String(level)
        }
    }
    
    var sick = 0
    var fast = 0
    var sickLevel = -1
    var fastLevel = -1
    var timeInterval: Double = 0.0

    var direction: Int = UILabel.moveDirection.left.rawValue {
        willSet {
            lastDirection = direction
        }
    }
    var lastDirection: Int = UILabel.moveDirection.left.rawValue

    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //setup voice - eat
        
        //initial background image
        allView.addBackground()
        snakeView.addSnakeBackground()
        
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
        if direction == UILabel.moveDirection.left.rawValue || direction == UILabel.moveDirection.right.rawValue {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Up")
                    direction = UILabel.moveDirection.up.rawValue
                } else {
                    print("Swipe - Up (sick to down)")
                    direction = UILabel.moveDirection.down.rawValue
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer!) {
        if direction == UILabel.moveDirection.left.rawValue || direction == UILabel.moveDirection.right.rawValue {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Down")
                    direction = UILabel.moveDirection.down.rawValue
                } else {
                    print("Swipe - Down (sick to up)")
                    direction = UILabel.moveDirection.up.rawValue
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer!) {
        if direction == UILabel.moveDirection.up.rawValue || direction == UILabel.moveDirection.down.rawValue {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Left")
                    direction = UILabel.moveDirection.left.rawValue
                } else {
                    print("Swipe - Left (sick to right)")
                    direction = UILabel.moveDirection.right.rawValue
                }
                isSnakeMove = false
            }
        }
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer!) {
        if direction == UILabel.moveDirection.up.rawValue || direction == UILabel.moveDirection.down.rawValue {
            if isSnakeMove {
                if sick == 0 {
                    print("Swipe - Right")
                    direction = UILabel.moveDirection.right.rawValue
                } else {
                    print("Swipe - Right (sick to left)")
                    direction = UILabel.moveDirection.left.rawValue
                }
                isSnakeMove = false
            }
        }
    }

    func setTimer(level: Int) {
        timer.invalidate()
        timeInterval = 0.5 - Double(level - 1) * 0.005
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(EatingSnake.snakeWalk), userInfo: nil, repeats: true)
    }
    
    func pixelInit() {
        pixel.removeAll()
        for x in 0...14 {
            pixel.append([UILabel]())
            for y in 0...14 {
                pixel[x].append(addPixel(location: (x, y)))
                pixel[x][y].status = UILabel.status.normal.rawValue
                pixel[x][y].value = UILabel.itemValue.none.rawValue
                snakeView.addSubview(pixel[x][y])
            }
        }
        //clear snake array
        snakeArray.removeAll()
        
        //snake head defined
        pixel[7][7].value = UILabel.itemValue.snakeHead.rawValue + direction
        snakeArray.append(.init(x: 7, y: 7))

        //snake tail defined
        pixel[8][7].value = UILabel.itemValue.snakeTail.rawValue + direction
        snakeArray.append(.init(x: 8, y: 7))
    }
    
    func pixelReset() {
        for x in 0...14 {
            for y in 0...14 {
                pixel[x][y].status = UILabel.status.normal.rawValue
                pixel[x][y].value = UILabel.itemValue.none.rawValue
            }
        }
        //clear snake array
        snakeArray.removeAll()
        
        direction = UILabel.moveDirection.left.rawValue
        lastDirection = UILabel.moveDirection.left.rawValue

        //snake head defined
        pixel[7][7].value = UILabel.itemValue.snakeHead.rawValue + direction
        snakeArray.append(.init(x: 7, y: 7))
        
        //snake tail defined
        pixel[8][7].value = UILabel.itemValue.snakeTail.rawValue + direction
        snakeArray.append(.init(x: 8, y: 7))
    }

    func addPixel(location: (Int, Int)) -> UILabel {
        let (x, y) = location
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.center = CGPoint(x: x*20+10, y: y*20+10)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.value = UILabel.itemValue.none.rawValue

        return label
    }
    
    func addFood() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixel[x][y].value == UILabel.itemValue.none.rawValue {
                pixel[x][y].value = UILabel.itemValue.food.rawValue
                ret = true
            }
            ret = false
        } while ret!
    }

    func addPufferFish() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixel[x][y].value == UILabel.itemValue.none.rawValue {
                pixel[x][y].value = UILabel.itemValue.pufferFish.rawValue
                ret = true
            }
            ret = false
        } while ret!
    }
    
    func addToxicMushroom() {
        var ret: Bool?
        repeat {
            let x = Int(arc4random_uniform(15))
            let y = Int(arc4random_uniform(15))
            if pixel[x][y].value == UILabel.itemValue.none.rawValue {
                pixel[x][y].value = UILabel.itemValue.toxicMushroom.rawValue
                ret = true
            }
            ret = false
        } while ret!
    }
    
    @objc func snakeWalk() {
        switch direction {
        case UILabel.moveDirection.up.rawValue:
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
        case UILabel.moveDirection.down.rawValue:
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
        case UILabel.moveDirection.left.rawValue:
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
        case UILabel.moveDirection.right.rawValue:
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
        default:
            break
        }
        isSnakeMove = true
    }
    
    func snakeBodyMove(headOrg: (x: Int, y: Int), headNew: (x: Int, y: Int), tailOrg:  (x: Int, y: Int), tailNew:  (x: Int, y: Int)) {
        var isRemoveTail: Bool = true

        //head move
        //check status
        pixel[headOrg.x][headOrg.y].status = UILabel.status.normal.rawValue
        if sick > 0 {
            pixel[headNew.x][headNew.y].status = UILabel.status.sick.rawValue
            sick -= 1
        } else if fast > 0 {
            pixel[headNew.x][headNew.y].status = UILabel.status.fast.rawValue
            fast -= 1
            if fast == 0 {
                setTimer(level: level)
            }
        } else {
            pixel[headNew.x][headNew.y].status = UILabel.status.normal.rawValue
        }
        //judegement head eat food or body
        if pixel[headNew.x][headNew.y].value == UILabel.itemValue.food.rawValue {
            //eat food (head = food)
            voiceEat.play()
            print("eat food")
            level += 1
            score += 10
            isRemoveTail = false
            setTimer(level: level)
        } else if pixel[headNew.x][headNew.y].value == UILabel.itemValue.toxicMushroom.rawValue {
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
            setTimer(level: level + 20)
        } else if pixel[headNew.x][headNew.y].value == UILabel.itemValue.pufferFish.rawValue {
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
        } else if pixel[headNew.x][headNew.y].value.hundreds == UILabel.itemValue.snakeBody.rawValue || pixel[headNew.x][headNew.y].value.hundreds == UILabel.itemValue.snakeTail.rawValue {
            //eat body (die...)
            voiceDie.play()
            print("eat body")
            timer.fireDate = NSDate.distantFuture
            reStartAlarm()
        }
        pixel[headNew.x][headNew.y].value = UILabel.itemValue.snakeHead.rawValue + direction
        snakeArray.insert(.init(x: headNew.x, y: headNew.y), at: 0)

        //Body move
        pixel[headOrg.x][headOrg.y].value = UILabel.itemValue.snakeBody.rawValue + direction
        if lastDirection != direction  {
            pixel[headOrg.x][headOrg.y].value += lastDirection * 10
            lastDirection = direction
        }

        //tail move
        if isRemoveTail {
            pixel[tailNew.x][tailNew.y].value = UILabel.itemValue.snakeTail.rawValue + pixel[tailNew.x][tailNew.y].value.units
            pixel[tailOrg.x][tailOrg.y].value = UILabel.itemValue.none.rawValue
            snakeArray.removeLast()
        } else {
            isRemoveTail = true
        }

        //check and generate food
        var hadFood: Bool = false
        var hadMushroom: Bool = false
        var hadFish: Bool = false
        for i in 0...14 {
            var tempPixelArray = [Int]()
            for j in 0...14 {
                tempPixelArray.append(pixel[i][j].value)
            }
            if tempPixelArray.contains(where: { $0 == UILabel.itemValue.food.rawValue }) {
                hadFood = true
            }
            if tempPixelArray.contains(where: { $0 == UILabel.itemValue.toxicMushroom.rawValue }) {
                hadMushroom = true
            }
            if tempPixelArray.contains(where: { $0 == UILabel.itemValue.pufferFish.rawValue }) {
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
        level = 1
        score = 0
        pixelReset()
        direction = UILabel.moveDirection.left.rawValue
        setTimer(level: level)
    }

    
}

extension Int {
    var units: Int {
        get {
            return self % 10
        }
    }
    
    var tens: Int {
        get {
            return self / 10 % 10 * 10
        }
    }

    var hundreds: Int {
        get {
            return self / 100 % 10 * 100
        }
    }
}

extension UILabel {
    enum item: String {
        case toxicMushroom = "🍄"
        case pufferFish = "🐡"
        case food = "🍖"
        case none = " "
    }

    enum moveDirection: Int {
        case up = 1
        case left = 2
        case down = 3
        case right = 4
    }

    enum status: Int {
        case normal = 0
        case sick = 1
        case fast = 2
    }
    
    //佰位數 = 蛇的部位，十位數 = 原來方向，個位數 = 目前方向
    enum itemValue: Int {
        case snakeHead = 500
        case snakeBody = 400
        case snakeTail = 300
        
        case toxicMushroom = 77
        case pufferFish = 88
        case food = 99
        case none = 0
    }

    private struct cell {
        static var value: Int = 0
        static var status: Int = 0
    }

    var value: Int {
        get {
            return objc_getAssociatedObject(self, &cell.value) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.value, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue == itemValue.none.rawValue {
                self.text = UILabel.item.none.rawValue
            } else if newValue == itemValue.food.rawValue {
                self.text = UILabel.item.food.rawValue
            } else if newValue == itemValue.toxicMushroom.rawValue {
                self.text = UILabel.item.toxicMushroom.rawValue
            } else if newValue == itemValue.pufferFish.rawValue {
                self.text = UILabel.item.pufferFish.rawValue
            } else {
                var imageName: String = ""

                switch newValue.hundreds {
                case itemValue.snakeHead.rawValue:
                    imageName = "snakeHead"
                case itemValue.snakeBody.rawValue:
                    imageName = "snakeBody"
                case itemValue.snakeTail.rawValue:
                    imageName = "snakeTail"
                default:
                    break
                }
                
                switch newValue.tens / 10 {
                case moveDirection.up.rawValue:
                    imageName += "Up"
                case moveDirection.left.rawValue:
                    imageName += "Left"
                case moveDirection.down.rawValue:
                    imageName += "Down"
                case moveDirection.right.rawValue:
                    imageName += "Right"
                default:
                    break
                }

                switch newValue.units {
                case moveDirection.up.rawValue:
                    imageName += "Up"
                case moveDirection.left.rawValue:
                    imageName += "Left"
                case moveDirection.down.rawValue:
                    imageName += "Down"
                case moveDirection.right.rawValue:
                    imageName += "Right"
                default:
                    break
                }
                
                if self.status == status.sick.rawValue && newValue.hundreds == itemValue.snakeHead.rawValue {
                    self.imageColorInvert(name: imageName)
                } else if self.status == status.fast.rawValue && newValue.hundreds == itemValue.snakeHead.rawValue {
                    self.imageFalseColor(name: imageName)
                } else {
                    self.image(name: imageName)
                }
                print("Debug:", newValue.hundreds, newValue.tens, newValue.units, imageName)
            }
        }
    }
    
    var status: Int {
        get {
            return objc_getAssociatedObject(self, &cell.status) as! Int
        }
        set {
            objc_setAssociatedObject(self, &cell.status, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

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


