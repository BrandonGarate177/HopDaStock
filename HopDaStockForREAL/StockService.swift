import Foundation

class StockService {
    func fetchStockData(symbol: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path),
              let apiKey = dictionary["ALPHA_VANTAGE_API_KEY"] as? String else {
            completion(.failure(NSError(domain: "Missing API Key", code: 0, userInfo: nil)))
            return
        }

        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

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
                    if json["Time Series (Daily)"] == nil {
                        let error = NSError(
                            domain: "InvalidStockSymbol",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid stock symbol. Please enter a valid one."]
                        )
                        completion(.failure(error))
                    } else {
                        completion(.success(json))
                    }
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func parseStockData(_ data: [String: Any]) -> [(date: String, closePrice: Double, openPrice: Double)] {
        var stockPrices = [(date: String, closePrice: Double, openPrice: Double)]()

        if let timeSeries = data["Time Series (Daily)"] as? [String: [String: String]] {
            for (date, values) in timeSeries {
                if let closePrice = values["4. close"],
                   let closePriceDouble = Double(closePrice),
                   let openPrice = values["1. open"],
                   let openPriceDouble = Double(openPrice) {
                    stockPrices.append((date: date, closePrice: closePriceDouble, openPrice: openPriceDouble))
                }
            }
        }

        return stockPrices.sorted(by: { $0.date > $1.date })
    }
}
