from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import os
import requests
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()

app = FastAPI()

username = os.getenv("LEMMY_USERNAME")
password = os.getenv("LEMMY_PASSWORD")
instance = os.getenv("LEMMY_INSTANCE")
post_id = os.getenv("POST_ID")

@app.post("/api/votes")
async def get_votes(request: Request):
    data = await request.json()
    post_id = data.get("post_id")
    if not post_id:
        return JSONResponse(content={"error": "Post ID is required"}, status_code=400)

    # Your existing logic to interact with Lemmy and retrieve votes
    # For example:
    # - Authenticate with Lemmy
    # - Retrieve votes for the given post_id
    # - Parse and format the data

    # Placeholder response


    login_url = f"{instance}/api/v3/user/login"
    login_data = {"username_or_email": username, "password": password}
    login_response = requests.post(login_url, json=login_data)

    if login_response.status_code != 200:
        print(f"Login failed: {login_response.text}")
        exit(1)

    auth_token = login_response.json()["jwt"]

    # Retrieve post likes with pagination
    page = 1
    per_page = 50  # Adjust as needed
    while True:
        likes_url = f"{instance}/api/v3/post/like/list?post_id={post_id}&page={page}&limit={per_page}"
        headers = {"Authorization": f"Bearer {auth_token}"}
        likes_response = requests.get(likes_url, headers=headers)

        if likes_response.status_code != 200:
            print(f"Failed to retrieve post likes: {likes_response.text}")
            exit(1)

        likes_data = likes_response.json()
        post_likes = likes_data.get("post_likes", [])

        if not post_likes:
            break

        # Display voter details with instance
        for vote in post_likes:
            user = vote["creator"]["name"]
            actor_id = vote["creator"]["actor_id"]
            score = vote["score"]

            # Extract instance from actor_id
            parsed_url = urlparse(actor_id)
            instance_domain = parsed_url.netloc

            print(f"User: {user}@{instance_domain}, Vote: {score}")

        page += 1

    return JSONResponse(content={"votes": votes})
