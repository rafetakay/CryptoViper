//
//  DetailViewController.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 28.01.2025.
//

import Foundation
import UIKit

class DetailViewController : UIViewController {
    
    var selectedCurrency = ""
    var selectedCrypto : Crypto?
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "coinplaceholder") // Placeholder image
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = screenHeight*5/100
        return imageView
    }()
    
    private let currencyLabel : UILabel = {
        let label = UILabel()
        label.isHidden = false
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let priceLabel : UILabel = {
        let label = UILabel()
        label.isHidden = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .gray
        label.backgroundColor = .white
        return label
    }()
    
    private let totalSupplyLabel : UILabel = {
        let label = UILabel()
        label.isHidden = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        label.backgroundColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(iconImageView)
        view.addSubview(currencyLabel)
        view.addSubview(priceLabel)
        view.addSubview(totalSupplyLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        iconImageView.frame = CGRect(x: view.frame.width / 2 - screenHeight*5/100 , y: view.frame.height / 2 - screenHeight*10/100, width: screenHeight*10/100, height:  screenHeight*10/100)
        
        currencyLabel.frame = CGRect(x: view.frame.width / 2 - 100 , y: view.frame.height / 2 + 25, width: screenWidth*50/100, height: 25)
        priceLabel.frame = CGRect(x: view.frame.width / 2 - 100 , y: view.frame.height / 2 + 75, width: screenWidth*70/100, height: 50)
        totalSupplyLabel.frame = CGRect(x: view.frame.width / 2 - 100 , y: view.frame.height / 2 + 150, width: screenWidth*70/100, height: 50)
        
        
        // Ensure selectedCrypto is not nil before accessing its properties
        if let crypto = selectedCrypto {
            
            currencyLabel.text = crypto.currencyname + " / " + crypto.currencysymbol
            priceLabel.text = "Fiyat : \(crypto.currentprice) \(selectedCurrency)"
            totalSupplyLabel.text = "Toplam Arz : \(crypto.currencytotalsupply)"
            
            // Download and set the image from the URL
            if let imageUrl = URL(string: crypto.currencyimageurl) {
                downloadImage(from: imageUrl)
            }
            
            iconImageView.isHidden = false
            currencyLabel.isHidden = false
            priceLabel.isHidden = false
            totalSupplyLabel.isHidden = false
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

}
