//
//  LocalArticleCell.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-31.
//

import UIKit

class LocalArticleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var article: Article? {
        didSet {
            guard let article = self.article else {
                return
            }
            
            titleLabel.text = article.title
            contentLabel.text = article.content
        }
    }
}
