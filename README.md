# HopDaStock

A native macOS stock data viewer built with SwiftUI.

## Features

- **Real-time Stock Data** - Fetches daily stock prices from Alpha Vantage API
- **Clean Interface** - Simple, focused UI for viewing open/close prices
- **Search** - Look up any stock by symbol (AAPL, GOOGL, MSFT, etc.)
- **Error Handling** - Validates stock symbols and handles API errors gracefully

## Screenshots

<img width="929" alt="Screenshot 2025-02-13 at 11 40 37 AM" src="https://github.com/user-attachments/assets/456829b9-d494-4cb8-9a04-102dc8cc5669" />

## Requirements

- macOS 13.0+
- Xcode 15.0+
- Alpha Vantage API key (free tier available)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/BrandonGarate177/HopDaStock.git
   cd HopDaStock
   ```

2. Get a free API key from [Alpha Vantage](https://www.alphavantage.co/support/#api-key)

3. Create your secrets file:
   ```bash
   cp HopDaStockForREAL/Secrets.plist.template HopDaStockForREAL/Secrets.plist
   ```

4. Edit `HopDaStockForREAL/Secrets.plist` and add your API key:
   ```xml
   <key>ALPHA_VANTAGE_API_KEY</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

5. Open `HopDaStock.xcodeproj` in Xcode and run

## Project Structure

```
HopDaStock/
├── HopDaStockForREAL/          # Main app source
│   ├── HopDaStockApp.swift     # App entry point
│   ├── StockView.swift         # Main UI view
│   ├── StockViewModel.swift    # View model (business logic)
│   ├── StockDataPoint.swift    # Data model
│   ├── StockService.swift      # API service layer
│   ├── Secrets.plist.template  # API key template
│   └── Assets.xcassets/        # App icons and colors
├── HopDaStockForREALTests/     # Unit tests
└── HopDaStockUITests/          # UI tests
```

## Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern:

| Layer | File | Responsibility |
|-------|------|----------------|
| **Model** | `StockDataPoint.swift` | Data structure for stock prices |
| **View** | `StockView.swift` | SwiftUI interface |
| **ViewModel** | `StockViewModel.swift` | State management, coordinates data flow |
| **Service** | `StockService.swift` | API calls and JSON parsing |

## API Usage

This app uses the [Alpha Vantage API](https://www.alphavantage.co/) for stock data. The free tier allows 25 requests per day.

## License

MIT License - feel free to use this code for your own projects.
