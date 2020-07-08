//
//  boardView.swift
//  tictactoe
//
//  Created by DiZenzo on 7/6/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import UIKit

class boardView : UIViewController {
    
    var gameBoard = serverConn.gameBoard
    var rematch = serverConn.rematch
    var chat = false
        
    @IBAction func action(_ sender: AnyObject) {
        serverConn.makeMove(move: sender.tag-1)
    }
    
    @IBAction func onChatPress(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let duration: TimeInterval = 0.6
        let displacement:CGFloat = 60
        
        if sender.isSelected {
            sender.backgroundColor = UIColor(red: 7/255, green: 135/255, blue: 254/255, alpha: 1)
            sender.setTitleColor(.white, for: .normal)
            moveChats(displacement: displacement,duration: duration)
        } else{
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
            moveChats(displacement: -1*displacement,duration: duration)
        }
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        serverConn.sendChat(chat: (sender.titleLabel?.text)!)
    }
    
    func setChats(){
        self.view.layoutIfNeeded()
        let chatTags = [40,41,42,43]
        if let chatView = view.viewWithTag(45) as? UIButton{
            for i in 0...3{
                if let tempView = view.viewWithTag(chatTags[i]) as? UIButton{
                    
                    tempView.frame = chatView.frame
                    tempView.backgroundColor = .white
                    tempView.layer.borderColor = CGColor(srgbRed: 7/255, green: 135/255, blue: 254/255, alpha: 1)
                    tempView.layer.borderWidth = 3
                    tempView.setTitleColor(UIColor(red: 7/255, green: 135/255, blue: 254/255, alpha: 1), for: .normal)
                    self.view.bringSubviewToFront(tempView)
                
                }
            }
            self.view.bringSubviewToFront(chatView)
        }
    }
    func moveChats(displacement:CGFloat,duration: Double){
        self.view.layoutIfNeeded()
        let chatTags = [40,41,42,43]
        for i in 0...3{
            if let tempView = view.viewWithTag(chatTags[i]){
                let offset:CGFloat = CGFloat(i+1)*displacement
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
                    tempView.frame = CGRect(x: tempView.frame.origin.x, y: tempView.frame.origin.y - offset, width: tempView.frame.width, height: tempView.frame.height)
                }, completion: nil)
            
            }
        }
        
    }
    
    @objc func reload(){
        gameBoard = serverConn.gameBoard
        for i in 1...9{
            if let button:UIButton = view.viewWithTag(i) as? UIButton{
                if (gameBoard[button.tag-1] == 1){
                    button.setImage(UIImage(named: "big-red-x.png"), for: UIControl.State())
                }else if (gameBoard[button.tag-1] == 2){
                    button.setImage(UIImage(named: "big-blue-o.png"), for: UIControl.State())
                }else{
                    button.setImage(nil, for: UIControl.State())
                }
            }
            
        }
        
    }
    
    @objc func reloadRematch(){
        rematch = serverConn.rematch
        if let v:UIProgressView = view.viewWithTag(11) as? UIProgressView{
            v.progress = (rematch==0) ? 0.0:0.5
        }else{
            makeReset()
        }
    }
    
    @objc func removeRematch(){
        view.viewWithTag(10)?.removeFromSuperview()
        view.viewWithTag(11)?.removeFromSuperview()
        for case let button as UIButton in self.view.subviews {
            if (button.tag < 10){
                button.setImage(nil, for: UIControl.State())
            }
        }
    }
    
    @objc func gameWin(){
        makeReset()
    }
    
    @objc func gameLost(){
        makeReset()
    }
    
    @objc func callReset(){
        serverConn.callReset()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name("reloadGameBoard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gameWin), name: Notification.Name("gameWin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gameLost), name: Notification.Name("gameLost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeRematch), name: Notification.Name("removeRematch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRematch), name: Notification.Name("reloadRematch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showChat), name: Notification.Name("showChat"), object: nil)
        
        drawBoard()
        reload()
        setChats()
    }
    
    @objc func showChat(notification: Notification){
        guard let text = notification.userInfo?["chat"] as? String else { return }
        
        
        let width: CGFloat = UIScreen.main.bounds.width
        let height:CGFloat = UIScreen.main.bounds.height
        let yPos:CGFloat = height/2-width/2-50
        let label = UILabel(frame: CGRect(x: 0, y: yPos, width: width, height: 40))
        label.center = CGPoint(x: width/2, y: yPos)
        label.textAlignment = NSTextAlignment.center
        label.text = text
        view.addSubview(label)
        view.bringSubviewToFront(label)
        
        
        label.fadeIn(completion: {
            (finished: Bool) -> Void in
            label.fadeOut(duration: 1, delay: 0, completion: {
                (finished: Bool) -> Void in
                label.removeFromSuperview()
            })
        })
        
    }
    
    func makeReset(){
        if (serverConn.player > 2){
            return
        }
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let xPos = 10
        let yPos = height/2-width/2-height/20-3
        var frame: CGRect = CGRect(x: CGFloat(xPos), y: CGFloat(yPos), width: CGFloat(width/3), height:CGFloat(height/20))
        let newView = UIButton(frame: frame)
        newView.backgroundColor = UIColor(red: CGFloat(49/255), green: CGFloat(134/255), blue: CGFloat(255/255), alpha: CGFloat(1))
        newView.setTitle("Rematch", for: .normal)
        newView.tag = 10
        newView.layer.cornerRadius = 5
        newView.addTarget(self, action: #selector(callReset), for: .touchUpInside)
        newView.layer.zPosition = 1
        view.addSubview(newView)
        
        
        frame = CGRect(x: CGFloat(xPos), y: CGFloat(yPos-20), width: CGFloat(width/3), height:CGFloat(height/5))
        let newView2 = UIProgressView(frame: frame)
//        newView2.backgroundColor = UIColor(red: CGFloat(49/255), green: CGFloat(134/255), blue: CGFloat(255/255), alpha: CGFloat(1))
        newView2.tag = 11
        newView2.layer.cornerRadius = 30
        newView2.transform = newView2.transform.scaledBy(x: 1, y: 8)
        newView2.progress = 0.0
        newView2.layer.zPosition = 1
        view.addSubview(newView2)
        
        
    }
    
    func drawBoard(){

        // Draw vertical bars
        let thickness:CGFloat = 5
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        for n in 1...2{
            let xPos = width*(CGFloat(n)/3)-thickness
            let yPos = height/2-width/2
            
            let rectFrame: CGRect = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:CGFloat(thickness*2), height:CGFloat(width))
            let greenView = UIView(frame: rectFrame)
            greenView.backgroundColor = UIColor.black
            greenView.tag = 20+n
            greenView.layer.zPosition = 1
            view.addSubview(greenView)
            
        }
        
        // Draw Horizontal bars
        for n in 1...2{
            let xPos = 0
            let offset = ((width) * ((2*CGFloat(n)) - 3)/6)
            let yPos = height/2-offset-thickness

            let rectFrame: CGRect = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:CGFloat(width), height:CGFloat(thickness*2))
            let greenView = UIView(frame: rectFrame)
            greenView.backgroundColor = UIColor.black
            greenView.tag = 22+n
            greenView.layer.zPosition = 1
            view.addSubview(greenView)

        }
        
        // Draw square buttons
        var x : CGFloat
        var y : CGFloat
        for n in 0...8{
            x = CGFloat((n%3))*width/3 + thickness
            
            let flr = CGFloat(n/3-2)
            y = height/2+(2*flr+1)*width/6+thickness
            
            
            let tempButton = UIButton(frame: CGRect(x: x, y: y, width: (width/3-thickness*2), height: (width/3-thickness*2)))
            tempButton.addTarget(self, action: #selector(action), for: .touchUpInside)
            tempButton.tag = n+1
            tempButton.layer.zPosition = 1
            view.addSubview(tempButton)

        }
        
                
    }
    
    
}

extension UIView {


    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.alpha = 1.0
        }, completion: completion)  }

    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 1.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in }) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.alpha = 0.0
        self.frame.origin.y += 40
        }, completion: completion)
}

}

