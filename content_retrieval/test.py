import requests

BASE = " http://127.0.0.1:5000/"

data = [{"name": "How to create a microservice based app", "description": "Like this", "podcast_file": "1s-sample.wav"},
        {"name": "How to make a pie", "description": "The pie is a simple recipe", "podcast_file": "8s-sample.wav"},
        {"name": "The art of making tea", "description": "This is the podcast for making tea", "podcast_file": "33s-sample.wav"}]

# get all the data from the db
response = requests.get(BASE + "podcasts")
print(response.json())
input()

# post data
for i in range(len(data)):
    response = requests.put(BASE + "podcast/" + str(i), data[i])
    print(response.json())
input()

# get a single podcast using the ID
response = requests.get(BASE + "podcast/1")
print(response.json())
