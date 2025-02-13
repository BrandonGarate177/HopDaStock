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


    #hardcoding the entry to the file for now.
    json_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_data.json"
    
    #Opening the file
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    #data frame
    df = pd.DataFrame(data)  # columns: date, closePrice, openPrice
    
    # Sort by date ascending so time makes sense
    
    
    df = df.sort_values(by='date')
    df.reset_index(drop=True, inplace=True)
    
    # Calculate direction = 1 if closePrice(t) > closePrice(t-1)
    df['prev_close'] = df['closePrice'].shift(1)
    df.dropna(inplace=True)  # remove first row (no prev_close)
    
    df['direction'] = (df['closePrice'] > df['prev_close']).astype(int)
    
    # Prepare features
    #df['prev_close'] = df['prev_close'].fillna(method='ffill')
    X = df[['openPrice', 'prev_close']]
    y = df['direction']
    
    # Train on all but the last row, test on the last row
    X_train, X_test = X.iloc[:-1], X.iloc[-1:]
    y_train, y_test = y.iloc[:-1], y.iloc[-1:]
    
    model = LogisticRegression()
    model.fit(X_train, y_train)
    
    # Predict direction for the last day
    prediction = model.predict(X_test)[0]  # 0 or 1
    direction_str = "Up" if prediction == 1 else "Down"
    actual_str = "Up" if y_test.values[0] == 1 else "Down"
    
    # Create a plot of the close prices over time
    plt.figure(figsize=(8, 6))
    plt.plot(df['date'], df['closePrice'], label='Close Price')

    plot_path = "/var/folders/0f/8g4pp70178j8tcfvh90vpbhc0000gn/T/stock_plot.png"
    
    plt.savefig(plot_path)
    plt.close()
    
    # Print JSON result (prediction + actual + path to plot)
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
#        print("Out of API Calls")
         print("out of calls")
         print(ex)
         
    
