FROM python:2.7

WORKDIR /app
COPY . /app

EXPOSE 8080

ENTRYPOINT ["python", "/app/hello.py"]
