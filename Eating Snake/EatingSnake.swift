//
//  EatingSnake.swift
//  Eating Snake
//
//  Created by 黃健偉 on 2018/1/8.
//  Copyright © 2018年 黃健偉. All rights reserved.
//

import UIKit

class EatingSnake: UIViewController {
    
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

    var score = 0
    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var snakeView: UIView!
 
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
        print("Swipe - Up")
        if direction == moveDirection.left || direction == moveDirection.right {
            direction = moveDirection.up
        }
    }
    
    @objc(down:)
    func downCommand(_ r: UIGestureRecognizer!) {
        print("Swipe - Down")
        if direction == moveDirection.left || direction == moveDirection.right {
            direction = moveDirection.down
        }
    }
    
    @objc(left:)
    func leftCommand(_ r: UIGestureRecognizer!) {
        print("Swipe - Left")
        if direction == moveDirection.up || direction == moveDirection.down {
            direction = moveDirection.left
        }
    }
    
    @objc(right:)
    func rightCommand(_ r: UIGestureRecognizer!) {
        print("Swipe - Right")
        if direction == moveDirection.up || direction == moveDirection.down {
            direction = moveDirection.right
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSwipeControls()
        scoreLabel.text = String(score)
        pixelInit()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(EatingSnake.snakeWalk), userInfo: nil, repeats: true)
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
    
    var direction = moveDirection.left
    enum moveDirection {
        case up
        case down
        case left
        case right
    }

    enum item: String {
        case snakeHead = "🐸"
        case snakeBody = "🎾"
        case snakeTail = "🎄"
        case food = "🍖"
        case none = ""
    }
    
    enum itemValue: Int {
        case snakeHead = 5
        case snakeBody = 4
        case snakeTail = 3
        case food = 1
        case none = 0
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
        pixel[7][7].text = item.snakeHead.rawValue
        pixelValue[7][7] = itemValue.snakeHead.rawValue
        snakeArray.append(.init(x: 7, y: 7))

        //snake tail defined
        pixel[8][7].text = item.snakeTail.rawValue
        pixelValue[8][7] = itemValue.snakeTail.rawValue
        snakeArray.append(.init(x: 8, y: 7))

        //food defined
        addFood()
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
        pixel[7][7].text = item.snakeHead.rawValue
        pixelValue[7][7] = itemValue.snakeHead.rawValue
        snakeArray.append(.init(x: 7, y: 7))
        
        //snake tail defined
        pixel[8][7].text = item.snakeTail.rawValue
        pixelValue[8][7] = itemValue.snakeTail.rawValue
        snakeArray.append(.init(x: 8, y: 7))
        
        //food defined
        addFood()
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
    }
    
    func snakeBodyMove(headOrg: (x: Int, y: Int), headNew: (x: Int, y: Int), tailOrg:  (x: Int, y: Int), tailNew:  (x: Int, y: Int)) {
        var isRemoveTail: Bool = true
        //head move
        pixel[headNew.x][headNew.y].text = item.snakeHead.rawValue
        //eat food (head = food)
        if pixelValue[headNew.x][headNew.y] == itemValue.food.rawValue {
            print("eat food")
            score += 10
            scoreLabel.text = String(score)
            isRemoveTail = false
        //eat body (die...)
        } else if pixelValue[headNew.x][headNew.y] == itemValue.snakeBody.rawValue || pixelValue[headNew.x][headNew.y] == itemValue.snakeTail.rawValue {
            print("eat body")
            timer.fireDate = NSDate.distantFuture
            reStartAlarm()
        }
        pixelValue[headNew.x][headNew.y] = itemValue.snakeHead.rawValue
        pixel[headOrg.x][headOrg.y].text = item.snakeBody.rawValue
        pixelValue[headOrg.x][headOrg.y] = itemValue.snakeBody.rawValue
        snakeArray.insert(.init(x: headNew.x, y: headNew.y), at: 0)
        
        //tail move
        if isRemoveTail {
            pixel[tailOrg.x][tailOrg.y].text = item.none.rawValue
            pixelValue[tailOrg.x][tailOrg.y] = itemValue.none.rawValue
            pixel[tailNew.x][tailNew.y].text = item.snakeTail.rawValue
            pixelValue[headOrg.x][headOrg.y] = itemValue.snakeTail.rawValue
            snakeArray.removeLast()
        } else {
            isRemoveTail = true
        }
    
        //check and generate food
        var hadFood: Bool = false
        for i in 0...14 {
            if pixelValue[i].contains(where: { $0 == itemValue.food.rawValue }) {
                hadFood = true
            }
        }
        if !hadFood {
            addFood()
        }
    }
    
    func reStartGame() {
        score = 0
        timer.fireDate = NSDate.distantPast
        scoreLabel.text = String(score)
        pixelReset()
        direction = moveDirection.left

    }

    
}


