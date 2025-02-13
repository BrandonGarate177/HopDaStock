import SwiftUI

struct StockView: View {
    @State private var stockData: [(date: String, closePrice: Double, openPrice: Double)] = []
    @State private var errorMessage: String?
    @State var small = true
    @State private var searchText: String = ""
    @State var hasCalls = true
    @State var calls = true
    @State var temp = "Prediction"
    @State private var plotPath: String? = nil
    @State private var predictedDirection: String? = nil
    @State private var actualDirection: String? = nil
    @State private var errorMessage_Real: String?
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            // MARK: - Master Column: Stock List
            VStack(alignment: .leading) {
                Text("Stock Data")
                    .font(.system(size: small ? 24 : 26))
                    .bold(true)
                    .fontWeight(small ? .none : .bold)
                    .frame(width: 350, height: 30, alignment: .center)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 1)) {
                            small.toggle()
                        }
                    }
                Spacer()
                List(stockData, id: \.date) { data in
                    VStack(alignment: .leading) {
                        Text("\(data.date)").font(.system(size: 18))
                        Text("Closing Price: $\(data.closePrice, specifier: "%.2f")")
                        Text("Opening Price: $\(data.openPrice, specifier: "%.2f")")
                    }
                    .bold(true)
                }
            }
            .background(Color(red: 45/255, green: 106/255, blue: 79/255))
            .searchable(text: $searchText, placement: .sidebar)
            
            // MARK: - Detail Column: Graph and Button
            VStack(spacing: 0) {
                // Graph appears at the top
                if let plotPath = plotPath, let nsImage = NSImage(contentsOfFile: plotPath) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 400, maxHeight: 300)
                        .padding(.bottom, 10) // Optional spacing between graph and button
                Text("")
                } else {
                    Text("")
                        .foregroundColor(.black)
                }
                
                if let predicted = predictedDirection, let actual = actualDirection {
                    Text("Prediction: \(predicted)  (Actual: \(actual))")
                        .font(.headline)
                        .padding(.bottom, 10)
                }
                
                // Button at the bottom
                Button("Get Prediction") {
                    testRunningScript()
                    fetchStockData(data: searchText)
                    fetchAndStoreJSON(data: searchText)
                    
                    let jsonURL = URL(fileURLWithPath: "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_data.json")
                    runMLPrediction(jsonURL: jsonURL)
                    
                    if !calls {
                        temp = "ERROR: OUT OF API CALLS"
                    }
                }
                .controlSize(.large)
            }
            .navigationTitle(temp)
            .ignoresSafeArea()
        }
        .background(Color(red: 149/255, green: 213/255, blue: 178/255))
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Invalid Stock Symbol"),
                message: Text(errorMessage ?? "Please enter a valid stock symbol."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Helper Functions
    
    func checkStateOfCalls() -> Bool {
        if !hasCalls {
            print("hasCalls: \(hasCalls)")
        } else {
            print("hasCalls: \(hasCalls)")
        }
        return hasCalls
    }
    
    func fetchStockData(data: String) {
        let stockService = StockService()
        stockService.fetchStockData(symbol: data) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    stockData = stockService.parseStockData(json)
                case .failure(let error):
                    errorMessage_Real = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    func fetchAndStoreJSON(data: String) {
        let stockService = StockService()
        stockService.fetchStockData(symbol: data) { result in
            switch result {
            case .success(let data):
                let parsed = stockService.parseStockData(data)
                DispatchQueue.main.async {
                    stockData = parsed
                    if let fileURL = stockService.saveStockDataToJSON(parsed) {
                        print("Wrote stock data to JSON at: \(fileURL.path)")
                    }
                }
            case .failure(let error):
                print("Error fetching stock data:", error)
            }
        }
    }
    
    func runMLPrediction(jsonURL: URL) {
        let stockService = StockService()
        guard let scriptPath = stockService.pathForPythonScript(named: "stock_predictor") else {
            print("Could not find stock_predictor.py in bundle")
            return
        }
        
        stockService.runEmbeddedPythonScript(
            scriptPath: scriptPath,
            arguments: [jsonURL.path]
        ) { output, error in
            if let error = error {
                print("Error running Python script:", error)
            } else if let output = output {
                print("Script output:", output)
                if let data = output.data(using: .utf8) {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            let predicted = dict["predicted_direction"] ?? "N/A"
                            let actual = dict["actual_direction"] ?? "N/A"
                            let returnedPlotPath = dict["plot_path"] ?? ""
                            
                            print("Predicted: \(predicted), Actual: \(actual)")
                            print("Plot at: \(returnedPlotPath)")
                            
                            DispatchQueue.main.async {
                                self.plotPath = returnedPlotPath
                                self.predictedDirection = predicted
                                self.actualDirection = actual
                            }
                        }
                    } catch {
                        print("JSON parse error:", error)
                    }
                }
            }
        }
    }
    
    func testRunningScript() {
        let stockService = StockService()
        if let scriptPath = stockService.pathForPythonScript(named: "stock_predictor") {
            print("Found script at: \(scriptPath)")
            let arguments: [String] = []
            stockService.runEmbeddedPythonScript(
                scriptPath: scriptPath,
                arguments: arguments
            ) { output, error in
                if let error = error {
                    print("Error running Python script:", error)
                } else {
                    print("Script output:", output ?? "No output")
                    if let trimmedOutput = output?.trimmingCharacters(in: .whitespacesAndNewlines),
                       trimmedOutput == "out of calls" {
                        DispatchQueue.main.async {
                            self.hasCalls = false
                        }
                    }
                }
            }
        }
    }
}
