import SwiftUI

struct StockView: View {
    @StateObject private var viewModel = StockViewModel()
    @State private var searchText: String = ""
    @State private var isCompactTitle = true

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Stock Data")
                    .font(.system(size: isCompactTitle ? 24 : 26))
                    .bold(true)
                    .fontWeight(isCompactTitle ? .none : .bold)
                    .frame(width: 350, height: 30, alignment: .center)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 1)) {
                            isCompactTitle.toggle()
                        }
                    }

                Spacer()

                List(viewModel.stockData) { data in
                    VStack(alignment: .leading) {
                        Text(data.date)
                            .font(.system(size: 18))
                        Text("Closing Price: $\(data.closePrice, specifier: "%.2f")")
                        Text("Opening Price: $\(data.openPrice, specifier: "%.2f")")
                    }
                    .bold(true)
                }
            }
            .background(Color(red: 45/255, green: 106/255, blue: 79/255))
            .searchable(text: $searchText, placement: .sidebar)

            VStack(spacing: 0) {
                Button("Get Stock Data") {
                    viewModel.fetchStock(symbol: searchText)
                }
                .controlSize(.large)
                .disabled(viewModel.isLoading)
            }
            .navigationTitle("Stock Viewer")
            .ignoresSafeArea()
        }
        .background(Color(red: 149/255, green: 213/255, blue: 178/255))
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Invalid Stock Symbol"),
                message: Text(viewModel.errorMessage ?? "Please enter a valid stock symbol."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    StockView()
}
