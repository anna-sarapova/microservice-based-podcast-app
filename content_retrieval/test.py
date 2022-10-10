import requests

BASE = " http://127.0.0.1:5000/"

data = [{"likes": 10, "name": "Tim", "views": 1000},
        {"likes": 5, "name": "Jorja", "views": 10000},
        {"likes": 500, "name": "Lily", "views": 2000000}]

# for i in range(len(data)):
#     response = requests.put(BASE + "podcast/" + str(i), data[i])
#     print(response.json())
# input()
response = requests.get(BASE + "podcast/2")
print(response.json())
