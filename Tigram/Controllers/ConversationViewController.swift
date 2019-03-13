//
//  ConversationViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 24/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var lastColorOfNavigationBar: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastColorOfNavigationBar = navigationController?.navigationBar.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    let chatMessages: [String] = ["It is a period of civil war.",
                                  "Rebel spaceships, striking from a hidden base, have won their first victory against the evil Galactic Empire.",
                                  "During the battle, Rebel spies managed to steal secret plans to the Empire's ultimate weapon, the DEATH STAR, an armored space station with enough power to destroy an entire planet.",
                                  "Pursued by the Empire's sinister agents, Princess Leia races home aboard her starship, custodian of the stolen plans that can save her people and restore freedom to the galaxy.",
                                  "It is a dark time for the Rebellion.",
                                  "It is a dark time for the Rebellion.",
                                  "Evading the dreaded Imperial Starfleet, a group of freedom fighters led by Luke Skywalker has established a new secret base on the remote ice world of Hoth.",
                                   "The evil lord Darth Vader.",
                                   "Obsessed with finding young Skywalker, has dispatched thousands of remote probes into the far reaches of space."]

}


extension ConversationViewController: UITableViewDelegate {
    
}

extension ConversationViewController: UITableViewDataSource {
    
    // Let it be 9 messages in each chat
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    // Creates a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row % 2 == 0 ? "Incoming Message" : "Sent Message"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageTableViewCell
        
        cell.configureMessage(withText: chatMessages[indexPath.row])
        updateCellWithCurrentTheme(cell)
        return cell
    }
    
    func updateCellWithCurrentTheme(_ cell: MessageTableViewCell) {
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        switch themeName {
        case "light":
            cell.backgroundColor = ThemeManager().light
        case "dark":
            cell.backgroundColor = ThemeManager().dark
        case "champagne":
            cell.backgroundColor = ThemeManager().champagne
        default:
            NSLog("No valid name for theme")
        }
    }
}
