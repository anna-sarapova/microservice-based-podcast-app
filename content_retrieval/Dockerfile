FROM python:3.8
WORKDIR /content_retrieval
COPY requirements.txt .
ADD content_retrieval.py .
CMD ["python", "./content_retrieval.py"]
EXPOSE 5000

RUN pip install -r requirements.txt

