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
        
    @IBAction func action(_ sender: AnyObject) {
        print("I'm creebo")
        serverConn.makeMove(move: sender.tag)
    }
    
    @objc func reload(){
        print("reloading board")
        gameBoard = serverConn.gameBoard
        
        print("Game board is:")
        print(gameBoard)
        for case let button as UIButton in self.view.subviews {
            if (button.tag < 10){
                if (gameBoard[button.tag] == 1){
                    button.setImage(UIImage(named: "big-red-x.png"), for: UIControl.State())
                }else if (gameBoard[button.tag] == 2){
                    button.setImage(UIImage(named: "big-blue-o.png"), for: UIControl.State())
                }
            }
        }
        
    }
    
    @objc func reloadRematch(){
        rematch = serverConn.rematch
        let v:UIProgressView = view.viewWithTag(11) as! UIProgressView
        print("Creebo!!!")
        v.progress = (rematch==0) ? 0.0:0.5
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
        print("I won!")
        makeReset()
    }
    
    @objc func gameLost(){
        print("I lost :(")
//        for case let button as UIButton in self.view.subviews {
//            button.setImage(nil, for: .normal)
//        }
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
        
        drawBoard()
        reload()
    }
    
    func makeReset(){
        if (serverConn.player > 2){
            return
        }
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let xPos = 10
        let yPos = height/2-width/2-30
        var frame: CGRect = CGRect(x: CGFloat(xPos), y: CGFloat(yPos), width: CGFloat(width/2), height:CGFloat(height/20))
        print(frame)
        let newView = UIButton(frame: frame)
        newView.backgroundColor = UIColor(red: CGFloat(49/255), green: CGFloat(134/255), blue: CGFloat(255/255), alpha: CGFloat(1))
        newView.setTitle("Rematch", for: .normal)
        newView.tag = 10
        newView.layer.cornerRadius = 5
        newView.addTarget(self, action: #selector(callReset), for: .touchUpInside)
        view.addSubview(newView)
        
        
        frame = CGRect(x: CGFloat(xPos), y: CGFloat(yPos-50), width: CGFloat(width/2), height:CGFloat(height/5))
        print(frame)
        let newView2 = UIProgressView(frame: frame)
//        newView2.backgroundColor = UIColor(red: CGFloat(49/255), green: CGFloat(134/255), blue: CGFloat(255/255), alpha: CGFloat(1))
        newView2.tag = 11
        newView2.layer.cornerRadius = 10
        newView2.transform = newView2.transform.scaledBy(x: 1, y: 8)
        newView2.progress = 0.0
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
            print(CGRect(x: x, y: y, width: width/3, height: width/3))
//            tempButton.backgroundColor = colorArray[n%3]
            tempButton.addTarget(self, action: #selector(action), for: .touchUpInside)
            tempButton.tag = n

            view.addSubview(tempButton)

        }
        
    }
    
}
