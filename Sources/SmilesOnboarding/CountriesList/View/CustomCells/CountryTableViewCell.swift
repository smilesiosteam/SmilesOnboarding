//
//  CountryTableViewCell.swift
//  
//
//  Created by Shahroze Zaheer on 01/07/2023.
//

import UIKit

public class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var countryimage: UIImageView! {
        didSet {
            countryimage.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryCode: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
