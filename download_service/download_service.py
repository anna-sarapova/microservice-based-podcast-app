import requests
from flask_restful import Api, Resource
from flask_sqlalchemy import SQLAlchemy
import splitter
from flask import Flask, make_response

app = Flask(__name__)
api = Api(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///podcast.db'
db = SQLAlchemy(app)

AUDIO_FILES_PATH = r"D:\workspace\PAD\microservice-based-podcast-app\download_service\audio_files"


class Download(Resource):
    def get(self, podcast_id):
        response_file_name = get_file_name(podcast_id)
        split_files = open_file(response_file_name)
        print("Split file", split_files)
        nr_of_files = len(split_files)
        print("Nr of chunked files", nr_of_files)
        myResponse = make_response(f'Response: There are {nr_of_files} nr of chunks for this podcast file')
        myResponse.headers['customHeader'] = f'Nr of chunks is {nr_of_files}'
        myResponse.status_code = 200
        return myResponse


class GetChunk(Resource):
    def get(self, podcast_id, chunk_id):
        response_file_name = get_file_name(podcast_id)
        split_files = open_file(response_file_name)
        print("Split file", split_files)
        nr_of_files = len(split_files)
        print("Nr of chunked files", nr_of_files)
        if chunk_id + 1 <= nr_of_files:
            element = split_files[chunk_id]
            myResponse = make_response(f'{element} [Chunk {chunk_id}/{nr_of_files} sent successfully] ')
            myResponse.headers['customHeader'] = f'Total nr. of chunks is {nr_of_files}'
            myResponse.status_code = 200
            myResponse.mimetype = element
            return myResponse
        else:
            myResponse = make_response(f'Bad Request. Incorrect chunk ID')
            myResponse.headers['customHeader'] = 'Incorrect chunk ID'
            myResponse.status_code = 400
            return myResponse


def get_file_name(podcast_id):
    podcast_data = requests.get("http://content_retrieval:5000/podcast/" + str(podcast_id))
    print(podcast_data.json())
    response = podcast_data.json()
    response_file_name = response["podcast_file"]
    print(response_file_name)
    return response_file_name


def open_file(response_file_name):
    src = 'audio_files/' + response_file_name
    folder = 'audio_files/output'
    dest = folder + '/output-'
    # extract data from wav file
    data = splitter.readwave(src)
    # split file into equal 1-second intervals
    split_files = splitter.split(data)

    # save each 1-second interval to output as individual files
    ex = splitter.writewave(dest + 'ex-', split_files)
    print(ex)
    return ex


api.add_resource(Download, "/download/<int:podcast_id>")
api.add_resource(GetChunk, "/download/<int:podcast_id>/<int:chunk_id>")

if __name__ == "__main__":
    personal_data = {"name": "download_service", "address": "http://download_service", "port": 5005, "status": "active"}
    requests.post('http://service_discovery:8008/register_me', json=personal_data)
    print("Register request was sent")
    app.run(host="download_service" ,port=5005, debug=True)

