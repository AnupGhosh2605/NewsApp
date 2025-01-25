//
//  NewsListTableViewCell.swift
//  NewsApp
//
//  Created by Anup Ghosh on 24/01/25.
//

import UIKit

class NewsListTableViewCell: UITableViewCell,NewsCellProtocol {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var authorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Configure the cell
    func configure(with article: Article) {
        title.text = article.title?.capitalized
        newsDescription.text = article.description
        
        if let authorName = article.author {
            author.text = authorName.uppercased()
        }
        else {
            authorView.isHidden = true
        }
    }
    
    // Load the image to display in the cell
    func loadImage(from url: String?, viewModel: NewsViewModel, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { 
            completion(nil)
            return
        }
        viewModel.fetchImageData(imageUrl: url) { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
}
