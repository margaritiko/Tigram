//
//  ConversationsListViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 23/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    // MARK: Data
    let sectionsTitles: [String] = ["Online", "History"]
    
    let usersNames: [String] = ["Padmé Amidala",
                                "Cassian Andor",
                                "Cad Bane",
                                "Commander Bly",
                                "BB-8",
                                "C-3PO",
                                "Jar Jar Binks",
                                "Lieutenant Kaydel Ko Connix",
                                "Chewbacca",
                                "Galen Erso",
                                "Obi-Wan Kenobi",
                                "Leia Organa",
                                "Jyn Erso",
                                "Jabba the Hutt",
                                "R2-D2",
                                "Anakin Skywalker",
                                "Kylo Ren",
                                "Han Solo",
                                "Luke Skywalker",
                                "Shmi Skywalker"]
    
    let usersMessages: [String?] = ["She served as the Princess 👑 of Theed and later Queen of Naboo.",
                                    "He is a pilot, intelligence officer for the Rebel Alliance, and leader of Rogue One, a rebel unit attempting to steal the plans to the Death Star, a powerful weapon.",
                                    nil,
                                    nil,
                                    "I am a cute droid! 🤤",
                                    "Protocol droid 👾 who appears throughout the Star Wars films.",
                                    nil,
                                    nil,
                                    "Han Solo's Wookiee partner and co-pilot of the Millennium Falcon.",
                                    "Imperial research scientist and the father of Jyn Erso in Rogue One and the prequel novel Catalyst: A Rogue One Novel. As prime designer of the Death Star, Erso supplies information on a critical weakness to the Rebellion, allowing an attack on the seemingly-invulnerable battle station.",
                                    "Wise and skilled Jedi Master who trains Anakin and later Luke Skywalker.",
                                    "Leader in the Rebel Alliance, the New Republic, and the Resistance.",
                                    nil,
                                    nil,
                                    "Astromech droid built on Naboo",
                                    "Darth Vader ⚔️",
                                    nil,
                                    nil,
                                    "Son of Anakin Skywalker and Padmé Amidala 💘",
                                    "Anakin Skywalker's mother ❤️❤️❤️",
                                    ]
    
    let usersMessagesDates: [Date] = [Date(timeIntervalSinceNow: -68820),
                                      Date(),
                                      Date(),
                                      Date(),
                                      Date(timeIntervalSince1970: 10000),
                                      Date(timeIntervalSinceReferenceDate: 100000),
                                      Date(timeIntervalSince1970: 366363),
                                      Date(timeIntervalSinceReferenceDate: 38383838),
                                      Date(timeIntervalSinceNow: 10),
                                      Date(timeIntervalSinceNow: 10),
                                      Date(),
                                      Date(),
                                      Date(),
                                      Date(),
                                      Date(timeIntervalSince1970: 3939393763),
                                      Date(timeIntervalSinceReferenceDate: 35353553),
                                      Date(timeIntervalSince1970: 2818283663),
                                      Date(timeIntervalSinceReferenceDate: 446645247),
                                      Date(timeIntervalSinceNow: 10),
                                      Date(timeIntervalSinceNow: 10)]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setUpNavigationBar()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Open Chat") {
            let cell = sender as? ChatWindowTableViewCell
            let conversationViewController = segue.destination as? ConversationViewController
            conversationViewController?.title = cell?.name
        }
    }
    

    func setUpNavigationBar() {
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        // navigationItem.largeTitleDisplayMode = .never
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    
}

extension ConversationsListViewController: UITableViewDataSource {
    
    // There are only two sections: Online and History
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Returns title for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsTitles[section]
    }
    
    // Let it be 15 chat windows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height * 0.18
    }
    
    // Creates a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chat Window", for: indexPath) as? ChatWindowTableViewCell ?? ChatWindowTableViewCell()
        
        cell.configureChatWindowCellWithData(userName: usersNames[indexPath.section * 10 + indexPath.row], message: usersMessages[indexPath.section * 10 + indexPath.row],
                                             date: usersMessagesDates[indexPath.section * 10 + indexPath.row],
                                             isOnline: indexPath.section == 0 ? true : false,
                                             hasUnreadMessages: indexPath.row % 2 == 0 ? true : false)
        return cell
    }

}
