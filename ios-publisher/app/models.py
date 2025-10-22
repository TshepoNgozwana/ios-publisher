from pydantic import BaseModel

class IOSMetadata(BaseModel):
    name: str
    bundle_id: str
    version: str
    release_notes: str

class StatusResponse(BaseModel):
    bundle_id: str
    build_status: str
    review_status: str
