FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY predictor.py ./
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "predictor:app", "--workers", "1"]
