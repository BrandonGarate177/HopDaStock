import Foundation
import SwiftUI

struct StockView: View {
    @State private var stockData: [(date: String, closePrice: Double, openPrice: Double)] = []
    @State private var errorMessage: String?
    
    
    
    var body: some View {
        
        NavigationView {
            List(stockData, id: \.date) { data in
                
                VStack(alignment: .leading) {
                    Text("Date: \(data.date)")
                    Text("Closing Price: $\(data.closePrice, specifier: "%.2f")")
                    Text("Opening Price: $\(data.openPrice, specifier: "%.2f")")
                    
                    
                }
                
                
            }
            
            
            Button("Run Python ML") {
                testRunningScript()
                
                
            }
            .buttonStyle(.bordered)
            //             .fixedSize(.random())
            .navigationTitle("Stock Prices")
            .onAppear {
                fetchStockData()
                //                fetchAndStoreJSON()
            }
            
            
        }
    }
    
    
    
    //    I can possibly remove this
    func fetchStockData() {
        let stockService = StockService()
        
        stockService.fetchStockData(symbol: "QQQ") { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    stockData = stockService.parseStockData(data)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }
        print("did this even try?")
        
        
    }
    
    
    
    func testRunningScript() {
        let stockService = StockService()
        stockService.testRunningScript()
    }
    
    
    
    func fetchAndStoreJSON() {
        let stockService = StockService()
        stockService.fetchStockData(symbol: "QQQ") { result in
            switch result {
            case .success(let data):
                // Parse
                let parsed = stockService.parseStockData(data)
                DispatchQueue.main.async {
                    stockData = parsed
                    // Once we have the data, we can save it to JSON:
                    if let fileURL = stockService.saveStockDataToJSON(parsed) {
                        print("Wrote stock data to JSON at: \(fileURL.path)")
                        // Next step: pass fileURL to the Python script, etc.
                    }
                }
            case .failure(let error):
                print("Error fetching stock data:", error)
                }
            }
        }
}
    
    
    
    
    

