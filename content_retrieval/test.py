import requests

BASE = " http://127.0.0.1:5000/"

data = [{"name": "How to draw", "description": "Like this", "podcast_file": "sample-3s.mp3"},
        {"name": "Moana", "description": "Hollaaa", "podcast_file": "sample-6s.mp3"},
        {"name": "How to make a pie", "description": "The pie is a simple ", "podcast_file": "sample-6s.mp3"}]

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
