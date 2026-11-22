FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY writer.py .
COPY query_iceberg.py .

CMD ["python", "-u", "writer.py"]
