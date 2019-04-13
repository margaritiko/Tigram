//
//  ConversationsListViewController.swift
//  Tigram
//
//  Created by Маргарита Коннова on 23/02/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import UIKit
import CoreData

enum SectionList: Int {
    case onlineSection = 0
    case historySection
}

class ConversationsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    // MARK: Fields
    var communicationService: CommunicatorServiceProtocol!
    var themeService: ThemeServiceProtocol!
    var coreDataManager: CoreDataManagerProtocol!
    // Dependencies
    private var presentationAssembly: IPresentationAssembly!
    // NSFetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Conversation>!
    var frcDelegate: FetchedResultsControllerProtocol?

    // MARK: Life cycle
    func reinit(communicator: CommunicatorServiceProtocol, manager: CoreDataManagerProtocol, frcDelegate: FetchedResultsControllerProtocol, themeService: ThemeServiceProtocol, presentationAssembly: IPresentationAssembly) {
        // Sets communicationManager
        self.communicationService = communicator
        self.coreDataManager = manager
        self.frcDelegate = frcDelegate
        self.themeService = themeService
        self.presentationAssembly = presentationAssembly
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.tableView.dataSource = self
        self.tableView.delegate = self
        setUpNavigationBar()
        // Makes fetch request
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        // Sorts all conversations in this way:
        // If both do not have a date, sorting is done by name
        // If only one has a date, the one who has the date is above
        // If both have date - sort by date
        request.sortDescriptors = [
            NSSortDescriptor(key: "isInterlocutorOnline", ascending: false),
            NSSortDescriptor(key: "lastMessage.date", ascending: false),
            NSSortDescriptor(key: "conversationName", ascending: true)
        ]
        guard let context = coreDataManager.getSaveContext() else {
            return
        }
        request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request,
                                                                            managedObjectContext: context,
                                                                            sectionNameKeyPath:
                                                                            #keyPath(Conversation.isInterlocutorOnline),
                                                                            cacheName: nil)

        self.frcDelegate?.reinit(tableView: tableView)
        fetchedResultsController?.delegate = self.frcDelegate

        updateWithFetchedResultsController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        themeService.setTheme(themeName: themeName ?? "light", navigationController: navigationController)
        self.view.backgroundColor = themeService.getColorForName(themeName ?? "light")
        tableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Open Chat" {
            let cell = sender as? ChatWindowTableViewCell
            let conversationViewController = segue.destination as? ConversationViewController
            conversationViewController?.title = cell?.name
        } else if segue.identifier == "Open Themes" {
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

    func updateWithFetchedResultsController() {
        do {
            try self.fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("ERROR: \(error.description)")
        }
    }
    // MARK: Actions
    @IBAction func themesButtonClicked(_ sender: Any) {
        if let nextViewController = presentationAssembly.themesViewController() {
            // Presents Modally
            present(nextViewController, animated: true, completion: nil)
        }
    }
    @IBAction func profileButtonClicked(_ sender: Any) {
        if let nextViewController = presentationAssembly.profileViewController() {
            // Presents Modally
            present(nextViewController, animated: true, completion: nil)
        }
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
        if let nextViewController = presentationAssembly.conversationViewController() {
            // Sets all data to new view controller
            nextViewController.conversation = cell.conversation
            nextViewController.conversation?.hasUnreadMessages = false
            nextViewController.conversationName = cell.nameLabel.text
            nextViewController.communicatorService = self.communicationService
            nextViewController.communicatorService?.conversationDelegate = nextViewController
            // Pushes new view controller into stack
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else {
            return nil
        }
        return sections[section].indexTitle == "1" ? "Online" : "History"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            assert(false, "No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chat Window") as? ChatWindowTableViewCell ?? ChatWindowTableViewCell()
        let conversation = self.fetchedResultsController?.object(at: indexPath)
        return configureCell(cell: cell, model: conversation ?? Conversation())
    }

    // There are maximum two sections: Online and History
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections.count
        }
        return 0
    }

    // MARK: Configuration of new cell
    private func configureCell(cell: ChatWindowTableViewCell, model: Conversation) -> UITableViewCell {
        coreDataManager.getSaveContext()?.performAndWait {
            cell.nameLabel.text = model.conversationName
            cell.dateLabel.text = "\(Date.convertDateIntoString(date: model.lastMessage?.date as Date?))"
            cell.conversation = model
            cell.online = model.isInterlocutorOnline
            if let lastMessage = model.lastMessage, (model.messages?.count)! > 0 {
                if model.hasUnreadMessages {
                    cell.messageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
                } else {
                    cell.messageLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
                }
                cell.messageLabel.text = lastMessage.text
            } else {
                cell.messageLabel.text = "No messages yet"
                cell.messageLabel.font = UIFont(name: "Noteworthy", size: 14.0)
            }
            // Another color for online conversations
            cell.configureCellWithCurrentThemes(color: UserDefaults.standard.string(forKey: "Theme") ?? "light")
        }
        return cell
    }
}

extension Date {
    static func convertDateIntoString(date: Date?) -> String {
        let dateFormatter = DateFormatter()
        // Sets format
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = date else {
            return "--:--"
        }
        let today = dateFormatter.string(from: Date())
        let messageDate = dateFormatter.string(from: date)
        // Checks if we should change date format
        if today == messageDate {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd MMM"
        }
        let resultDateString = dateFormatter.string(from: date)
        return resultDateString
    }
}
