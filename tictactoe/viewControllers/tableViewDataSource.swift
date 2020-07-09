//
//  tableViewDataSource.swift
//  tictactoe
//
//  Created by DiZenzo on 7/4/20.
//  Copyright © 2020 DiZenzo. All rights reserved.
//

import UIKit
import SocketIO

class tableViewDataSource: UITableViewController{
    
    
    let alert = UIAlertController(title: "Create Room", message: "Make a room title", preferredStyle: .alert)
    var roomTitle = "Default"
    var hostname = "User"
    
    @IBAction func creatingRoom(_ sender: Any) {
        self.present(alert,animated: true,completion: nil)
    }
    
    @objc func reload(){
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name("reload"), object: nil)
        alert.addTextField{
            (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {[weak alert] (val) in
            let textField = alert?.textFields![0]
            self.roomTitle = textField!.text ?? "Default"
            serverConnection.createRoom(title: self.roomTitle,host: self.hostname)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {[weak alert] (val) in
            _ = alert?.textFields![0]
        }))
        
        createButton()
        
    }
    
    func createButton(){
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.orange, for: .normal)
        button.setTitle("Make a Room", for: .normal)
        button.addTarget(self, action: #selector(creatingRoom), for: UIControl.Event.touchUpInside)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderColor = CGColor(srgbRed: 7/255, green: 135/255, blue: 254/255, alpha: 1)
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor(red: 7/255, green: 135/255, blue: 254/255, alpha: 1), for: .normal)
        view.addSubview(button)
        view.addConstraints([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
        button.heightAnchor.constraint(equalToConstant: 60)])

        view.bringSubviewToFront(button)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("joining row: " + String(indexPath.row))
        serverConnection.joinRoom(row: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverConnection.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = serverConnection.rooms[indexPath.row].title
        
        return cell
    }
}

