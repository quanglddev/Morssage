//
//  ViewController.swift
//  Morssage
//
//  Created by QUANG on 6/17/17.
//  Copyright © 2017 Superior Future. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class MainVC: UIViewController {
    
    
    // MARK: Properties
    var ref: DatabaseReference!
    var messages: [DataSnapshot]! = []
    var msglength: NSNumber = 150
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    
    // MARK: Outlets
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var signOutButton: UIButton!

    override func viewDidLoad() {
        configureAuth()
    }
    
    // MARK: Config
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        // TODO: configure firebase authentication
        //Listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            //Refresh table data
            self.messages.removeAll(keepingCapacity: false)
            self.messagesTable.reloadData()
            
            //Check if there is a current user
            if let activeUser = user {
                //Check if current app user is current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                }
            }
            else {
                //User must sign in
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        })
    }
    
    deinit {
        ref.child("messages").removeObserver(withHandle: _refHandle)
        Auth.auth().removeStateDidChangeListener(_authHandle)
        // TODO: set up what needs to be deinitialized when view is no longer being used
    }
    
    // MARK: Sign In and Out
    
    func signedInStatus(isSignedIn: Bool) {
        signOutButton.isHidden = !isSignedIn
        messagesTable.isHidden = !isSignedIn
        
        if (isSignedIn) {
            // remove background blur (will use when showing image messages)
            messagesTable.rowHeight = UITableViewAutomaticDimension
            messagesTable.estimatedRowHeight = 122.0
        }
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: Send Message
    
    func sendMessage(data: [String:String]) {
        // TODO: create method that pushes message to the firebase database
        var mData = data
        mData[Constants.MessageFields.name] = displayName
        ref.child("messages").childByAutoId().setValue(mData)
    }
    
    // MARK: Scroll Messages
    
    func scrollToBottomMessage() {
        if messages.count == 0 { return }
        let bottomMessageIndex = IndexPath(row: messagesTable.numberOfRows(inSection: 0) - 1, section: 0)
        messagesTable.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func showLoginView(_ sender: AnyObject) {
        loginSession()
    }

    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
}

// MARK: - MainVC: UITableViewDelegate, UITableViewDataSource

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeue cell
        let cell = messagesTable.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MainCell
        
        //unpack message from the firebase data snapshot
        let messageSnapshot: DataSnapshot! = messages[indexPath.row]
        let message = messageSnapshot.value as! [String: String]
        let name = message[Constants.MessageFields.name] ?? "[username]"
        let text = message[Constants.MessageFields.text] ?? "[message]"
        
        cell.lblName.text = name
        cell.lblText.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
