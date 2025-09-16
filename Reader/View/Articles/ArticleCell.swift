//
//  ArticleCell.swift
//  Reader
//
//  Created by Debashish on 16/09/25.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsIcon: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
