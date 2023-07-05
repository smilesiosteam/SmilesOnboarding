//
//  PromptViewController.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import UIKit

class PromptViewController: UIViewController {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okayButton: UIButton!
    
    var titleString: String?
    var messageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageLabel.text = messageString
        titleLabel.text = titleString
    }

    @IBAction func okayTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
    }
    
}
