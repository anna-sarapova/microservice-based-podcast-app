import requests

BASE = "http://127.0.0.1:5005/"

# get a single podcast using the ID
response = requests.get(BASE + "download/1")
print(response)
# json_response = response.json()
# response_file_name = json_response["podcast_file"]
# print(response.json())
# print(response_file_name)
# print("response type ", type(response))
