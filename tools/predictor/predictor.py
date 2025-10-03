"""Simple predictor Flask app for Colab.

POST /predict
  body: { "historical": [float,...], "periods": int }
  returns: { "predictions": [float,...], "model": "prophet"|"linear" }

If Prophet is available it will be used; otherwise, falls back to sklearn LinearRegression.
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import traceback

app = Flask(__name__)
CORS(app)

try:
    from prophet import Prophet
    HAS_PROPHET = True
except Exception:
    HAS_PROPHET = False

# Simple in-memory cache for predictions (key: (tuple(historical), periods, model))
prediction_cache = {}

def predict_with_prophet(history, periods=1):
    # history: list of floats
    n = len(history)
    if n < 3:
        raise ValueError('Need at least 3 points for Prophet prediction')

    # create dates ending today
    dates = pd.date_range(end=pd.Timestamp.today(), periods=n)
    df = pd.DataFrame({'ds': dates, 'y': history})
    m = Prophet(daily_seasonality=False, weekly_seasonality=False, yearly_seasonality=False)
    m.fit(df)
    future = m.make_future_dataframe(periods=periods)
    forecast = m.predict(future)
    preds = forecast['yhat'].tail(periods).values.tolist()
    return preds

def predict_with_linear(history, periods=1):
    # simple linear regression over time index
    n = len(history)
    x = np.arange(n).reshape(-1, 1)
    y = np.array(history)
    from sklearn.linear_model import LinearRegression
    model = LinearRegression()
    model.fit(x, y)
    xf = np.arange(n, n + periods).reshape(-1, 1)
    preds = model.predict(xf).tolist()
    return preds

@app.route('/')
def index():
    return jsonify({'ok': True, 'has_prophet': HAS_PROPHET})

@app.route('/predict', methods=['POST'])
def predict():
    try:
        body = request.get_json(force=True)
        history = body.get('historical')
        periods = int(body.get('periods', 1))
        if not history or not isinstance(history, list):
            return jsonify({'error': 'provide `historical` as list of numbers'}), 400

        # convert possible strings to floats
        history = [float(x) for x in history]
        hist_tuple = tuple(history)

        # try prophet first (if available)
        if HAS_PROPHET and len(history) >= 3:
            cache_key = (hist_tuple, periods, 'prophet')
            if cache_key in prediction_cache:
                preds = prediction_cache[cache_key]
            else:
                preds = predict_with_prophet(history, periods=periods)
                prediction_cache[cache_key] = preds
            return jsonify({'model': 'prophet', 'predictions': preds})

        # fall back to linear regression
        preds = predict_with_linear(history, periods=periods)
        return jsonify({'model': 'linear', 'predictions': preds})
    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # for Colab run: set host to 0.0.0.0 and use ngrok to expose
    app.run(host='0.0.0.0', port=5000, debug=True)
