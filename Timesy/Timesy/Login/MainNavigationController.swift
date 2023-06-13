//
//  MainNavigationController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 6/1/23.
//

import UIKit
import FirebaseAuth

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in. Show home screen
                let picsTableViewC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! PicsTableViewController
                let navigationController = UINavigationController(rootViewController: picsTableViewC)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: false, completion: nil)
            } else {
                // No User is signed in. Show user the login screen
                let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: "welcome") as! WelcomeViewController
                let navigationController = UINavigationController(rootViewController: welcomeVC)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: false, completion: nil)
            }
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
