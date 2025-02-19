//
//  Interactor.swift
//  CryptoViper
//
//  Created by Rafet Can AKAY on 27.01.2025.
//

import Foundation

//Talks to presenter
//class, protocol

protocol AnyInteractor {
    var presenter : AnyPresenter? {get set}
    
    func downloadCryptos(with currency: String)
    func bestCoinToBuy(with crpytos: [Crypto]) -> Crypto?
    func bestCoinToSell(with crpytos: [Crypto]) -> Crypto?
    
    func fetchAIAnalysis(for cryptos: [Crypto])
}

class CryptoInteractor : AnyInteractor {
    
    var presenter: AnyPresenter?
    
    func bestCoinToBuy(with cryptos: [Crypto]) -> Crypto? {
        guard !cryptos.isEmpty else { return nil }
        
        var bestCoin: Crypto?
        var bestScore: Double = -Double.infinity // Start with a very low value
        
        for crypto in cryptos {
            let athAdvantage = (crypto.alltimehigh - crypto.currentprice) / crypto.alltimehigh * 100
            let atlDisadvantage = (crypto.currentprice - crypto.alltimelow) / crypto.alltimelow * 100
            let marketCapScore = log(crypto.marketcap + 1) // Log scale to avoid extreme values
            let priceChange24hScore = crypto.priceChangePercentage24h // Trend indicator
            let marketCapChange24hScore = crypto.marketCapChangePercentage24h
           
            // If maxsupply is nil, default circulatingSupplyRatio to 0
            let circulatingSupplyRatio = (crypto.maxsupply != nil) ? (crypto.circulatingSupply / crypto.maxsupply!) : 0
                
            // Combine all factors into a final score
            let combinedScore = (
                (athAdvantage * 0.3) +        // 30% - Potential upside based on ATH
                (atlDisadvantage * 0.2) +     // 20% - Distance from ATL
                (marketCapScore * 0.2) +      // 20% - Market cap log-scaled
                (priceChange24hScore * 0.1) + // 10% - Recent price trend
                (marketCapChange24hScore * 0.1) + // 10% - Recent market cap change
                (circulatingSupplyRatio * 0.1)   // 10% - Scarcity factor
            )
            
            if combinedScore > bestScore {
                bestScore = combinedScore
                bestCoin = crypto
            }
        }
        
        return bestCoin
    }
    
    func bestCoinToSell(with cryptos: [Crypto]) -> Crypto? {
        guard !cryptos.isEmpty else { return nil }
        
        var worstCoin: Crypto?
        var worstScore: Double = Double.infinity  // Start with a very high value
        
        for crypto in cryptos {
            let athAdvantage = (crypto.alltimehigh - crypto.currentprice) / crypto.alltimehigh * 100
            let atlDisadvantage = (crypto.currentprice - crypto.alltimelow) / crypto.alltimelow * 100
            let marketCapScore = log(crypto.marketcap + 1)
            let priceChange24hScore = crypto.priceChangePercentage24h
            let marketCapChange24hScore = crypto.marketCapChangePercentage24h
            
            // If maxsupply is nil, default circulatingSupplyRatio to 0
            let circulatingSupplyRatio = (crypto.maxsupply != nil) ? (crypto.circulatingSupply / crypto.maxsupply!) : 0
            
            let score = (
                (athAdvantage * -0.3) +   // Reverse logic (closer to ATH = bad for selling)
                (atlDisadvantage * 0.2) + // The further from ATL, the worse for selling
                (marketCapScore * -0.2) + // Larger market cap = more stability (less selling pressure)
                (priceChange24hScore * -0.1) + // Price dropping = better selling point
                (marketCapChange24hScore * -0.1) + // Market cap dropping = bad sentiment
                (circulatingSupplyRatio * 0.1) // Higher supply = lower scarcity (bad for holding)
            )
            
            if score < worstScore {
                worstScore = score
                worstCoin = crypto
            }
        }
        
        return worstCoin
    }


    
    func downloadCryptos(with currency: String) {
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)") else {
                    return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,response,error in
            
