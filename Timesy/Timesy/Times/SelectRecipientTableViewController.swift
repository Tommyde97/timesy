//
//  SelectRecipientTableViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 3/16/23.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class SelectRecipientTableViewController: UITableViewController {
    
    var timeDescription = ""
    var downloadURL = ""
    var imageName = ""
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
    }
    
    // Fetch users from Firebase Realtime Database
    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let userDictionary = snapshot.value as? [String: Any],
               let email = userDictionary["email"] as? String,
               let uid = snapshot.key as? String {
                
                let user = User(email: email, uid: uid)
                self.users.append(user)
                self.fetchUsername(for: user)
                self.tableView.reloadData()
            }
        }
    }
    
    // Fetch username for each user
    func fetchUsername(for user: User) {
        Database.database().reference().child("users").child(user.uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let username = snapshot.value as? String {
                user.username = username
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let user = users[indexPath.row]
        
        if let username = user.username {
            cell.textLabel?.text = username
        } else {
            cell.textLabel?.text = user.email
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            fetchSenderUsername(for: currentUserID) { fromUsername in
                if let fromUsername = fromUsername {
                    let time = ["from": fromUsername, "description": self.timeDescription, "imageURL": self.downloadURL, "imageName": self.imageName]
                    
                    Database.database().reference().child("users").child(user.uid).child("times").childByAutoId().setValue(time)
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    class User {
        var email: String
        var uid: String
        var username: String?
        
        init(email: String, uid: String) {
            self.email = email
            self.uid = uid
        }
    }
    
    // Fetch sender's username from Firebase Realtime Database
    func fetchSenderUsername(for userID: String, completion: @escaping (String?) -> Void) {
        Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let userDictionary = snapshot.value as? [String: Any],
               let username = userDictionary["username"] as? String {
                completion(username)
            } else {
                completion(nil)
            }
        }
    }
}
