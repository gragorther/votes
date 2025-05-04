from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import os
import aiohttp
from urllib.parse import urlparse  # this is one very useful library
from sqlmodel import Field, Session, SQLModel, create_engine, select

# Configuration variables
origin = os.environ["FRONTEND_URL"]
username = os.environ["LEMMY_USERNAME"]
password = os.environ["LEMMY_PASSWORD"]
lemmy_instance = os.environ["LEMMY_INSTANCE"]
database_url = os.environ["DATABASE_URL"]


engine = create_engine(database_url, echo=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Before `yield`: startup
    app.state.http = aiohttp.ClientSession()

    # Login to Lemmy
    login_url = f"{instance}/api/v3/user/login"
    login_data = {"username_or_email": username, "password": password}
    async with app.state.http.post(login_url, json=login_data) as login_response:
        login_response.raise_for_status()
        data = await login_response.json()
        app.state.auth_token = data["jwt"]

    yield

    # After `yield`: shutdown
    await app.state.http.close()


# Initialize FastAPI with the lifespan context
app = FastAPI(lifespan=lifespan)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=origin,
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers
)


class post_like(SQLModel, table=True):
    post_id: int = Field(primary_key=True)
    person_id: int = Field(primary_key=True)
    score: int
    published: int | None = None


class person(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str
    instance_id: int
    actor_id: str


class instance(SQLModel, table=True):
    id: int = Field(primary_key=True)
    domain: str


@app.get("/api/user")
async def get_user_votes(request: Request):
    data = await request.json()
    user_url = data.get("user_url")
    user_instance = user_url.split(
        "@"
    )[
        1
    ]  # splits the user url (such as lena@gregtech.eu) by the @ symbol, then gets the second element from that list
    username = user_url.split("@")[1]
    with Session(engine) as session:  # gets instance ID
        statement = select(instance).where(instance.domain == user_instance)
        instance_id = session.exec(statement)["id"]

    with Session(engine) as session:  # gets person ID
        statement = select(
            person
        ).where(
            person.instance_id == instance_id and person.name == username
        )  # the first one is the instance ID from the database, the other is the one acquired from the block above
        person_id = session.exec(statement)

    with Session(engine) as session:  # gets likes
        statement = select(post_like).where(post_like.person_id == person_id)
        likes = session.exec(statement)
    return JSONResponse(content={"likes": likes})


@app.post("/api/votes")
async def get_votes(request: Request):
    data = await request.json()
    post_url = data.get("post_url")
    comment = data.get("comment")
    print(f"Getting post: {post_url}")

    if not post_url:
        return JSONResponse(content={"error": "Post ID is required"}, status_code=400)

    if comment is True:
        like_type = "comment"
    else:
        like_type = "post"
    parsed = urlparse(post_url)
    post_instance = parsed.netloc
    original_post_id = parsed.path.rsplit("/", 1)[-1]

    # get the original post URL from OP's instance (resolve_object can't resolve stuff retrieved via non-poster instances)
    resolve1_url = f"https://{post_instance}/api/v3/{like_type}"
    async with app.state.http.get(
        resolve1_url, params={"id": original_post_id}
    ) as op_resolve_response:
        op_resolve_response.raise_for_status()
        op_data = await op_resolve_response.json()
        if comment is True:
            op_post_url = op_data["comment_view"]["comment"]["ap_id"]
        else:
            op_post_url = op_data["post_view"]["post"]["ap_id"]

    # Resolve the federated object into a post ID
    resolve2_url = f"{lemmy_instance}/api/v3/resolve_object"
    async with app.state.http.get(
        resolve2_url, params={"q": op_post_url}
    ) as resolve_response:
        resolve_response.raise_for_status()
        data = await resolve_response.json()
        if comment is True:
            post_id = data["comment"]["comment"]["id"]
        else:
            post_id = data["post"]["post"]["id"]

    votes = []
    page = 1
    per_page = 50  # Must be smaller than 50 due to Lemmy's limits

    while True:
        likes_url = f"{lemmy_instance}/api/v3/{like_type}/like/list?{like_type}_id={post_id}&page={page}&limit={per_page}"

        headers = {"Authorization": f"Bearer {app.state.auth_token}"}

        async with app.state.http.get(likes_url, headers=headers) as likes_response:
            if likes_response.status != 200:
                text = await likes_response.text()
                return JSONResponse(
                    content={"error": f"Failed to retrieve {like_type} likes: {text}"},
                    status_code=likes_response.status,
                )

            likes_data = await likes_response.json()

        post_likes = likes_data.get(f"{like_type}_likes")

        if not post_likes:
            break

        for vote in post_likes:
            user = vote["creator"]["name"]
            actor_id = vote["creator"]["actor_id"]
            score = vote["score"]

            # Extract instance from actor_id
            parsed_url = urlparse(actor_id)
            instance_domain = parsed_url.netloc

            votes.append({"user": user, "instance": instance_domain, "vote": score})

        page += 1

    return JSONResponse(content={"votes": votes})
