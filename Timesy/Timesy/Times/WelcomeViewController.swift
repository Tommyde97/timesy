//
//  WelcomeViewController.swift
//  Timesy
//
//  Created by Tommy De Andrade on 5/24/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet var holderView: UIView!
    
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }
    
    private func configure() {
        //set up scrollview
        
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        
        
        let titles = ["Welcome to Timesy", "Time it Right", "All set"]
        let subtitles = ["The Social Media app where you have control of your Times", "Show who you want to see which times", "You're all set to get started"]
        
        for x in 0..<3 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * holderView.frame.size.width, y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height))
            scrollView.addSubview(pageView)
                        
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width-10, height: 120))
            let subtitleLabel = UILabel(frame: CGRect(x: 10, y: label.frame.maxY + 10, width: pageView.frame.size.width-20, height: 60))
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10 + 120 + 10, width: pageView.frame.size.width-10, height: pageView.frame.size.height - 60 - 130 - 15))
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height-60, width: pageView.frame.size.width-20, height: 50))
            
            //Title
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica-Bold", size: 32)
            label.text = titles[x]
            pageView.addSubview(label)
            
            
            //Subtitle
            subtitleLabel.textAlignment = .center
            subtitleLabel.font = UIFont(name: "Helvetica", size: 16)
            subtitleLabel.textColor = .gray
            subtitleLabel.numberOfLines = 2
            subtitleLabel.text = subtitles[x]
            pageView.addSubview(subtitleLabel)
            
            //Images
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "Welcome-\(x+1)")
            pageView.addSubview(imageView)
            
            //Button
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.setTitle("Continue", for: .normal)
            if x == 2 {
                button.setTitle("Get Started", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton(_ :)), for: .touchUpInside)
            button.tag = x + 1
            pageView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: holderView.frame.size.width*3, height: 0)
        scrollView.isPagingEnabled = true
    }
   
    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 3 else {
            // Dismiss
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        // scroll to next page
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
    }
}

