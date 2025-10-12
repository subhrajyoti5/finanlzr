Colab predictor README

This folder contains a small Flask predictor service you can run in Google Colab to generate simple price forecasts. It will attempt to use Prophet when available and fall back to scikit-learn's LinearRegression when Prophet isn't installed.

1) Setup (Colab)

- Open `predictor_colab.ipynb` in Colab for an easy setup.
- Or create a new Colab notebook and mount your drive or upload files.
- Install dependencies (Prophet can require system deps; the following pip should work in Colab):

!pip install -r /content/finanlzr/tools/predictor/requirements.txt

If Prophet install fails, it will still fall back to scikit-learn.

2) Run the predictor

- Start the Flask app:

!python /content/finanlzr/tools/predictor/predictor.py

- Use ngrok to expose port 5000 (optional):

!pip install pyngrok
!ngrok http 5000

- The service exposes:
  - GET / -> health check and indicates whether Prophet is installed.
  - POST /predict -> accepts JSON: {"historical": [list_of_numbers], "periods": <int, optional default 1>} and returns JSON: {"model":"prophet"|"linear", "predictions":[...]} (list of floats)

3) Example curl (replace <NGROK_URL> with the forwarding URL)

curl -X POST "https://<NGROK_URL>/predict" -H "Content-Type: application/json" -d '{"historical": [100, 101, 102, 99, 105], "periods": 1}'

4) Integrate with app

- Set PREDICTOR_URL in your .env to the ngrok URL.
- The app will call the predictor for stock predictions, falling back to local heuristics if unavailable.

