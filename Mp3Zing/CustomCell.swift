//
//  CustomCell.swift
//  Mp3Zing
//
//  Created by Le Ha Thanh on 9/23/16.
//  Copyright © 2016 le ha thanh. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var imageSong: UIImageView!
    @IBOutlet weak var nameSong: UILabel!
    @IBOutlet weak var artistSong: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var constrainLabel: NSLayoutConstraint!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
