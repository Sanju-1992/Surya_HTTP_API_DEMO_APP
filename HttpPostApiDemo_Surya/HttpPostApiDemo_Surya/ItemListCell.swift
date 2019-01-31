//
//  ItemListCell.swift
//  HttpPostApiDemo_Surya
//
//  Created by Toor, Sanju on 30/01/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import UIKit

class ItemListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureListCell(name: String? ,email: String?, imageUrl: String? ) {
        guard let nameText = name ,let emailText = email , let imagelink = imageUrl else {
            return
        }
        nameLabel.text = nameText
        emailLabel.text = emailText
        self.fetchImage(urls: imagelink)
    }
    
    private func fetchImage(urls: String) {
        let imageUrl = URL(string: urls)
        guard let imagelink = imageUrl else {
            return
        }
        let task = URLSession.shared.dataTask(with: imagelink) { (data, response, error) in
            if error == nil {
                guard let dataValue = data else {
                    self.profileImageView.image = UIImage(imageLiteralResourceName: "placeholder")
                    return 
                }
                let downloadImage = UIImage(data: dataValue)
                DispatchQueue.main.async(){
                    self.profileImageView.image = downloadImage
                }
            }
        }
        
        task.resume()
    }

}
