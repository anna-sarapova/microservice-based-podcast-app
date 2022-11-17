FROM python:3.8
WORKDIR /download_service
COPY requirements.txt .
ADD download_service.py .
CMD ["python", "./download_service.py"]
EXPOSE 5005

RUN pip install -r requirements.txt

