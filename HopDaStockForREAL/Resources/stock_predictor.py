#!/usr/bin/env python3

import sys
import json
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

# For plotting
import matplotlib
matplotlib.use('Agg')  # Use a non-interactive backend so it can save images without a GUI
import matplotlib.pyplot as plt
import os

def main():
#    if len(sys.argv) < 2:
#        print("Error: No JSON file path provided.")
#        sys.exit(1)
#    
#    json_path = sys.argv[1]
#

    #hardcoding the entry to the file for now.
    json_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_data.json"
    
    #Opening the file
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # 3. Convert to a DataFrame
    df = pd.DataFrame(data)  # columns: date, closePrice, openPrice
    
    # 4. Sort by date ascending so time makes sense
    df = df.sort_values(by='date')
    df.reset_index(drop=True, inplace=True)
    
    # 5. Calculate direction = 1 if closePrice(t) > closePrice(t-1)
    df['prev_close'] = df['closePrice'].shift(1)
    df.dropna(inplace=True)  # remove first row (no prev_close)
    
    df['direction'] = (df['closePrice'] > df['prev_close']).astype(int)
    
    # 6. Prepare features
    df['prev_close'] = df['prev_close'].fillna(method='bfill')
    X = df[['openPrice', 'prev_close']]
    y = df['direction']
    
    # 7. Train on all but the last row, test on the last row
    X_train, X_test = X.iloc[:-1], X.iloc[-1:]
    y_train, y_test = y.iloc[:-1], y.iloc[-1:]
    
    model = LogisticRegression()
    model.fit(X_train, y_train)
    
    # 8. Predict direction for the last day
    prediction = model.predict(X_test)[0]  # 0 or 1
    direction_str = "Up" if prediction == 1 else "Down"
    actual_str = "Up" if y_test.values[0] == 1 else "Down"
    
    # 9. Create a plot of the close prices over time
    plt.figure(figsize=(8, 6))
    plt.plot(df['date'], df['closePrice'], label='Close Price')
#    plt.xticks(rotation=45)
#    plt.tight_layout()
#    plt.title('Stock Close Prices Over Time')
#    plt.xlabel('Date')
#    plt.ylabel('Price')
   # plt.legend()
    
    # 10. Save plot to a file
    # We'll store it in a temp path or any path you like. Swift can load it from there.
    # e.g., /tmp or sys.argv[2] if you want a custom path
    plot_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_plot.png"
    plt.savefig(plot_path)
    
    # 11. Print JSON result (prediction + actual + path to plot)
    result = {
        "predicted_direction": direction_str,
        "actual_direction": actual_str,
        "plot_path": plot_path
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
