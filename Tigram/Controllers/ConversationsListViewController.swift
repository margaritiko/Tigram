//
//  ConversationsListViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 23/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

enum SectionList: Int {
    case onlineSection = 0
    case historySection
}

class ConversationsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var communicationManager: CommunicationManager?
    
    // Lists with conversations
    var allConversations: [[Conversation]] = []
    var onlineConversations: [Conversation] = []
    var historyConversations: [Conversation] = []
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setUpNavigationBar()
        
        // Inits communicationManager
        communicationManager = CommunicationManager()
        communicationManager?.viewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        ThemeManager().setTheme(themeName: themeName ?? "light", navigationController: navigationController)
        self.view.backgroundColor = ThemeManager().getColorForName(themeName ?? "light")
        
        tableView.reloadData()
    }
    
    // MARK: Other functions
    
    // Sorts all conversations in this way:
    // If both do not have a date, sorting is done by name
    // If only one has a date, the one who has the date is above
    // If both have date - sort by date
    func sortConversations( listToSort: inout [Conversation]) {
        listToSort.sort(by: {
            if ($0.allMessagesFromCurrentConversation?.count)! == 0 && ($1.allMessagesFromCurrentConversation?.count)! == 0 {
                // By name
                return $0.conversationName ?? "" < $1.conversationName ?? ""
            }
            if ($0.allMessagesFromCurrentConversation?.count)! == 0 {
                return false
            }
            if ($1.allMessagesFromCurrentConversation?.count)! == 0 {
                return true
            }
            // By date
            if $0.dateOfLastMessage?.compare($1.dateOfLastMessage!) == ComparisonResult.orderedAscending {
                return true
            }
            return false
        })
    }
    
    // Deletes all data from lists with conversations
    private func clearAllConversations() {
        allConversations.removeAll()
        onlineConversations.removeAll()
        historyConversations.removeAll()
    }
    
    func setTableViewWith(data: [Conversation]) {
        clearAllConversations()
        
        for conversation in data {
            // Distributes the dialogs into sections
            if conversation.isInterlocutorOnline == true {
                onlineConversations.append(conversation)
            } else {
                historyConversations.append(conversation)
            }
        }
        
        // Sorts sections
        sortConversations(listToSort: &onlineConversations)
        sortConversations(listToSort: &historyConversations)
        
        // Adds conversations from sections to list with all conversations
        allConversations.append(onlineConversations)
        allConversations.append(historyConversations)
        
        // Reloads table view with new data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Open Chat") {
            let cell = sender as? ChatWindowTableViewCell
            let conversationViewController = segue.destination as? ConversationViewController
            conversationViewController?.title = cell?.name
        }
        else if (segue.identifier == "Open Themes") {
            let themesViewController = segue.destination as? ThemesViewController
            themesViewController?.delegate = self
            themesViewController?.closureForSettingNewTheme = {(color, viewController) in
                if let colorForChosenTheme = color {
                    self.logThemeChanging(selectedTheme: colorForChosenTheme)
                    UINavigationBar.appearance().backgroundColor = colorForChosenTheme
                    self.view.backgroundColor = colorForChosenTheme
                    viewController?.view.backgroundColor = colorForChosenTheme
                }
            }
        }
    }

    func setUpNavigationBar() {
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func logThemeChanging(selectedTheme: UIColor) {
        print("COLOR: \(selectedTheme)")
    }
}


extension ConversationsListViewController: ThemesViewControllerDelegate {
    func themesViewController(_ controller: ThemesViewController!, didSelectTheme selectedTheme: UIColor!) {
        self.logThemeChanging(selectedTheme: selectedTheme)
        UINavigationBar.appearance().backgroundColor = selectedTheme
        self.view.backgroundColor = selectedTheme
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    // Opens conversations after click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatWindowTableViewCell else {
            return
        }
        
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ConversationViewController") as! ConversationViewController
        
        // Sets all data to new view controller
        nextViewController.conversation = cell.conversation
        nextViewController.conversation?.hasUnreadMessages = false
        nextViewController.conversationName = cell.nameLabel.text
        
        nextViewController.communicatorManager = self.communicationManager
        nextViewController.communicatorManager?.conversationDelegate = nextViewController
        
        // Pushes new view controller into stack
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == SectionList.onlineSection.rawValue {
            return "Online"
        } else if section == SectionList.historySection.rawValue {
            return "History"
        }
        return nil
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allConversations[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentConversation = allConversations[indexPath.section][indexPath.row]
        return configureCell(tableView: tableView, model: currentConversation)
    }
    
    // There are only two sections: Online and History
    func numberOfSections(in tableView: UITableView) -> Int {
        return allConversations.count
    }
    
    // MARK: Configuration of new cell
    private func configureCell(tableView: UITableView, model: Conversation) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chat Window") as! ChatWindowTableViewCell
        cell.nameLabel.text = model.conversationName
        cell.dateLabel.text = "\(Date.convertDateIntoString(date: model.allMessagesFromCurrentConversation?.last?.date))"
        cell.conversation = model
        cell.online = model.isInterlocutorOnline
        
        if let messages = model.allMessagesFromCurrentConversation, (model.allMessagesFromCurrentConversation?.count)! > 0 {
            
            if (model.hasUnreadMessages) {
                cell.messageLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
            }
            else {
                cell.messageLabel.font = UIFont(name:"HelveticaNeue", size: 14.0)
            }
            
            cell.messageLabel.text = messages.last?.messageText
        } else {
            cell.messageLabel.text = "No messages yet"
            cell.messageLabel.font = UIFont(name: "Noteworthy", size: 14.0)
        }
        
        // Another color for online conversations
        cell.configureCellWithCurrentThemes(color: UserDefaults.standard.string(forKey: "Theme") ?? "light")
        return cell
    }
}

extension ConversationsListViewController: CommunicationManagerProtocol {
    func didUpdateConversations(conversations: [Conversation]) {
        setTableViewWith(data: conversations)
    }
}
extension Date {
    static func convertDateIntoString(date: Date?) -> String {
    
        let dateFormatter = DateFormatter()
        // Sets format
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let _date = date else {
            return "--:--"
        }
        
        let today = dateFormatter.string(from: Date())
        let messageDate = dateFormatter.string(from: _date)
        
        // Checks if we should change date format
        if today == messageDate {
            dateFormatter.dateFormat = "HH:mm"
        }
        else {
            dateFormatter.dateFormat = "dd MMM"
        }
        
        let resultDateString = dateFormatter.string(from: _date)
        return resultDateString
    }
}
