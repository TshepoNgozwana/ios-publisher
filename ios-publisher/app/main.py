from fastapi import FastAPI, UploadFile, Form
from pydantic import BaseModel
from pathlib import Path
import json
from app.cockpit import log_event

app = FastAPI(title="iOS Publisher API")

DATA_PATH = Path("data/cockpit/ios_publisher.jsonl")
DATA_PATH.parent.mkdir(parents=True, exist_ok=True)

# ──────────────────────────────────────────────────────────────
# Models
# ──────────────────────────────────────────────────────────────
class Metadata(BaseModel):
    name: str
    bundle_id: str
    version: str
    release_notes: str

class TestFlightData(BaseModel):
    beta_info: str
    testers: list[str]
    submit_external: bool

# ──────────────────────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────────────────────
@app.post("/ios/prepare")
async def prepare_app(meta: Metadata):
    """Save app metadata"""
    log_event("ios.prepare", meta.dict())
    return {"status": "ok", "action": "prepare", "metadata": meta.dict()}

@app.post("/ios/upload")
async def upload_app(file: UploadFile | None = None, url: str | None = Form(None)):
    """Upload .ipa or from URL (simulated here)"""
    payload = {"file": file.filename if file else None, "url": url}
    log_event("ios.upload", payload)
    return {"status": "ok", "action": "upload", "source": payload}

@app.post("/ios/testflight")
async def testflight_submit(data: TestFlightData):
    """Simulate TestFlight submission"""
    log_event("ios.testflight", data.dict())
    return {"status": "ok", "action": "testflight", "submitted": True}

@app.post("/ios/submit")
async def submit_for_review(bundle_id: str = Form(...), notes: str = Form(...)):
    """Simulate submission for App Review"""
    payload = {"bundle_id": bundle_id, "notes": notes}
    log_event("ios.submit", payload)
    return {"status": "ok", "action": "submit", "bundle_id": bundle_id}

@app.get("/ios/status/{bundle_id}")
async def get_status(bundle_id: str):
    """Fetch mock build status"""
    # Example placeholder
    status = "pending"
    payload = {"bundle_id": bundle_id, "status": status}
    log_event("ios.status", payload)
    return payload

# ──────────────────────────────────────────────────────────────
# Root
# ──────────────────────────────────────────────────────────────
@app.get("/")
async def root():
    return {"message": "iOS Publisher API running"}
