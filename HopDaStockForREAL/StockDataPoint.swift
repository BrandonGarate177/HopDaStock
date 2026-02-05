import Foundation

struct StockDataPoint: Identifiable {
    let id = UUID()
    let date: String
    let openPrice: Double
    let closePrice: Double
}
