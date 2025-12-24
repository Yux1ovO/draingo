import time
from smbus2 import SMBus

# ADS1x15 registers
_REG_CONVERSION = 0x00
_REG_CONFIG     = 0x01

# MUX for single-ended A0..A3
_MUX_SINGLE = {
    0: 0b100,  # AIN0 vs GND
    1: 0b101,
    2: 0b110,
    3: 0b111,
}

# PGA (gain) -> full-scale voltage
# gain here matches "PGA bits" meaning:
# 2/3=6.144V, 1=4.096V, 2=2.048V, 4=1.024V, 8=0.512V, 16=0.256V
_PGA_BITS = {  # gain: bits
    2/3: 0b000,
    1:   0b001,
    2:   0b010,
    4:   0b011,
    8:   0b100,
    16:  0b101,
}

_FSR_VOLTS = {  # gain: full-scale range volts
    2/3: 6.144,
    1:   4.096,
    2:   2.048,
    4:   1.024,
    8:   0.512,
    16:  0.256,
}

class ADS1x15Reader:
    """
    Pure I2C ADS1115-style reader (no Blinka, no RPi.GPIO).
    - address: usually 0x48
    - channel: 0..3 (A0..A3)
    - gain: 1,2,4,8,16, or 2/3
    - i2c_bus: 1 on Raspberry Pi
    """

    def __init__(self, address: int = 0x48, channel: int = 0, gain=1, i2c_bus: int = 1, sps: int = 128):
        if channel not in _MUX_SINGLE:
            raise ValueError("ADS channel must be 0..3 (A0..A3)")
        if gain not in _PGA_BITS:
            raise ValueError("gain must be one of: 2/3, 1, 2, 4, 8, 16")

        self.address = address
        self.channel = channel
        self.gain = gain
        self.fsr = _FSR_VOLTS[gain]
        self.bus = SMBus(i2c_bus)

        # Data rate bits (ADS1115). We'll support common values.
        # 8,16,32,64,128,250,475,860
        self._dr_bits = {
            8:   0b000,
            16:  0b001,
            32:  0b010,
            64:  0b011,
            128: 0b100,
            250: 0b101,
            475: 0b110,
            860: 0b111,
        }.get(sps, 0b100)  # default 128 SPS

    def _write_config(self):
        # Build config for single-shot conversion
        os_bit   = 1  # start single conversion
        mux_bits = _MUX_SINGLE[self.channel]
        pga_bits = _PGA_BITS[self.gain]
        mode     = 1  # single-shot
        dr_bits  = self._dr_bits

        # Disable comparator: COMP_QUE = 11
        comp_que = 0b11
        comp_lat = 0
        comp_pol = 0
        comp_mode = 0

        config = (
            (os_bit   << 15) |
            (mux_bits << 12) |
            (pga_bits << 9)  |
            (mode     << 8)  |
            (dr_bits  << 5)  |
            (comp_mode << 4) |
            (comp_pol  << 3) |
            (comp_lat  << 2) |
            (comp_que)
        )

        hi = (config >> 8) & 0xFF
        lo = config & 0xFF
        self.bus.write_i2c_block_data(self.address, _REG_CONFIG, [hi, lo])

    def read_raw(self) -> int:
        self._write_config()

        time.sleep(0.01)

        data = self.bus.read_i2c_block_data(self.address, _REG_CONVERSION, 2)
        raw = (data[0] << 8) | data[1]

        if raw & 0x8000:
            raw -= 1 << 16
        return int(raw)

    def read_voltage(self) -> float:
        # ADS1115 is 16-bit signed; LSB = fsr / 32768
        raw = self.read_raw()
        return (raw / 32768.0) * self.fsr

    def close(self):
        try:
            self.bus.close()
        except Exception:
            pass


