import Foundation
import SwiftUI

struct StockView: View {
    @State private var stockData: [(date: String, closePrice: Double, openPrice: Double)] = []
    @State private var errorMessage: String?
    
    @State var small = true
    
    @State private var searchText: String = ""

    
    
    var body: some View {
        
        
        
        NavigationView {
            
            
            
            
            VStack(alignment: .leading) {
                Text("Stock Data")
                    .font(.system(size: small ? 24:26))
                    .bold(true)
                    .fontWeight(small ? .none :.bold)
                    .frame(width: 350, height: 30, alignment: .center)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 1)){
                            small.toggle()
                        }
                        
                    }
                    
                Spacer()
                
                List(stockData, id: \.date) { data in
                    VStack(alignment: .leading) {
                        Text("\(data.date)").font(.system(size: 18))
                        Text("Closing Price: $\(data.closePrice, specifier: "%.2f")")
                        Text("Opening Price: $\(data.openPrice, specifier: "%.2f")")
                    }.bold(true)
                }
            }.background(Color(red: 45/255, green: 106/255, blue: 79/255))
                .searchable(text: $searchText, placement: .sidebar)


            
            
            
            
            
            Button("Get Prediction") {
                testRunningScript()
                fetchStockData(data: searchText)
                fetchAndStoreJSON(data: searchText)
                

                
                
            }.controlSize(.large)
//                .buttonStyle(.borderedProminent)
            //             .fixedSize(.random())
            
            
//                .navigationTitle("Prediciton")
                .navigationTitle("Prediciton")
                
//                .background((
//                    Color(red: 8/255, green: 28/255, blue: 21/255)
//                    
//                ))
                
            
            .ignoresSafeArea()
        }
        .background(Color(red: 149/255, green: 213/255, blue: 178/255))
        

    }
    
    
    
    
    
    
    // Helper functions for the buttons n stuff ya feel me
    
    
    
//        I can possibly remove this
    func fetchStockData(data: String) {
        let stockService = StockService()
        
        stockService.fetchStockData(symbol: data) { result in
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
        print("FetchStock works")
        
        
    }
    
    
    
    func testRunningScript() {
        
        
        let stockService = StockService()
        if let scriptPath = stockService.pathForPythonScript(named: "stock_predictor") {
            print("Found script at: \(scriptPath)")
            
            // Provide empty arguments if your script doesn't need any
            let arguments: [String] = []
            
            // Provide a completion handler if you want output
            stockService.runEmbeddedPythonScript(
                scriptPath: scriptPath,
                arguments: arguments
            ) { output, error in
                if let error = error {
                    print("Error running Python script:", error)
                } else {
                    print("Script output:", output ?? "No output")
                }
            }
        }
    }

    
    
    
    func fetchAndStoreJSON(data: String) {
        let stockService = StockService()
        stockService.fetchStockData(symbol: data) { result in
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
    
    
    
    
    

