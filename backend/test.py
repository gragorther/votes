import requests


url = "https://gregtech.eu/api/v3/search"

headers = {
    "accept": "application/json",
}
data = {'q': 'https://lemmy.world/post/28260898'}
response = requests.post(url, headers=headers, data=data)

print(response.text)