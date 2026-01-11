import asyncio
import uvicorn
from fastapi import FastAPI

app = FastAPI()

@app.get("/items/{item_id}")
async def read_item(item_id: int):
    # Simulate I/O operation (e.g., DB query)
    await asyncio.sleep(0.1)
    return {"item_id": item_id, "framework": "FastAPI", "status": "success"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
