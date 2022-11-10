from flask_restful import Api, Resource
from flask import Flask, request

app = Flask(__name__)
api = Api(app)

cache_list = []


class CachePodcastList(Resource):
    def get(self):
        print("Cache podcast list", cache_list)
        if len(cache_list) == 0:
            return None
        else:
            print("Cache list: ", cache_list)
            return cache_list

    def post(self):
        print("Data in cache: ", cache_list)
        print("Request", request.data)
        data = request.get_json()
        print("Data in put request ", data)
        updated_podcast_list = update_cache(data)
        print("Cache list after append list: ", updated_podcast_list)
        return "ok"


def update_cache(podcast_list):
    print("Podcast list: ", podcast_list)
    for element in podcast_list:
        cache_list.append(element)
    print("Updated list:", cache_list)
    return cache_list


class CachePodcastItem(Resource):
    def get(self, podcast_id):
        for item in cache_list:
            if podcast_id == item[id]:
                return item
            else:
                return None

    def put(self, item):
        print("Received item: ", item.json())
        cache_list.append(item.json())
        return "ok"


api.add_resource(CachePodcastList, "/cache_podcasts")
api.add_resource(CachePodcastItem, "/cache_podcast/<int:podcast_id>")

if __name__ == "__main__":
    app.run(port=9000, debug=True)

