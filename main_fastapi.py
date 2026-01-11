import asyncio
import uvicorn
from fastapi import FastAPI

app = FastAPI()

def fibonacci(n: int) -> int:
    """CPU-intensive recursive Fibonacci calculation"""
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

@app.get("/io/{item_id}")
async def io_bound(item_id: int):
    """Szenario B: I/O-Bound - simulierte Datenbankabfrage (100ms)"""
    await asyncio.sleep(0.1)
    return {"item_id": item_id, "framework": "FastAPI", "scenario": "I/O-Bound", "status": "success"}

@app.get("/cpu/{n}")
async def cpu_bound(n: int):
    """Szenario A: CPU-Bound - rechenintensive Fibonacci-Berechnung"""
    result = fibonacci(n)
    return {"n": n, "fibonacci": result, "framework": "FastAPI", "scenario": "CPU-Bound", "status": "success"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
