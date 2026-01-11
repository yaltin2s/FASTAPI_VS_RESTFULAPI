#!/bin/bash

# Ensure cleanup on exit
cleanup() {
    echo "Stopping servers..."
    pkill -f "uvicorn main_fastapi:app"
    pkill -f "gunicorn"
}
trap cleanup SIGINT SIGTERM EXIT

# Clear previous results
> results.txt

echo "==========================================="
echo "Starting FastAPI server..."
echo "==========================================="
# Start FastAPI in background
uvicorn main_fastapi:app --host 0.0.0.0 --port 8000 > /dev/null 2>&1 &
PID_FASTAPI=$!
# Wait for server to start
sleep 5

echo "Benchmarking FastAPI..."
echo "FastAPI Results:" >> results.txt
wrk -t4 -c100 -d30s http://localhost:8000/items/123 >> results.txt
echo "FastAPI Benchmark finished."
echo "" >> results.txt

echo "Stopping FastAPI server..."
kill $PID_FASTAPI
sleep 2

echo "==========================================="
echo "Starting Flask server with Gunicorn (4 workers)..."
echo "==========================================="
# Start Flask with Gunicorn in background
gunicorn -w 4 -b 0.0.0.0:8001 main_flask:app > /dev/null 2>&1 &
PID_FLASK=$!
# Wait for server to start
sleep 5

echo "Benchmarking Flask..."
echo "Flask Results:" >> results.txt
wrk -t4 -c100 -d30s http://localhost:8001/items/123 >> results.txt
echo "Flask Benchmark finished."

echo "Stopping Flask server..."
kill $PID_FLASK

echo "==========================================="
echo "All benchmarks completed. Results saved in results.txt."
echo "==========================================="
cat results.txt
