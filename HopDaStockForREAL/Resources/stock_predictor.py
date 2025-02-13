#!/usr/bin/env python3

import sys
import json
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

# For plotting
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import os

def main():
    # Hardcoded JSON file path for testing
    json_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_data.json"
    
    # Open and load JSON data
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # Create a DataFrame (expected columns: date, closePrice, openPrice)
    df = pd.DataFrame(data)
    
    # Sort by date ascending and reset index
    df = df.sort_values(by='date')
    df.reset_index(drop=True, inplace=True)
    
    # Calculate "direction" as 1 if closePrice(t) > closePrice(t-1)
    df['prev_close'] = df['closePrice'].shift(1)
    df.dropna(inplace=True)
    df['direction'] = (df['closePrice'] > df['prev_close']).astype(int)
    
    # Prepare features and target
    X = df[['openPrice', 'prev_close']]
    y = df['direction']
    
    # Train on all but the last row, test on the last row
    X_train, X_test = X.iloc[:-1], X.iloc[-1:]
    y_train, y_test = y.iloc[:-1], y.iloc[-1:]
    
    model = LogisticRegression()
    model.fit(X_train, y_train)
    
    # Predict direction for the last day
    prediction = model.predict(X_test)[0]
    direction_str = "Up" if prediction == 1 else "Down"
    actual_str = "Up" if y_test.values[0] == 1 else "Down"
    
    # Set your desired background color (normalized RGB)
    bg_color = (149/255, 213/255, 178/255)  # Approx. (0.584, 0.835, 0.698)
    
    # Create a plot with custom background and bold styling
    plt.figure(figsize=(8, 6), facecolor=bg_color)
    ax = plt.gca()
    ax.set_facecolor(bg_color)
    
    # Plot the close prices
    plt.plot(df['date'], df['closePrice'], label='Close Price', linewidth=2, color='black')
    
    # Remove x-axis labels/ticks
    ax.set_xticks([])
    
    # Set bold title and axis labels
    plt.title('Stock Close Prices Over Time', fontweight='bold', fontsize=16)
    plt.xlabel('Date', fontweight='bold', fontsize=14)
    plt.ylabel('Price', fontweight='bold', fontsize=14)
    
    # Set legend with bold font
    leg = plt.legend()
    for text in leg.get_texts():
        text.set_fontweight('bold')
    
    plt.tight_layout()
    
    # Save the plot to a file
    plot_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_plot.png"
    plt.savefig(plot_path)
    plt.close()
    
    # Print the JSON result (prediction, actual, and plot path)
    result = {
        "predicted_direction": direction_str,
        "actual_direction": actual_str,
        "plot_path": plot_path
    }
    print(json.dumps(result))

if __name__ == "__main__":
    try:
        main()
    except Exception as ex:
        print("out of calls")
        print(ex)
