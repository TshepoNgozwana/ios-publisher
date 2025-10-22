# 🍏 iOS Publisher — FastAPI + Fastlane Wrapper

A lightweight FastAPI microservice that connects to Apple App Store Connect via `fastlane`.  
It prepares, uploads, and submits iOS apps for TestFlight and App Store Review — while logging all activity into a local cockpit file.

---

## 🚀 Features
- `POST /ios/prepare` — store metadata (name, bundle ID, version, release notes)
- `POST /ios/upload` — simulate upload via file or URL
- `POST /ios/testflight` — mock submission to TestFlight testers
- `POST /ios/submit` — simulate App Store review submission
- `GET /ios/status/{bundle_id}` — retrieve mock submission/build status
- Logs every event → `data/cockpit/ios_publisher.jsonl`

---

## ⚙️ Environment Variables

Define these in `.env.local` or `.env.example` (to be filled when integrating with Fastlane):

| Variable | Description |
|-----------|--------------|
| `ASC_KEY_ID` | Apple API Key ID |
| `ASC_ISSUER_ID` | Apple Issuer ID |
| `ASC_PRIVATE_KEY` | Private .p8 key contents |
| `TEAM_ID` | Apple Developer Team ID |
| `ITC_TEAM_ID` | iTunes Connect Team ID |
| `APPLE_APP_SPECIFIC_PASSWORD` | Optional for iTunes uploads |

---

## 🧱 Folder Layout
ios-publisher/
app/
main.py
models.py
asc.py
cockpit.py
lanes/
Fastfile
Appfile
data/
cockpit/ios_publisher.jsonl
.env.example
requirements.txt
README.md

---

## 🧩 Quick Start

```bash
# Clone or init repo
git clone <repo-url> && cd ios-publisher

# Create virtual environment
python -m venv .venv
.venv\Scripts\activate   # Windows
# or source .venv/bin/activate  # mac/Linux

# Install dependencies
pip install -r requirements.txt

# Run API
uvicorn app.main:app --reload --port 8089
