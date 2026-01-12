#!/bin/bash

# Benchmark-Konfiguration
DURATION="30s"
CONNECTIONS=100
THREADS=4
FIBONACCI_N=30

# Ensure cleanup on exit
cleanup() {
    echo "Stopping servers..."
    pkill -f "uvicorn main_fastapi:app" 2>/dev/null
    pkill -f "gunicorn" 2>/dev/null
}
trap cleanup SIGINT SIGTERM EXIT

# Timestamp für diesen Durchlauf
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "" >> results.txt
echo "############################################################" | tee -a results.txt
echo "# BENCHMARK-DURCHLAUF: ${TIMESTAMP}" | tee -a results.txt
echo "############################################################" | tee -a results.txt
echo "" | tee -a results.txt

echo "============================================================" | tee -a results.txt
echo "BENCHMARK: FastAPI (ASGI) vs Flask (WSGI)" | tee -a results.txt
echo "Konfiguration: ${DURATION} Laufzeit, ${CONNECTIONS} Connections, ${THREADS} Threads" | tee -a results.txt
echo "Fibonacci N=${FIBONACCI_N} für CPU-Bound Tests" | tee -a results.txt
echo "============================================================" | tee -a results.txt
echo "" | tee -a results.txt

# ============================================================
# SZENARIO A: CPU-BOUND (Fibonacci-Berechnung)
# ============================================================
echo "============================================================" | tee -a results.txt
echo "SZENARIO A: CPU-BOUND (Fibonacci-Berechnung)" | tee -a results.txt
echo "============================================================" | tee -a results.txt
echo "" | tee -a results.txt

# FastAPI CPU-Bound
echo "Starting FastAPI server..."
uvicorn main_fastapi:app --host 0.0.0.0 --port 8000 > /dev/null 2>&1 &
PID_FASTAPI=$!
sleep 3

echo "--- FastAPI CPU-Bound ---" | tee -a results.txt
wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency http://localhost:8000/cpu/${FIBONACCI_N} >> results.txt
echo "" | tee -a results.txt

kill $PID_FASTAPI 2>/dev/null
sleep 2

# Flask CPU-Bound
echo "Starting Flask server with Gunicorn (4 workers)..."
gunicorn -w 4 -b 0.0.0.0:8001 main_flask:app > /dev/null 2>&1 &
PID_FLASK=$!
sleep 3

echo "--- Flask CPU-Bound ---" | tee -a results.txt
wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency http://localhost:8001/cpu/${FIBONACCI_N} >> results.txt
echo "" | tee -a results.txt

kill $PID_FLASK 2>/dev/null
sleep 2

# ============================================================
# SZENARIO B: I/O-BOUND (Simulierte Datenbankabfrage 100ms)
# ============================================================
echo "============================================================" | tee -a results.txt
echo "SZENARIO B: I/O-BOUND (Simulierte DB-Abfrage 100ms)" | tee -a results.txt
echo "============================================================" | tee -a results.txt
echo "" | tee -a results.txt

# FastAPI I/O-Bound
echo "Starting FastAPI server..."
uvicorn main_fastapi:app --host 0.0.0.0 --port 8000 > /dev/null 2>&1 &
PID_FASTAPI=$!
sleep 3

echo "--- FastAPI I/O-Bound ---" | tee -a results.txt
wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency http://localhost:8000/io/123 >> results.txt
echo "" | tee -a results.txt

kill $PID_FASTAPI 2>/dev/null
sleep 2

# Flask I/O-Bound
echo "Starting Flask server with Gunicorn (4 workers)..."
gunicorn -w 4 -b 0.0.0.0:8001 main_flask:app > /dev/null 2>&1 &
PID_FLASK=$!
sleep 3

echo "--- Flask I/O-Bound ---" | tee -a results.txt
wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency http://localhost:8001/io/123 >> results.txt
echo "" | tee -a results.txt

kill $PID_FLASK 2>/dev/null

echo "============================================================" | tee -a results.txt
echo "BENCHMARK ABGESCHLOSSEN" | tee -a results.txt
echo "Ergebnisse gespeichert in: results.txt" | tee -a results.txt
echo "============================================================" | tee -a results.txt

cat results.txt
