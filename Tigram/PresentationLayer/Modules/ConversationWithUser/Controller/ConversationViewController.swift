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
    var fetchedResultsController: NSFetchedResultsController<Message>!
    var frcDelegate: FetchedResultsControllerProtocol?
    // MARK: Messages Service for cells configuration
    var mcService: MessageCellsServiceProtocol!
    // MARK: Keyboard Service
    var keyboardService: KeyboardServiceProtocol!
    // MARK: Communicator Service
    var communicatorService: CommunicatorServiceProtocol!
    // MARK: CoreData Manager
    var coreDataManager: CoreDataManagerProtocol!
    // MARK: Theme Service
    var themeService: ThemeServiceProtocol!

    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendMessageButton: UIButton!
    var conversationName: String?
    var conversation: Conversation?
    var lastColorOfNavigationBar: UIColor?
    var headerLabel: HeaderLabel = HeaderLabel()

    // MARK: Life Cycle
    func reinit(mcService: MessageCellsServiceProtocol, keyboardService: KeyboardServiceProtocol, coreDataManager: CoreDataManagerProtocol, frcDelegate: FetchedResultsControllerProtocol, themeService: ThemeServiceProtocol) {
        self.mcService = mcService
        self.keyboardService = keyboardService
        self.coreDataManager = coreDataManager
        self.frcDelegate = frcDelegate
        self.themeService = themeService
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting send message button design
        let image = UIImage(named: "SendButton")?.withRenderingMode(.alwaysTemplate)
        sendMessageButton.setImage(image, for: .normal)
        sendMessageButton.isEnabled = false
        sendMessageButton.tintColor = themeService.getDefaultColor()

        // All additional setup after loading the view
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

        // Setting delegate instance
        frcDelegate?.reinit(tableView: self.tableView)
        // Setting delegate to FRController
        fetchedResultsController?.delegate = frcDelegate
        updateWithFetchedResultsController()
        // Creating MessageCellsService instance for configuring cells
        mcService.reinit(tableView: self.tableView)
        // Creating se
        keyboardService.reinit(view: self.view)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        if let conversation = conversation {
            changeSendButtonModeIfNeeded(to: conversation.isInterlocutorOnline && !isTextFieldIsEmpty())
            changeHeaderIfNeeded(to: conversation.isInterlocutorOnline)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnTableView))
        tableView.addGestureRecognizer(tapGesture)
        // Header label
        headerLabel.text = conversationName
        navigationItem.titleView = headerLabel
        // Scroll to the end of current conversation
        scrollToBottom()
        self.communicatorService.readAllNewMessages(with: conversation?.userId ?? "")
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
                    self?.changeSendButtonModeIfNeeded(to: false)
                } else {
                    let alertVC = UIAlertController(title: "ERROR", message: "Cannot send message", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alertVC, animated: true, completion: nil)
                }
            })
        }
    }

    @IBAction func messageTextFieldEditingChanged(_ sender: Any) {
        if let conversation = conversation {
            if conversation.isInterlocutorOnline && !sendMessageButton.isEnabled && !isTextFieldIsEmpty() {
                changeSendButtonModeIfNeeded(to: true)
            } else if !conversation.isInterlocutorOnline || isTextFieldIsEmpty() {
                changeSendButtonModeIfNeeded(to: false)
            }
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
    func isTextFieldIsEmpty() -> Bool {
        return messageTextField.text == nil || messageTextField.text == ""
    }

    // MARK: Animation
    func changeHeaderIfNeeded(to mode: Bool) {
        if headerLabel.isInterlocutorOnline != mode {
            headerLabel.isInterlocutorOnline = mode
        }
    }
    // Sets new value to sendMessageButton.isEnabled
    func changeSendButtonModeIfNeeded(to mode: Bool) {
        if sendMessageButton.isEnabled == mode {
            return
        }
        sendMessageButton.isEnabled = mode
        if mode {
            makeSendButtonAvailable()
        } else {
            makeSendButtonNotAvailable()
        }

        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.sendMessageButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.sendMessageButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        })
    }

    func makeSendButtonAvailable() {
        UIView.animate(withDuration: 0.5, animations: {
            self.sendMessageButton.tintColor = self.themeService.getCurrentColor()
        })
    }

    func makeSendButtonNotAvailable() {
        UIView.animate(withDuration: 0.5, animations: {
            self.sendMessageButton.tintColor = self.themeService.getDefaultColor()
        })
    }
}
extension ConversationViewController: ConversationDelegate {
    func didUserIsOnline(online: Bool) {
        changeSendButtonModeIfNeeded(to: online && !isTextFieldIsEmpty())
        changeHeaderIfNeeded(to: online)
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
