//
//  Presenter.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 27.01.2025.
//

import Foundation

//talk to interactor, router, viewer
// class, protocol
enum NetworkError : Error {
    case NetworkFailed
    case ParsingFailed
    case RateLimitExceeded
}


protocol AnyPresenter {
    var router : AnyRouter? {get set}
    var interactor : AnyInteractor? {get set}
    var view : AnyView? {get set}
    
    func interactorDidReceivedCrypto(result: Result<[Crypto],Error>)
    
    func interactorDidReceiveAIAnalysis(buy: String?, sell: String?, buyReason: String?, sellReason: String?)
    
}

class CryptoPresenter : AnyPresenter {
    
    var router: AnyRouter?
    
    var interactor: AnyInteractor? {
        didSet {
            interactor?.downloadCryptos(with: kdefaultCurrency)
        }
    }
    
    var view: AnyView?
    
    // In your Presenter implementation
    func interactorDidReceiveAIAnalysis(buy: String?, sell: String?, buyReason: String?, sellReason: String?) {
        DispatchQueue.main.async {
            
            if let buy = buy, let reason = buyReason {
                self.view?.showBuyRecommendation(crypto: buy, reason: reason)
            }else {
                self.view?.hideBuyRecommendation()
            }
            if let sell = sell, let reason = sellReason {
                self.view?.showSellRecommendation(crypto: sell, reason: reason)
            }else{
                self.view?.hideSellRecommendation()
            }
        }
    }
    
    func interactorDidReceivedCrypto(result: Result<[Crypto], Error>) {
        switch result {
        case .success(let cryptos):
            //view.update
            view?.updateCryptos(with: cryptos)
        case .failure(let error):
            //error
            // Determine the error type and set a custom message
                    let errorMessage: String
                    
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .NetworkFailed:
                            errorMessage = "Network connection failed. Please check your internet and try again."
                        case .ParsingFailed:
                            errorMessage = "Data parsing error. Please report this issue."
                        case .RateLimitExceeded:
                            errorMessage = "Too many requests! Please wait and try again later."
                        }
                    } else {
                        errorMessage = "An unknown error occurred. Please try again."
                    }
                    
                    // Pass the custom error message to the view
                    view?.updateError(with: errorMessage)

        }
    }
    
    
    
}
