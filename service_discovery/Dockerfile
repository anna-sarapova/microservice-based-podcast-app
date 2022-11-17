FROM python:3.8
WORKDIR /service_discovery
COPY requirements.txt .
ADD service_register.py .
CMD ["python", "./service_register.py"]
EXPOSE 8008

RUN pip install -r requirements.txt

