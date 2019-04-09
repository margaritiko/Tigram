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
    var frcDelegate: NSFetchedResultsControllerDelegate!
    // MARK: Messages Service for cells configuration
    var mcService: MessageCellsServiceProtocol!
    // MARK: Keyboard Service
    var keyboardService: KeyboardServiceProtocol!
    // MARK: Communicator Service
    var communicatorService: CommunicatorServiceProtocol!
    // MARK: CoreData Manager
    var coreDataManager: CoreDataManagerProtocol!

    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendMessageButton: UIButton!

    // MARK: Other fields
    var conversationName: String?
    var conversation: Conversation?
    var lastColorOfNavigationBar: UIColor?

    // MARK: Life Cycle
    func reinit(communicator: CommunicatorServiceProtocol, mcService: MessageCellsServiceProtocol, keyboardService: KeyboardServiceProtocol, coreDataManager: CoreDataManagerProtocol, frcDelegate: NSFetchedResultsControllerDelegate) {
        self.communicatorService = communicator
        self.mcService = mcService
        self.keyboardService = keyboardService
        self.coreDataManager = coreDataManager
        self.frcDelegate = frcDelegate
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Getting all messages for current conversation
        let request: NSFetchRequest<Message> = Message.fetchRequestForConversationWith(userId: conversation?.userId ?? "emptyUserID")
        // Sorting messages by data (true order)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.fetchBatchSize = 20
        guard let context = coreDataManager.getSaveContext() else {
            fetchedResultsController = nil
            return
        }
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        // reinit
        frcDelegate.reinit(tableView: tableView)
        mcService.reinit(tableView: tableView)
        keyboardService.reinit(view: self.view)
        // Setting delegate to FRController
        fetchedResultsController?.delegate = frcDelegate
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
        self.title = conversationName
        // Scroll to the end of current conversation
        scrollToBottom()
        communicatorService?.readAllNewMessages(with: conversation?.userId ?? "")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardService.beginObservingKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardService.endObservingKeyboard()
    }

    // MARK: Actions
    @objc func didTapOnTableView() {
        messageTextField.resignFirstResponder()
    }
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if let messageText = messageTextField.text, messageTextField.text != "" {
            communicatorService?.haveSendMessage(for: conversation?.userId ?? "Id", withText: messageText, completion: { [weak self] (result, _) in
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
extension ConversationViewController: ConversationDelegate {
    func didUserIsOnline(online: Bool) {
        self.sendMessageButton.isEnabled = online
        self.messageTextField.isUserInteractionEnabled = online
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
        return mcService.configure(cellWithMessage: message, at: indexPath)
    }
}