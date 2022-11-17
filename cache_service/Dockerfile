FROM python:3.8
WORKDIR /cache_service
COPY requirements.txt .
ADD cache.py .
CMD ["python", "./cache.py"]
EXPOSE 9000

RUN pip install -r requirements.txt

