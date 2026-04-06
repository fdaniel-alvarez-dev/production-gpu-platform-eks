from fastapi import FastAPI
from pydantic import BaseModel
import time

app = FastAPI(title="inference-gateway", version="1.0.0")

class InferenceRequest(BaseModel):
    prompt: str

@app.get("/healthz")
def healthz() -> dict:
    return {"status": "ok"}

@app.get("/ready")
def ready() -> dict:
    return {"status": "ready"}

@app.post("/infer")
def infer(request: InferenceRequest) -> dict:
    started = time.time()
    # This is intentionally simple. The platform repo demonstrates the infrastructure path,
    # not the model implementation itself.
    output = request.prompt.upper()
    latency_ms = int((time.time() - started) * 1000)
    return {
        "output": output,
        "latency_ms": latency_ms,
        "model": "baseline-serving"
    }
