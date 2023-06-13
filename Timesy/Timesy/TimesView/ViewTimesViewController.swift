//
//  ViewTimesViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 5/8/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class ViewTimesViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageName = ""
    var time : DataSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
           if let timeDictionary = time?.value as? NSDictionary {
               if let description = timeDictionary["description"] as? String {
                   if let imageURL = timeDictionary["imageURL"] as? String {
                       messageLabel.text = description
    
                       if let url = URL(string: imageURL) {
                           
                           imageView.sd_setImage(with: url)
                       }
                       
                       if let imageName = timeDictionary["imageName"] as? String {
                           self.imageName = imageName
                       }
                   }
               }
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let currentUserUid = Auth.auth().currentUser?.uid {
            
            if let key = time?.key {
                
                Database.database().reference().child("users").child(currentUserUid).child("times").child(key).removeValue()
                
                Storage.storage().reference().child("images").child(imageName).delete(completion: nil)
            }
        }
    }
}
