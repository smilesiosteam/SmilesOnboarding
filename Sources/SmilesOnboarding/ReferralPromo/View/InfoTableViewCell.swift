//
//  InfoTableViewCell.swift
//  
//
//  Created by Shmeel Ahmed on 19/06/2023.
//

import UIKit
import SmilesLanguageManager
class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        semanticContentAttribute = SmilesLanguageManager.shared.currentLanguage == .ar ? .forceRightToLeft : .forceLeftToRight
        // Configure the view for the selected state
    }

}
