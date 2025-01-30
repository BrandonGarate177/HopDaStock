import Foundation
import PythonKit

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
        
        
        
        // this fetches the api key with the link below. checks to see if we have a valid key and url
        
//        print("API Key retrieved successfully: \(apiKey)")

//         Construct URL for Alpha Vantage API
    
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        // TESTS

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
    
    
    // the real work begins
    
    // StockRecord holds all these variables
    struct StockRecord: Codable{
        let date: String
        let closePrice: Double
        let openPrice: Double
    }

    
    func saveStockDataToJSON(_ records: [(date: String, closePrice: Double, openPrice: Double)]) -> URL? {
        let stockRecords = records.map { StockRecord(date: $0.date, closePrice: $0.closePrice, openPrice: $0.openPrice) }
        print("saveStockDataToJSON RUNS")
        
        do {
            let jsonData = try JSONEncoder().encode(stockRecords)
            //Saves to a temp file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("stock_data.json")
            try jsonData.write(to: tempURL)
            return tempURL
            // catch statement incase it not working properly
        } catch {
            print("Error writing JSON: \(error)")
            return nil
            
        }
        
    }
    
    
    
    
    func pathForPythonScript(named scriptName: String) -> String? {
        // This looks for a file named "<scriptName>.py" in the app bundle.
        return Bundle.main.path(forResource: scriptName, ofType: "py")
    }
    
    

    func runPythonScript(scriptPath: String, completion: @escaping (String?, Error?) -> Void) {
//        Creates a process object and sets it capable of reading out script
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", scriptPath]
//          Debugging clutch
        let outputPipe = Pipe()
        let errorPipe = Pipe()

//        Man i love processing
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Its literally so beautiful
        process.terminationHandler = { _ in
            // Read stdout
            let outData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outData, encoding: .utf8)

            // Read stderr
            let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errors = String(data: errData, encoding: .utf8)
            // THIS LITTLE
            if let errors = errors, !errors.isEmpty {
                print("Script error:\n\(errors)")
            }
            
            completion(output, nil)
        }

        
        do {
            try process.run()
        } catch {
            completion(nil, error)
        }
    }
    
    
    
    

    
    
//    ################### DEBUG ########################
    func testRunningScript() {
        // 1) Get the path to 'stock_predict.py' from the app bundle
        if let scriptPath = pathForPythonScript(named: "stock_predictor") {
            print("Found script at: \(scriptPath)")
            
            // 2) Run the script
            runPythonScript(scriptPath: scriptPath) { output, error in
                if let error = error {
                    print("Error running Python script: \(error)")
                } else {
                    print("Script output: \(output ?? "No output")")
                    // IT PRINTS NO OUTPUT BECAUSE IT DOESN'T EVEN RUN BRUHH H
                }
            }
        } else {
            print("Could not find stock_predict.py in the app bundle.")
        }
    }
    
    
    
    
    
 
        
    
}
