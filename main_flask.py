import time
from flask import Flask, jsonify

app = Flask(__name__)

def fibonacci(n: int) -> int:
    """CPU-intensive recursive Fibonacci calculation"""
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

@app.route("/io/<int:item_id>", methods=["GET"])
def io_bound(item_id):
    """Szenario B: I/O-Bound - simulierte Datenbankabfrage (100ms)"""
    time.sleep(0.1)
    return jsonify({"item_id": item_id, "framework": "Flask", "scenario": "I/O-Bound", "status": "success"})

@app.route("/cpu/<int:n>", methods=["GET"])
def cpu_bound(n):
    """Szenario A: CPU-Bound - rechenintensive Fibonacci-Berechnung"""
    result = fibonacci(n)
    return jsonify({"n": n, "fibonacci": result, "framework": "Flask", "scenario": "CPU-Bound", "status": "success"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001)
