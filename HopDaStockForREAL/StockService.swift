import Foundation

class StockService {
    // Fetch stock data from Alpha Vantage API
    func fetchStockData(symbol: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Load API Key from Secrets.plist
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path),
              let apiKey = dictionary["ALPHA_VANTAGE_API_KEY"] as? String else {
                  print("Failed to retrieve API key")
                  completion(.failure(NSError(domain: "Missing API Key", code: 0, userInfo: nil)))
                  return
        }
//        print("API Key retrieved successfully: \(apiKey)")

//         Construct URL for Alpha Vantage API
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // Make network request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
//        let testURL = URL(string: "https://www.google.com")!
//        let task = URLSession.shared.dataTask(with: testURL) { data, response, error in
//            if let error = error {
//                print("Test URL failed with error: \(error.localizedDescription)")
//            } else {
//                print("Test URL succeeded!")
//            }
//        }
//        task.resume()
        task.resume()
    }

    // Parse stock data JSON
    func parseStockData(_ data: [String: Any]) -> [(date: String, closePrice: Double, openPrice: Double)] {
        var stockPrices = [(date: String, closePrice: Double, openPrice: Double)]()
        if let timeSeries = data["Time Series (Daily)"] as? [String: [String: String]] {
            for (date, values) in timeSeries {
                if let closePrice = values["4. close"], let closePriceDouble = Double(closePrice), let opnePrice = values["1. open"], let openPriceDouble = Double(opnePrice) {
                    stockPrices.append((date: date, closePrice: closePriceDouble, openPrice: openPriceDouble))
                }
//                if let openPrice = values["1. open"], let openPriceDouble = Double(openPrice) {
//                    stockPrices.append((date: date, openPrice: openPriceDouble))
//                }
            }
        }
        return stockPrices.sorted(by: { $0.date > $1.date })
    }
}
