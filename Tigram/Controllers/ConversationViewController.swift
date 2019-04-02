//
//  ConversationViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 24/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import CoreData

protocol ConversationDelegate: class {
    func didUserIsOnline(online: Bool)
}

class ConversationViewController: UIViewController {
    // MARK: NSFetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Message>?

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

        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.userId == %@", conversation?.userId ?? "emptyUserID")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]

        guard let context = CoreDataManager.instance.getContextWith(name: "save") else {
            fetchedResultsController = nil
            return
        }
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate

        updateWithFetchedResultsController()
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.title = conversationName
        // Scroll to the end of current conversation
        scrollToBottom()
    }
    // MARK: Actions
    @objc func didTapOnTableView() {
        messageTextField.resignFirstResponder()
    }
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if let messageText = messageTextField.text, messageTextField.text != "" {
            communicatorManager?.haveSendMessage(for: conversation?.userId ?? "Id", withText: messageText, completion: { [weak self] (result, _) in
                if result {
                    self?.messageTextField.text = ""
                    self?.messageTextField.resignFirstResponder()
                    self?.scrollToBottom()
                } else {
                    let alertVC = UIAlertController(title: "ERROR", message: "Cannot send message", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alertVC, animated: true, completion: nil)
                }
            })
        }
    }
    // MARK: Notifications
    @objc func keyboardWillShow(notification: NSNotification) {
        if !keyboardIsShowing {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.view.bounds.origin.y = keyboardRectangle.height
                keyboardIsShowing = true
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
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
                let indexPath = IndexPath(row: (self.conversation?.messages?.count)!-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    func updateWithFetchedResultsController() {
        do {
            try self.fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("ERROR: \(error.description)")
        }
    }
}

extension ConversationViewController: UITableViewDelegate {}
extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = conversation?.messages {
            return messages.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.fetchedResultsController?.object(at: indexPath)
        // Configure the cell with data from the managed object
        return configureCell(message: message!, for: indexPath)
    }
    // MARK: Creates a cell for each table view row
    private func configureCell(message: Message, for indexPath: IndexPath) -> UITableViewCell {
        if message.isIncoming {
            let cell = tableView.dequeueReusableCell(withIdentifier: incomingMessageID, for: indexPath) as? MessageTableViewCell ?? MessageTableViewCell()
            cell.configureMessage(withText: message.text ?? "")
            updateCellWithCurrentTheme(cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: sentMessageID, for: indexPath) as? MessageTableViewCell ?? MessageTableViewCell()
            cell.configureMessage(withText: message.text ?? "")
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
extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView.endUpdates()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .move:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                self.tableView.reloadRows(at: [indexPath!], with: .automatic)
            }
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        DispatchQueue.main.async {
            switch type {
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .move, .update:
                break
            }
        }
    }
}
extension ConversationViewController: ConversationDelegate {
    func didUserIsOnline(online: Bool) {
        self.sendMessageButton.isEnabled = online
        self.messageTextField.isUserInteractionEnabled = online
    }
}
