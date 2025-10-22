import json
from datetime import datetime, timezone
from pathlib import Path

LOG_FILE = Path("data/cockpit/ios_publisher.jsonl")
LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

def log_event(action: str, payload: dict):
    entry = {
        "ts": datetime.now(timezone.utc).isoformat(),
        "action": action,
        "payload": payload,
    }
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
