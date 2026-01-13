from typing import Optional
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel

class User(BaseModel):
    username: str
    age: int
    email: Optional[str] = None

app = FastAPI()

@app.post("/user")
def create_user(user: User):
    return user

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
