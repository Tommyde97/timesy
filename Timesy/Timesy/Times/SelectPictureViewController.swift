//
//  SelectPictureViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 3/14/23.
//

import UIKit
import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class SelectPictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var imagePicker : UIImagePickerController?
    var imageAdded = false
    var imageName = "\(NSUUID().uuidString).jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
    }
    
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        if imagePicker != nil {
            imagePicker!.sourceType = .photoLibrary
            present(imagePicker!, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        if imagePicker != nil {
            imagePicker!.sourceType = .camera
            present(imagePicker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue) ] as? UIImage {
            imageView.image = image
            imageAdded = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        
            // DELETE THIS FOR PRODUCTION
            messageTextField.text = "test"
            imageAdded = true
            
            if let message = messageTextField.text {
                if imageAdded && message != "" {
                    // Upload the image
                    
                    let imagesFolder = Storage.storage().reference().child("images")
                    
                    if let image = imageView.image {
                        if let imageData = image.jpegData(compressionQuality: 0.1) {
                            let uploadTask = imagesFolder.child(imageName).putData(imageData, metadata: nil)
                            
                            uploadTask.observe(.success) { snapshot in
                                // Upload completed successfully
                                imagesFolder.child(self.imageName).downloadURL { (url, error) in
                                    if let downloadURL = url?.absoluteString {
                                        self.performSegue(withIdentifier: "selectReceiverSegue", sender: downloadURL)
                                    }
                                }
                            }
                            
                            uploadTask.observe(.failure) { snapshot in
                                if let error = snapshot.error {
                                    self.presentAlert(alert: error.localizedDescription)
                                }
                            }
                        }
                    }
                } else {
                    // We are missing something
                    presentAlert(alert: "You must provide an image and a message for your time.")
                }
            }
        }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let downloadURL = sender as? String {
                if let selectVC = segue.destination as? SelectRecipientTableViewController {
                    selectVC.downloadURL = downloadURL
                    selectVC.timeDescription = messageTextField.text!
                    selectVC.imageName = imageName
                }
            }
        }
        
        func presentAlert(alert: String) {
            let alertVC = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
