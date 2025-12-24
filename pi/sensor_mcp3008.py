import spidev

class MCP3008:
    """
    Minimal MCP3008 reader using spidev.
    Returns 10-bit ADC value: 0..1023
    """
    def __init__(self, bus: int = 0, device: int = 0, max_speed_hz: int = 1_000_000):
        self.spi = spidev.SpiDev()
        self.spi.open(bus, device)
        self.spi.max_speed_hz = max_speed_hz

    def read(self, channel: int) -> int:
        if not (0 <= channel <= 7):
            raise ValueError("MCP3008 channel must be 0..7")

        # MCP3008 protocol: start bit, single-ended + channel, then read back 10 bits.
        # tx: [00000001, (1000 + ch)<<4, 00000000]
        tx = [1, (8 + channel) << 4, 0]
        rx = self.spi.xfer2(tx)
        value = ((rx[1] & 0x03) << 8) | rx[2]
        return value

    def close(self):
        self.spi.close()

