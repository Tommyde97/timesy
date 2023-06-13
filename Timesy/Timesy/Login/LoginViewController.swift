//
//  LoginViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 12/13/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!

    var signupMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameTextField.isHidden = true
    }

    @IBAction func topTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if signupMode {
                // Sign Up
                guard let username = sanitizeUsername(usernameTextField.text) else {
                    presentAlert(alert: "Invalid username. Please choose a different username.")
                    return
                }

                // Check username availability
                checkUsernameAvailability(username: username) { [weak self] isAvailable in
                    if isAvailable {
                        // Username is available, proceed with sign up
                        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                            if let error = error {
                                self?.presentAlert(alert: error.localizedDescription)
                            } else {
                                if let user = user {
                                    let uid = user.user.uid

                                    // Save the user's email to the database
                                    let usersRef = Database.database().reference().child("users")
                                    let userRef = usersRef.child(uid)
                                    userRef.child("email").setValue(email)

                                    // Save the user's username to the database
                                    self?.saveUsernameAvailability(username: username)
                                    userRef.child("username").setValue(username)

                                    // Save the user details in UserDefaults
                                    self?.saveUserDetails(uid: uid, email: email, username: username)

                                    self?.navigateToMainAppScreen()
                                }
                            }
                        }
                    } else {
                        // Username is not available, present an alert
                        self?.presentAlert(alert: "Username is already taken. Please choose a different username.")
                    }
                }
            } else {
                // Log In
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
                    if let error = error {
                        self?.presentAlert(alert: error.localizedDescription)
                    } else {
                        // Retrieve the user's username from the database if needed
                        var username = ""
                        if self?.usernameTextField.isHidden == false {
                            username = self?.sanitizeUsername(self?.usernameTextField.text) ?? ""
                        }
                        
                        // Check username availability if a username is entered
                        if !username.isEmpty {
                            self?.checkUsernameAvailability(username: username) { isAvailable in
                                if isAvailable {
                                    // Username is available or not required, proceed with login
                                    // Save the user details in UserDefaults
                                    self?.saveUserDetails(uid: user?.user.uid, email: email, username: username)

                                    self?.navigateToMainAppScreen()
                                } else {
                                    // Username is not available, present an alert
                                    self?.presentAlert(alert: "Username is not available.")
                                }
                            }
                        } else {
                            // No username entered, proceed with login
                            self?.saveUserDetails(uid: user?.user.uid, email: email, username: username)
                            self?.navigateToMainAppScreen()
                        }
                    }
                }
            }
        }
    }

    func sanitizeUsername(_ username: String?) -> String? {
        guard let username = username else { return nil }
        // Remove any invalid characters from the username
        let allowedCharacterSet = CharacterSet.alphanumerics
        let sanitizedUsername = username.components(separatedBy: allowedCharacterSet.inverted).joined()
        return sanitizedUsername
    }


    func presentAlert(alert: String) {
        let alertVC = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }

    @IBAction func bottomTapped(_ sender: Any) {
        if signupMode {
            // Switch to Log In
            signupMode = false
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            usernameTextField.isHidden = true
        } else {
            // Switch to Sign Up
            signupMode = true
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            usernameTextField.isHidden = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            // Show Onboarding
            let vc = storyboard?.instantiateViewController(withIdentifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    func saveUserDetails(uid: String?, email: String, username: String) {
        // Save the user details in UserDefaults or any other storage mechanism
        // ...
    }

    func navigateToMainAppScreen() {
        // Navigate to the main app screen or perform any other actions
        // ...
    }

    func checkUsernameAvailability(username: String, completion: @escaping (Bool) -> Void) {
        let usernamesRef = Database.database().reference().child("usernames")
        let usernameRef = usernamesRef.child(username)

        // Observe the value of the username reference
        usernameRef.observeSingleEvent(of: .value) { snapshot in
            // If the snapshot exists, the username is not available
            let isAvailable = !snapshot.exists()
            completion(isAvailable)
        }
    }
    
    func saveUsernameAvailability(username: String) {
        let usernamesRef = Database.database().reference().child("usernames")
        let usernameRef = usernamesRef.child(username)
        
        // Set the value of the username reference to true to indicate availability
        usernameRef.setValue(true)
    }
}

class Core {

    static let shared = Core()

    func isNewUser() -> Bool  {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }

    ///
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
