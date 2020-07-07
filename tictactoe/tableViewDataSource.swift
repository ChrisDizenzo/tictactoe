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
    var hostname = "Creebo"
    
    @IBAction func creatingRoom(_ sender: Any) {
        print("I'm johhny")
        self.present(alert,animated: true,completion: nil)
    }
    
    
    
    @objc func reload(){
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name("reload"), object: nil)
        print("I like puppies")
        alert.addTextField{
            (textField) in
            textField.text = "Default"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {[weak alert] (val) in
            let textField = alert?.textFields![0]
            self.roomTitle = textField!.text ?? "Creebo"
            serverConn.createRoom(title: self.roomTitle,host: self.hostname)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {[weak alert] (val) in
            _ = alert?.textFields![0]
        }))
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("joining row: " + String(indexPath.row))
        serverConn.joinRoom(row: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverConn.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = serverConn.rooms[indexPath.row].title
        
        return cell
    }
}

