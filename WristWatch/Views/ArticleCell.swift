//
//  ArticleCell.swift
//  WristWatch
//
//  Created by Marcio Duarte on 2021-03-31.
//

import UIKit
import Kingfisher

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        
        return formatter
    }
    
    var article: Article? {
        didSet {
            guard let article = self.article else {
                return
            }
            
            if let urlToImage = article.urlToImage,
               let url = URL(string: urlToImage) {
                articleImageView.kf.setImage(with: url)
            } else {
                articleImageView.image = nil
            }
            
            titleLabel.text = article.title
            authorLabel.text = article.author
            
            if let publishedAt = article.publishedAt {
                dateLabel.text = dateFormatter.string(from: publishedAt)
            } else {
                dateLabel.text = ""
            }
        }
    }
}
