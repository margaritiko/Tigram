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
    var communicationManager: CommunicationManager?
    // MARK: NSFetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Conversation>?
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        setUpNavigationBar()
        // Inits communicationManager
        communicationManager = CommunicationManager()
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
        guard let context = CoreDataManager.instance.getContextWith(name: "save") else {
            return
        }
        // TODO: Batching
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: request,
                                                                            managedObjectContext: context,
                                                                            sectionNameKeyPath:
                                                                            #keyPath(Conversation.isInterlocutorOnline),
                                                                            cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate

        updateWithFetchedResultsController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let themeName = UserDefaults.standard.string(forKey: "Theme")
        ThemeManager().setTheme(themeName: themeName ?? "light", navigationController: navigationController)
        self.view.backgroundColor = ThemeManager().getColorForName(themeName ?? "light")
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
}
extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
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
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ConversationViewController") as? ConversationViewController {
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
