
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
                print("Attempting to Run Script")
                testRunningScript()
                print("Post Running Script")
                

            }
            .buttonStyle(.bordered)
//             .fixedSize(.random())
            
            
            
            .navigationTitle("Stock Prices")
            
            .onAppear {
                
                fetchStockData()

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
    }
    
    
    
    func testRunningScript() {
           let stockService = StockService()
           stockService.testRunningScript()
    }
    
  
    
}
