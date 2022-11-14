from flask_restful import Api, Resource
from flask import Flask, request
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler

DELTA_TIME = timedelta(seconds=60)
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
        data = request.get_json()
        updated_podcast_list = update_cache(data)
        print("Cache list after append list: ", updated_podcast_list)
        return "ok"


def update_cache(podcast_list):
    print("Podcast list: ", podcast_list)
    for element in podcast_list:
        current_time = datetime.now() + DELTA_TIME
        element.update({"expire_time": current_time.strftime('%Y-%m-%d %H:%M:%S.%f')})
        print("Updated element", element)
        cache_list.append(element)
    print("Updated list:", cache_list)
    return cache_list


class CachePodcastItem(Resource):
    def get(self, podcast_id):
        print("Request received")
        print("Cache list: ", cache_list)
        if len(cache_list) == 0:
            return None
        else:
            for item in cache_list:
                print("Item", item)
                if podcast_id == item["id"]:
                    print("returned item", item)
                    return item
                else:
                    return None

    def post(self, podcast_id):
        # cache_list.append(item.json())
        print("podcast_id", podcast_id)
        data = request.get_json()
        print("Received item: ", data)
        updated_podcast_list = update_item_cache(data)
        print("Cache list after append item: ", updated_podcast_list)
        return "ok"


def update_item_cache(podcast_item):
    print("Podcast list: ", podcast_item)
    current_time = datetime.now() + DELTA_TIME
    podcast_item.update({"expire_time": current_time.strftime('%Y-%m-%d %H:%M:%S.%f')})
    print("Updated item", podcast_item)
    cache_list.append(podcast_item)
    print("Updated list:", cache_list)
    return cache_list


def delete_routine():
    # print("Hiiiiiii")
    now = datetime.now()
    for element in cache_list:
        new_element = datetime.strptime(element["expire_time"], '%Y-%m-%d %H:%M:%S.%f')
        # print("new element ", new_element)
        if new_element < now:
            cache_list.remove(element)
            print("Cache list after remove", cache_list)


api.add_resource(CachePodcastList, "/cache_podcasts")
api.add_resource(CachePodcastItem, "/cache_podcast/<int:podcast_id>")

if __name__ == "__main__":
    scheduler = BackgroundScheduler()
    scheduler.add_job(delete_routine, 'interval', seconds=20)
    scheduler.start()
    app.run(port=9000, debug=True)

