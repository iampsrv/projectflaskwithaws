FROM python:3.12.0b3-alpine3.18
COPY . /app
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "application.py"]