            guard let data = data, error == nil else {
                self?.presenter?.interactorDidReceivedCrypto(result: .failure(NetworkError.NetworkFailed))
                return
            }
            do {
                let receivedcryptos = try JSONDecoder().decode([Crypto].self, from: data)
                self?.presenter?.interactorDidReceivedCrypto(result: .success(receivedcryptos))
                
            } catch {
                // Try parsing the response as an error message
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let status = jsonObject["status"] as? [String: Any],
                      let errorCode = status["error_code"] as? Int, errorCode == 429 {
                      self?.presenter?.interactorDidReceivedCrypto(result: .failure(NetworkError.RateLimitExceeded))
                       return
                }
                // Print the error to the console
                print("Parsing failed with error: \(error)")
                self?.presenter?.interactorDidReceivedCrypto(result: .failure(NetworkError.ParsingFailed))
            }
        }
        task.resume()
    }
    
    
    
    // ai
    private let aiKey = Bundle.main.infoDictionary?["AI_API_KEY"] as? String ?? ""
    
    // Call this after fetching cryptos
    func fetchAIAnalysis(for cryptos: [Crypto]) {
        print("AI Test fetchAIAnalysis")
        let prompt = prepareAIPrompt(cryptos: cryptos)
        sendToAIModel(prompt: prompt, cryptos: cryptos)
    }
        
    private func prepareAIPrompt(cryptos: [Crypto]) -> String {
      
        print("AI Test prepareAIPrompt")
        let cryptoDescriptions = cryptos.map { crypto in
            """
            \(crypto.currencysymbol.uppercased()): Priced at \(crypto.currentprice) (\(crypto.priceChangePercentage24h)% 24h),
            ATH: \(crypto.alltimehigh), Market Cap: \(crypto.marketcap)
            """
        }.joined(separator: "\n")
            
        return """
                Analyze these cryptocurrencies and respond EXACTLY in the JSON format below to select one crypto for best to buy now and one crypto to sell now.
                       Provide only one sentence for each reason (buy_reason and sell_reason). Use the following JSON structure:
                       {
                           "buy_symbol": "SYMBOL",
                           "sell_symbol": "SYMBOL",
                           "buy_reason": "...",
                           "sell_reason": "..."
                       }

                       Consider factors such as price change percentage, market cap, all-time high, and all-time low, market cap, max supply when making your decision.
                       Only use the data provided below and do not make assumptions about external factors.
                       If no clear buy/sell recommendation can be made, set the symbol to "NONE" and provide a reason explaining why.

                       Data:
                       \(cryptoDescriptions)
            """
        }
        
        private func sendToAIModel(prompt: String, cryptos: [Crypto]) {
            
            let url = URL(string: "https://api.deepinfra.com/v1/openai/chat/completions")!
            let deepInfraKey = aiKey

            var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("Bearer \(deepInfraKey)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
            let parameters: [String: Any] = [
                "model": "mistralai/Mistral-7B-Instruct-v0.1",
                "messages": [["role": "user", "content": prompt]],
                "temperature": 0.7,
                "response_format": ["type": "json_object"] // Corrected this line
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                self.presenter?.interactorDidReceiveAIAnalysis(buy: nil, sell: nil, buyReason: nil, sellReason: nil)
                return
            }
            
            request.httpBody = httpBody
            
            URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    self?.presenter?.interactorDidReceiveAIAnalysis(buy: nil, sell: nil, buyReason: nil, sellReason: nil)
                    return
                }
                
                // Print the raw response to verify the structure
                if let responseString = String(data: data, encoding: .utf8) {
                    print("AI Test Raw API response: \(responseString)")
                }
                
                do {
                    // Decode the API response
                    let response = try JSONDecoder().decode(AIResponse.self, from: data)
                    
                    // Extract the content field
                    if let content = response.choices.first?.message.content {
                        // Remove the Markdown code block markers
                        let jsonString = content
                            .replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                       
                        // Convert the cleaned JSON string to Data
                        if let jsonData = jsonString.data(using: .utf8) {
                            // Decode the JSON array into [AIDecision]
                            let aiDecision = try JSONDecoder().decode(AIDecision.self, from: jsonData)
                            
                        
                            
                            self?.presenter?.interactorDidReceiveAIAnalysis(
                                buy: aiDecision.buy_symbol,
                                sell: aiDecision.sell_symbol,
                                buyReason: aiDecision.buy_reason,
                                sellReason: aiDecision.sell_reason
                            )
                        }
                    }
                } catch {
                    self?.presenter?.interactorDidReceiveAIAnalysis(buy: nil, sell: nil, buyReason: nil, sellReason: nil)
                }
            }.resume()
        }
    //a aid
}

