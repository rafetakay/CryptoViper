//
//  View.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 27.01.2025.
//

import Foundation
import UIKit

//Talks to presenter
//class, protocol
//viewcontroller
 
protocol AnyView {
    
    var presenter : AnyPresenter? {get set}
    
    func updateCryptos(with cryptos: [Crypto])
    func updateError(with error: String)
    
    func showBuyRecommendation(crypto: String, reason: String)
    func hideBuyRecommendation()
    
    func showSellRecommendation(crypto: String, reason: String)
    func hideSellRecommendation()
}

class CryptoViewController: UIViewController, AnyView, UITableViewDelegate, UITableViewDataSource {
    
    private let reuseIdentifierForCell = "CryptoCell"
 
    var presenter: AnyPresenter?
    
    var cryptos : [Crypto] = []
    
    private var tableView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        return table
    }()
    
    
    private let bestToBuyCryptoLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.backgroundColor = UIColor.green.cgColor
        label.layer.masksToBounds = true
        
        return label
    }()
    
    private let bestToSellCryptoLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.backgroundColor = UIColor.yellow.cgColor
        label.layer.masksToBounds = true
        
        
        return label
    }()
    
    private let aiRecommendBuyCryptoLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .gray
        label.backgroundColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let aiRecommendSellCryptoLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .gray
        label.backgroundColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel : UILabel = {
        let label = UILabel()
        label.isHidden = false
        label.text = "Downloading.."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
  
    private let currencySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: kCurrencyList)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .blue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.selectedSegmentTintColor = .green
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
           
        return control
    }()
    
    
    private let sortSegmentedControlForTableView: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Price","Market Cap"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .blue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.selectedSegmentTintColor = .green
        control.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        return control
    }()

    @objc private func sortChanged() {
        if sortSegmentedControlForTableView.selectedSegmentIndex == 0 {
            cryptos.sort { $0.currentprice > $1.currentprice }
        } else {
            cryptos.sort { $0.marketcap > $1.marketcap }
        }
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(messageLabel)
        view.addSubview(currencySegmentedControl)
        view.addSubview(bestToBuyCryptoLabel)
        view.addSubview(bestToSellCryptoLabel)
        
        view.addSubview(aiRecommendBuyCryptoLabel)
        view.addSubview(aiRecommendSellCryptoLabel)
        
        view.addSubview(sortSegmentedControlForTableView)
        sortSegmentedControlForTableView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CryptoCell.self, forCellReuseIdentifier: reuseIdentifierForCell)
        tableView.isHidden = true
        

        currencySegmentedControl.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
    }
    
    @objc private func currencyChanged() {
            let selectedCurrency = currencySegmentedControl.titleForSegment(at: currencySegmentedControl.selectedSegmentIndex)?.lowercased() ?? "usd"
            fetchCryptos(with: selectedCurrency)
    }
        
    private func fetchCryptos(with currency: String) {
        (presenter?.interactor as? CryptoInteractor)?.downloadCryptos(with: currency)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        currencySegmentedControl.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.frame.width - 20, height: 30)
        bestToBuyCryptoLabel.frame = CGRect(x: 10, y:currencySegmentedControl.frame.maxY + 10 , width: view.frame.width - 20, height: 50)
        bestToSellCryptoLabel.frame = CGRect(x: 10, y:bestToBuyCryptoLabel.frame.maxY + 10 , width: view.frame.width - 20, height: 50)
        
        aiRecommendBuyCryptoLabel.frame = CGRect(x: 10, y:bestToSellCryptoLabel.frame.maxY + 10 , width: view.frame.width - 20, height: 70)
        aiRecommendSellCryptoLabel.frame = CGRect(x: 10, y:aiRecommendBuyCryptoLabel.frame.maxY + 10 , width: view.frame.width - 20, height: 70)
        
        sortSegmentedControlForTableView.frame = CGRect(x: 10, y: aiRecommendSellCryptoLabel.frame.maxY + 10, width: view.frame.width - 20, height: 30)

    
        tableView.frame = CGRect(x: 0, y: sortSegmentedControlForTableView.frame.maxY + 10, width: view.frame.width, height: view.frame.height - sortSegmentedControlForTableView.frame.maxY - 10)
        
        messageLabel.frame = CGRect(x: 0, y: view.frame.height / 2, width: view.frame.width, height: 50)
    }
    
    //table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierForCell,for: indexPath) as! CryptoCell
       
        cell.receivedcrypto = cryptos[indexPath.row]
        cell.priceLabel.text = "\(cryptos[indexPath.row].currentprice) \(currencySegmentedControl.titleForSegment(at: currencySegmentedControl.selectedSegmentIndex) ?? "")"
        
        cell.contentView.isUserInteractionEnabled = false //içindeki view a tap gesture eklenebilsin diye
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewContoller = DetailViewController()
        
        let selectedCurrencyForDetail = currencySegmentedControl.titleForSegment(at: currencySegmentedControl.selectedSegmentIndex) ?? "USD"
        detailViewContoller.selectedCurrency = selectedCurrencyForDetail

        detailViewContoller.selectedCrypto = cryptos[indexPath.row]
        self.present(detailViewContoller, animated: true,completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenHeight*10/100
    }
    //table view
    
    func updateCryptos(with cryptos: [Crypto]) {
        DispatchQueue.main.async {
            
            self.cryptos = cryptos
            
            //default price sort
            self.sortSegmentedControlForTableView.selectedSegmentIndex = 0
            self.cryptos.sort { $0.currentprice > $1.currentprice }
          
            self.messageLabel.isHidden = true
            self.tableView.reloadData()
            self.tableView.isHidden = false
            
            self.sortSegmentedControlForTableView.isHidden = false
            
            //ai recommend
            (self.presenter?.interactor as? CryptoInteractor)?.fetchAIAnalysis(for: cryptos)
            
            //basic analysis
             self.setupBestToBuyCryptoLabel()
             self.setupBestToSellCryptoLabel()
           
        }
    }
    
    func updateError(with errorstring: String) {
        DispatchQueue.main.async {
            self.cryptos = []
            self.messageLabel.text = errorstring
            self.messageLabel.isHidden = false
            self.tableView.isHidden = true
            
            self.sortSegmentedControlForTableView.isHidden = true
            
            //basic analysis
            self.setupBestToBuyCryptoLabel()
            self.setupBestToSellCryptoLabel()
        }
    }
    
    //ai recommendation
    func showBuyRecommendation(crypto: String, reason: String){
        aiRecommendBuyCryptoLabel.text = "AI Comment to Buy : \(crypto) - \(reason)"
    }
    func hideBuyRecommendation(){
        self.aiRecommendBuyCryptoLabel.text = "No Recommendation"
    }
    
    func showSellRecommendation(crypto: String, reason: String){
        aiRecommendSellCryptoLabel.text = "AI Comment to Sell : \(crypto) - \(reason)"
    }
    func hideSellRecommendation(){
        self.aiRecommendSellCryptoLabel.text = "No Recommendation"
    }
    //ai recommendation
    
    //easy calculation
    private func setupBestToBuyCryptoLabel() {
        if cryptos.isEmpty {
            self.bestToBuyCryptoLabel.text = "No Data"
            return
        }
        guard let bestCoin = (presenter?.interactor as? CryptoInteractor)?.bestCoinToBuy(with: cryptos) else {
            self.bestToBuyCryptoLabel.text = "Best Coin To Buy Error"
            return
        }
        bestToBuyCryptoLabel.text = "Best Coin to Buy Now : \(bestCoin.currencyname) (\(bestCoin.currencysymbol.uppercased()))"
    }
    
    private func setupBestToSellCryptoLabel() {
        if cryptos.isEmpty {
            self.bestToSellCryptoLabel.text = "No Data"
            return
        }
        guard let bestCoin = (presenter?.interactor as? CryptoInteractor)?.bestCoinToSell(with: cryptos) else {
            self.bestToSellCryptoLabel.text = "Best Coin To Buy Error"
            return
        }
        bestToSellCryptoLabel.text = "Best Coin to Sell Now : \(bestCoin.currencyname) (\(bestCoin.currencysymbol.uppercased()))"
    }
    //easy calculation

}

