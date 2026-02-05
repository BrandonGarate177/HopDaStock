import Foundation

@MainActor
class StockViewModel: ObservableObject {
    @Published var stockData: [StockDataPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let stockService = StockService()

    func fetchStock(symbol: String) {
        guard !symbol.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        stockService.fetchStockData(symbol: symbol) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let json):
                    let parsed = self?.stockService.parseStockData(json) ?? []
                    self?.stockData = parsed.map { item in
                        StockDataPoint(
                            date: item.date,
                            openPrice: item.openPrice,
                            closePrice: item.closePrice
                        )
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
}
