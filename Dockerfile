FROM python:3.9-slim

WORKDIR /microservice
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 80

CMD ["python", "app.py"]
