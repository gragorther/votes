from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import requests
from urllib.parse import urlparse

app = FastAPI()

origin = os.environ['FRONTEND_URL']
username = os.environ['LEMMY_USERNAME']
password = os.environ['LEMMY_PASSWORD']
instance = os.environ['LEMMY_INSTANCE']

app.add_middleware(
    CORSMiddleware,
    allow_origins=origin,
    allow_credentials=True,
    allow_methods=["*"],    # Allows all HTTP methods
    allow_headers=["*"],    # Allows all headers
)


# Login to Lemmy
login_url = f"{instance}/api/v3/user/login"
login_data = {"username_or_email": username, "password": password}
login_response = requests.post(login_url, json=login_data)

if login_response.status_code != 200:
    print(f"Login failed: {login_response.text}")
    exit(1)

auth_token = login_response.json()["jwt"]

@app.post("/api/votes")
async def get_votes(request: Request):
    data = await request.json()
    post_id = data.get("post_id")
    comment = data.get("comment")
    if not post_id:
        return JSONResponse(content={"error": "Post ID is required"}, status_code=400)
    if comment == True:
        like_type = "comment"
    else:
        like_type = "post"
    votes = []
    page = 1
    per_page = 50 
    while True:
        likes_url = f"{instance}/api/v3/{like_type}/like/list?{like_type}_id={post_id}&page={page}&limit={per_page}"
        headers = {"Authorization": f"Bearer {auth_token}"}
        likes_response = requests.get(likes_url, headers=headers)

        if likes_response.status_code != 200:
            print(f"Failed to retrieve {like_type} likes: {likes_response.text}")
            return JSONResponse(content={"error": "Failed to retrieve post likes"}, status_code=likes_response.status_code)

        likes_data = likes_response.json()
        post_likes = likes_data.get(f"{like_type}_likes", [])

        if not post_likes: #ends the loop
            break

        for vote in post_likes:
            user = vote["creator"]["name"]
            actor_id = vote["creator"]["actor_id"]
            score = vote["score"]

            # Extract instance from actor_id
            parsed_url = urlparse(actor_id)
            instance_domain = parsed_url.netloc

            votes.append({
                "user": user,
                "instance": instance_domain,
                "vote": score
            })

        page += 1

    return JSONResponse(content={"votes": votes})
