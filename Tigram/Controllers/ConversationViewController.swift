//
//  ConversationViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 24/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit

protocol ConversationDelegate {
    func didUserIsOnline(online: Bool)
    func didGetMessages(messages: [Message]?)
}

class ConversationViewController: UIViewController {
    let incomingMessageID = "Incoming Message"
    let sentMessageID = "Sent Message"
    
    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendMessageButton: UIButton!
    
    var keyboardIsShowing: Bool = false
    var conversationName: String?
    var conversation: Conversation?
    var communicatorManager: CommunicationManager?
    
    var lastColorOfNavigationBar: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        if let conversation = conversation {
            sendMessageButton.isEnabled = conversation.isInterlocutorOnline
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnTableView))
        tableView.addGestureRecognizer(tapGesture)
        
        // Adding events to pick up view when the keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.title = conversationName
        // Scroll to the end of current conversation
        if let _ = conversation?.allMessagesFromCurrentConversation {
            scrollToBottom()
        }
    }
    
    // MARK: Actions
    @objc func didTapOnTableView() {
        messageTextField.resignFirstResponder()
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if messageTextField.text != "" && messageTextField.text != nil {
            
            let message = Message(text: messageTextField.text, isIncoming: false)
            conversation?.allMessagesFromCurrentConversation?.append(message)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            communicatorManager?.communicator?.sendMessage(string: messageTextField.text!, to: (conversation?.userId)!) {
                (success, error) in
                
                if let error = error {
                    print(error)
                }
            }
            
            messageTextField.text = ""
        }
        scrollToBottom()
        messageTextField.resignFirstResponder()
    }
    
    // MARK: Notifications
    @objc func keyboardWillShow(notification:NSNotification) {
        if !keyboardIsShowing {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.view.bounds.origin.y = keyboardRectangle.height
                keyboardIsShowing = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        if keyboardIsShowing {
            self.view.bounds.origin.y = 0
            keyboardIsShowing = false
        }
    }
    
    // MARK: Other functions
    func scrollToBottom() {
        DispatchQueue.main.async {
            let rowsCount = self.tableView.numberOfRows(inSection: 0)
            if rowsCount > 0 {
                let indexPath = IndexPath(row: (self.conversation?.allMessagesFromCurrentConversation?.count)!-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
}


extension ConversationViewController: UITableViewDelegate {
    
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = conversation?.allMessagesFromCurrentConversation {
            return messages.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let messages = conversation?.allMessagesFromCurrentConversation {
            return configureCell(tableView: tableView, message: messages[indexPath.row])
        }
        return UITableViewCell()
    }
    
    // MARK: Creates a cell for each table view row
    private func configureCell(tableView: UITableView, message: Message) -> UITableViewCell {
        if message.isIncoming {
            let cell = tableView.dequeueReusableCell(withIdentifier: incomingMessageID) as! MessageTableViewCell
            cell.configureMessage(withText: message.messageText ?? "")
            updateCellWithCurrentTheme(cell)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: sentMessageID) as! MessageTableViewCell
            cell.configureMessage(withText: message.messageText ?? "")
            return cell
        }
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

extension ConversationViewController: ConversationDelegate {
    func didUserIsOnline(online: Bool) {
        self.sendMessageButton.isEnabled = online
        self.messageTextField.isUserInteractionEnabled = online
    }
    
    func didGetMessages(messages: [Message]?) {
        conversation?.allMessagesFromCurrentConversation = messages
        // Updates table view with new messages
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
