import logging
import os
from supabase import create_client
from postgrest.exceptions import APIError

from dotenv import load_dotenv
load_dotenv()  
log = logging.getLogger("draingo.supabase")

def get_supabase():
    url = os.environ["SUPABASE_URL"]
    key = os.environ["SUPABASE_SERVICE_ROLE_KEY"]  
    log.info("Creating Supabase client for %s", url)
    return create_client(url, key)

def upload_reading(sb, payload: dict, table: str = "water_readings"):
    """
    Payload keys must match DB columns exactly:
    device_id, depth_cm, lat, lng, raw, (optional) measured_at
    """
    log.info("Uploading reading to %s: device_id=%s depth_cm=%s lat=%s lng=%s",
             table, payload.get("device_id"), payload.get("depth_cm"),
             payload.get("lat"), payload.get("lng"))

    try:
        res = sb.table(table).insert(payload).execute()
        log.info("Upload success. Returned rows: %s", len(res.data) if res.data else 0)
        if res.data:
            log.debug("Returned data: %s", res.data)
        return res
    except APIError as e:
        log.error("Supabase insert failed: %s", getattr(e, "args", e))
        raise

