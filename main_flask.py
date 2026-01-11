import time
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/items/<int:item_id>", methods=["GET"])
def read_item(item_id):
    # Simulate blocking I/O operation
    time.sleep(0.1)
    return jsonify({"item_id": item_id, "framework": "Flask", "status": "success"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001)
