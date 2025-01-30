#!/usr/bin/env python3

import sys
import json
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

def main():
    if len(sys.argv) < 2:
        print("Error: No JSON file path provided.")
        sys.exit(1)
    
    json_path = sys.argv[1]
    
    # Load the JSON data
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # Convert to a DataFrame (columns: date, closePrice, openPrice)
    df = pd.DataFrame(data)
    
    # Sort by date ascending so time makes sense
    df = df.sort_values(by='date')
    df.reset_index(drop=True, inplace=True)
    
    # We'll define "direction" as +1 if today's close > yesterday's close, else 0
    df['prev_close'] = df['closePrice'].shift(1)
    df.dropna(inplace=True)  # remove first row with no prev_close
    
    df['direction'] = (df['closePrice'] > df['prev_close']).astype(int)
    
    # Our naive "features" for demonstration: openPrice, maybe the previous close
    df['prev_close'] = df['prev_close'].fillna(method='bfill')
    X = df[['openPrice', 'prev_close']]
    y = df['direction']
    
    # Train on all but the last row, test on the last row
    X_train, X_test = X.iloc[:-1], X.iloc[-1:]
    y_train, y_test = y.iloc[:-1], y.iloc[-1:]
    
    model = LogisticRegression()
    model.fit(X_train, y_train)
    
    # Predict the direction for the last day
    prediction = model.predict(X_test)[0]  # 0 or 1
    direction_str = "Up" if prediction == 1 else "Down"
    
    # For fun, you could also compute the actual direction for that day:
    actual_direction = "Up" if y_test.values[0] == 1 else "Down"
    
    # Print a JSON result
    # e.g. { "predicted_direction": "Up", "actual_direction": "Down" }
    result = {
        "predicted_direction": direction_str,
        "actual_direction": actual_direction
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
