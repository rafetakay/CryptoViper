//
//  CryptoCell.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 28.01.2025.
//

import Foundation

import Foundation
import UIKit

class CryptoCell: UITableViewCell {
    
    var receivedcrypto: Crypto? {
        didSet {
            configureCryptoInfo(crypto: receivedcrypto! )
        }
    }
    
    // ImageView for displaying the coin image
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "coinplaceholder") // Placeholder image
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = screenHeight*2/100
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .right
        return label
    }()
    
    var generalStackView = UIStackView()
    
    func configureCryptoInfo(crypto: Crypto) {
        //PRİCE İ TABLEVİEW DA VERİYORUZ SECİLİ olan gecsin diye
        nameLabel.text = crypto.currencyname
        
        // Download and set the image from the URL
        if let imageUrl = URL(string: crypto.currencyimageurl) {
            downloadImage(from: imageUrl)
        }
    }
    
    // Function to download and set the image
    func downloadImage(from url: URL) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self?.iconImageView.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.iconImageView.image = UIImage(named: "coinplaceholder") // Set placeholder if image fails to load
                    }
                }
            }
            task.resume()
    }
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        selectionStyle = .none
        backgroundColor = .white
        
        layoutDuzenle()
    }
    
   func layoutDuzenle() {
   
        // Add iconImageView to the stack view
        iconImageView.anchor(width: screenHeight*4/100, height: screenHeight*4/100)
        nameLabel.anchor(width:screenWidth*40/100,height:screenHeight*8/100)
        priceLabel.anchor(width:screenWidth*30/100, height:screenHeight*8/100)
        
        generalStackView = UIStackView(arrangedSubviews: [iconImageView,nameLabel,priceLabel])
        generalStackView.backgroundColor = .none
        generalStackView.axis = .horizontal
        generalStackView.alignment = .center
        generalStackView.distribution = .fill
        generalStackView.spacing = screenWidth*2/100
        
        addSubview(generalStackView)
        generalStackView.anchor( left: leftAnchor, right: rightAnchor,
                                paddingLeft: screenWidth*2/100,
                                paddingRight: screenWidth*2/100
        )
        generalStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        let separatorView = UIView()
        separatorView.backgroundColor = .gray
        addSubview(separatorView)
        separatorView.anchor(left: leftAnchor,bottom: bottomAnchor,right: rightAnchor,
                             paddingLeft: 0,
                             paddingRight: 0,
                             height: screenHeight*0.1/100)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

