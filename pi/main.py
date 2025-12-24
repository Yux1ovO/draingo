import logging
import os
import time

from dotenv import load_dotenv

from sensor_ads1x15 import ADS1x15Reader
from supabase_uploader import get_supabase, upload_reading


def clamp(x, lo, hi):
    return max(lo, min(hi, x))


def raw_to_depth_cm(raw: int, dry_raw: int, wet_raw: int, max_depth_cm: float) -> float:
    """
    Map raw ADC value to depth_cm using linear interpolation between dry_raw and wet_raw.
    """
    if wet_raw == dry_raw:
        return 0.0
    t = (raw - dry_raw) / float(wet_raw - dry_raw)
    t = clamp(t, 0.0, 1.0)
    return t * max_depth_cm


def setup_logging():
    level = os.getenv("LOG_LEVEL", "INFO").upper()
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s"
    )
    logging.getLogger("httpx").setLevel(logging.WARNING)


def main():
    load_dotenv()
    setup_logging()
    log = logging.getLogger("draingo")

    table = os.getenv("TABLE_NAME", "water_readings")
    device_id = os.getenv("DEVICE_ID", "draingo-pi-001")
    poll = float(os.getenv("POLL_SECONDS", "5"))

    # Calibration
    dry_raw = int(os.getenv("DRY_RAW", "200"))
    wet_raw = int(os.getenv("WET_RAW", "800"))
    max_depth_cm = float(os.getenv("MAX_DEPTH_CM", "30"))

    lat = 31.24
    lng = 121.44

    # I2C ADC config (defaults: address 0x48, channel A0)
    ads_address = int(os.getenv("ADS_ADDRESS", "0x48"), 16)
    ads_channel = int(os.getenv("ADS_CHANNEL", "0"))
    ads_gain = int(os.getenv("ADS_GAIN", "1"))

    sb = get_supabase()
    adc = ADS1x15Reader(address=ads_address, channel=ads_channel, gain=ads_gain)

    log.info(
        "Started. table=%s device_id=%s poll=%.1fs ads_addr=0x%02x ads_ch=%d",
        table, device_id, poll, ads_address, ads_channel
    )

    while True:
        raw = adc.read_raw()
        volts = (raw / 32768.0) * adc.fsr
        depth_cm = round(raw_to_depth_cm(raw, dry_raw, wet_raw, max_depth_cm), 2)

        payload = {
            "device_id": device_id,
            "depth_cm": float(depth_cm),
            "lat": float(lat),
            "lng": float(lng),
            "raw": {
                "adc_raw": int(raw),
                "voltage": float(volts),
                "dry_raw": int(dry_raw),
                "wet_raw": int(wet_raw),
                "max_depth_cm": float(max_depth_cm),
                "adc_type": "ads1x15",
                "ads_addr": hex(ads_address),
                "ads_channel": int(ads_channel),
            }
        }

        log.info("ADC raw=%d volts=%.3f -> depth_cm=%.2f", raw, volts, depth_cm)
        upload_reading(sb, payload, table=table)

        time.sleep(poll)


if __name__ == "__main__":
    main()

