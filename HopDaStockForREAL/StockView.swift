
import SwiftUI

struct StockView: View {
    @State private var stockData: [(date: String, closePrice: Double)] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            List(stockData, id: \.date) { data in
                VStack(alignment: .leading) {
                    Text("Date: \(data.date)")
                    Text("Closing Price: $\(data.closePrice, specifier: "%.2f")")
                }
            }
            .navigationTitle("Stock Prices")
            .onAppear {
                fetchStockData()
            }
        }
    }

    func fetchStockData() {
        let stockService = StockService()
        stockService.fetchStockData(symbol: "AAPL") { result in
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
}
