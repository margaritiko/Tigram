//
//  MultipeerCommunicator.swift
//  Tigram
//
//  Created by Маргарита Коннова on 17/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler:((_ success: Bool, _ error: Error?) -> Void)?)
    var delegate: CommunicatorDelegate? {get set}
    var isOnline: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {
    weak var delegate: CommunicatorDelegate?

    private let serviceType = "tinkoff-chat"
    private let discoveryInfo = ["userName": "Margarita Konnova"]

    // To make the device visible to others
    private let advertiser: MCNearbyServiceAdvertiser
    // To search for devices
    private let browser: MCNearbyServiceBrowser

    private let myPeerId: MCPeerID = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)

    var isOnline: Bool
    var allSessions: [String: MCSession] = [String: MCSession]()

    lazy var session: MCSession = {
        let session = MCSession(peer: myPeerId)
        session.delegate = self
        return session
    }()
    init(delegate: CommunicatorDelegate) {
        // Init advertiser and browser with data
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: discoveryInfo, serviceType: serviceType)
        self.browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        self.isOnline = true
        // Calls super.init() to init all NSObject components
        super.init()
        self.delegate = delegate
        self.browser.delegate = self
        self.advertiser.delegate = self
        // Starts advertiser and browser
        self.advertiser.startAdvertisingPeer()
        self.browser.startBrowsingForPeers()
    }
    deinit {
        // Stops advertiser and browser
        self.advertiser.stopAdvertisingPeer()
        self.browser.stopBrowsingForPeers()
    }
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> Void)?) {
        let message = ["eventType": "TextMessage",
                       "messageId": String.generateMessageId(),
                       "text": string]
        do {
            let messageData = try JSONSerialization.data(withJSONObject: message, options: [])
            if let session = self.allSessions[userID] {
                try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            completionHandler?(false, error)
        }
        completionHandler?(true, nil)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            if let receivedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                delegate?.didReceiveMessage(text: receivedData["text"] as? String ?? "text", fromUser: peerID.displayName, toUser: myPeerId.displayName)
            }
        } catch {
            print("ERROR: can't receive data")
        }
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        var session = self.allSessions[peerID.displayName]
        if session?.connectedPeers.contains(peerID) ?? false {
            invitationHandler(false, nil)
        } else {
            if session == nil {
                // Creates new session
                session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
                session!.delegate = self
                // Sets new session to peer
                self.allSessions[peerID.displayName] = session
            }
            invitationHandler(true, session)
        }
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard peerID.displayName != myPeerId.displayName, let userInfo = info, let userName = userInfo["userName"]  else {
            return
        }
        var session = self.allSessions[peerID.displayName]
        if session == nil {
            // Creates new session
            session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
            session!.delegate = self
            // Sets new session to peer
            self.allSessions[peerID.displayName] = session
        }
        browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 60)
        // Now we found user
        self.delegate?.didFoundUser(userID: peerID.displayName, userName: userName)
    }
}

extension String {
    static func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))"
            .data(using: .utf8)?.base64EncodedString()
        return string!
    }
}
