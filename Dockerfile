FROM python:2.7

WORKDIR /app
COPY ./app /app
RUN pip install -r requirements.txt

EXPOSE 8080

ENTRYPOINT ["python", "/app/hello.py"]
