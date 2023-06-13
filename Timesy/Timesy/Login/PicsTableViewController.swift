//
//  PicsTableViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 2/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PicsTableViewController: UITableViewController {
    
    var times : [DataSnapshot] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUserUid = Auth.auth().currentUser?.uid {
            
            Database.database().reference().child("users").child(currentUserUid).child("times").observe(.childAdded, with: { (snapshot) in
                self.times.append(snapshot)
                self.tableView.reloadData()
                
                Database.database().reference().child("users").child(currentUserUid).child("times").observe(.childRemoved, with: { (snapshhot) in
                    
                    var index = 0
                    for time in self.times {
                        if snapshot.key == time.key {
                            self.times.remove(at: index)
                        }
                        index += 1
                    }
                    self.tableView.reloadData()
                })
            })
        }
    }

    @IBAction func logOutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if times.count == 0 {
            return 1
        } else {
            return times.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if times.count == 0 {
            cell.textLabel?.text = "No Times to show 🤔"
        } else {
            let time = times[indexPath.row]
            
            if let timeDictionary = time.value as? NSDictionary {
                if let fromEmail = timeDictionary["from"] as? String {
                    cell.textLabel?.text = fromEmail
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let time = times[indexPath.row]
        
        performSegue(withIdentifier: "viewTimeSegue", sender: time)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewTimeSegue" {
            if let viewVC = segue.destination as? ViewTimesViewController {
               
                if let time = sender as? DataSnapshot {
                    viewVC.time = time
                }
            }
        }
    }
}
