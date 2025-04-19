
import aiohttp
import asyncio

async def post_request():
    async with aiohttp.ClientSession() as session:
        response = await session.post(url="https://httpbin.org/post",
                                      data={"key": "value"},
                                      headers={"Content-Type": "application/json"})
        print(await response.json())

asyncio.run(post_request())
