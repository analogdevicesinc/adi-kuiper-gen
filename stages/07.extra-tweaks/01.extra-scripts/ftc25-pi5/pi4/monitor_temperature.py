#!/usr/bin/env python3
"""
🌡️ IIO Temperature Monitor
Monitors local or remote temperature with automatic mode detection
"""
import iio
import time
import sys
from collections import deque


class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"

    COOL = "\033[94m"  # Blue
    NORMAL = "\033[92m"  # Green
    WARM = "\033[93m"  # Yellow
    HOT = "\033[91m"  # Red
    CRITICAL = "\033[95m"  # Magenta

    HEADER = "\033[96m"  # Cyan
    DIM = "\033[2m"  # Dim
    NETWORK = "\033[93m"  # Yellow for network indicators


class Thermometer:
    """Network-transparent temperature visualization using IIO"""

    def __init__(self, history_size=50):
        """Initialize IIO context and temperature sensor"""

        print(f"{Colors.HEADER}🔧 Initializing IIO context...{Colors.RESET}")

        try:
            # ========================================================================
            # EXERCISE: Change this ONE line for remote monitoring!
            # ========================================================================
            # For LOCAL monitoring (RPi5 monitors itself):
            #     ctx = iio.Context()
            #
            # For REMOTE monitoring (RPi5 monitors RPi4 at 169.254.35.68):
            #     ctx = iio.Context("ip:169.254.35.68")
            # ========================================================================

            # Change the line below
            ctx = iio.Context()

            # ========================================================================

            self.ctx = ctx

        except Exception as e:
            print(f"{Colors.HOT}Connection failed: {e}{Colors.RESET}")
            print(f"\n{Colors.BOLD}Troubleshooting:{Colors.RESET}")
            print(f"  1. For local: Check if IIO devices exist: iio_info")
            print(f"  2. For remote: Verify target is reachable: ping <IP>")
            print(
                f"  3. For remote: Ensure iiod is running: sudo systemctl status iiod"
            )
            print(f"  4. Try manually: iio_info -n ip:<IP>")
            sys.exit(1)

        self.backend_uri = self.ctx.attrs.get("uri", "unknown")
        self.is_local = self.backend_uri == "local:"
        self.is_remote = self.backend_uri.startswith("ip:")

        if self.is_remote:
            self.remote_ip = self.backend_uri.replace("ip:", "")
        else:
            self.remote_ip = None

        self.backend_desc = self.ctx.attrs.get("local,kernel", "unknown")

        if self.is_local:
            print(
                f"{Colors.NORMAL}Mode: {Colors.BOLD}Local{Colors.RESET} - monitoring this system"
            )
        elif self.is_remote:
            print(
                f"{Colors.NETWORK}Mode: {Colors.BOLD}Remote{Colors.RESET} - monitoring {self.remote_ip}"
            )
        else:
            print(f"{Colors.DIM}Mode: {self.backend_uri}{Colors.RESET}")
        print()

        try:
            self.cpu_thermal = self.ctx.find_device("cpu_thermal")
            self.temp_channel = self.cpu_thermal.find_channel("temp1")
        except Exception as e:
            print(f"{Colors.HOT}Could not find cpu_thermal device: {e}{Colors.RESET}")
            print(f"\n{Colors.BOLD}Available IIO devices:{Colors.RESET}")
            for dev in self.ctx.devices:
                print(f"  - {dev.name}")
            print(
                f"\n{Colors.DIM}Note: Not all boards have cpu_thermal. Try another device name.{Colors.RESET}"
            )
            sys.exit(1)

        self.history = deque(maxlen=history_size)
        self.history_size = history_size

        self.min_temp = float("inf")
        self.max_temp = float("-inf")
        self.read_errors = 0

    def get_temperature(self):
        """Read CPU temperature in Celsius"""
        try:
            raw = int(self.temp_channel.attrs["input"].value)
            self.read_errors = 0
            return raw / 1000.0
        except Exception as e:
            self.read_errors += 1
            raise Exception(f"Read error: {e}")

    def get_temp_color(self, temp):
        """Return color based on temperature zones"""
        if temp < 45:
            return Colors.COOL
        elif temp < 55:
            return Colors.NORMAL
        elif temp < 70:
            return Colors.WARM
        elif temp < 80:
            return Colors.HOT
        else:
            return Colors.CRITICAL

    def get_temp_zone(self, temp):
        """Return temperature zone name"""
        if temp < 45:
            return "Cool", Colors.COOL
        elif temp < 55:
            return "Normal", Colors.NORMAL
        elif temp < 70:
            return "Warm", Colors.WARM
        elif temp < 80:
            return "Hot", Colors.HOT
        else:
            return "Critical", Colors.CRITICAL

    def draw_thermometer_bar(self, temp, width=40):
        """Draw a horizontal thermometer bar"""
        min_temp = 0
        max_temp = 100

        percent = (temp - min_temp) / (max_temp - min_temp)
        filled = int(width * percent)

        bar = ""
        for i in range(width):
            if i < filled:
                if i < width * 0.45:
                    bar += f"{Colors.COOL}█{Colors.RESET}"
                elif i < width * 0.55:
                    bar += f"{Colors.NORMAL}█{Colors.RESET}"
                elif i < width * 0.70:
                    bar += f"{Colors.WARM}█{Colors.RESET}"
                elif i < width * 0.80:
                    bar += f"{Colors.HOT}█{Colors.RESET}"
                else:
                    bar += f"{Colors.CRITICAL}█{Colors.RESET}"
            else:
                bar += f"{Colors.DIM}░{Colors.RESET}"

        return bar

    def draw_sparkline(self):
        """Draw a mini sparkline of temperature history"""
        if len(self.history) < 2:
            return "Collecting data..."

        blocks = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

        min_val = min(self.history)
        max_val = max(self.history)
        range_val = max_val - min_val if max_val != min_val else 1

        sparkline = ""
        for temp in self.history:
            normalized = int(((temp - min_val) / range_val) * (len(blocks) - 1))
            color = self.get_temp_color(temp)
            sparkline += f"{color}{blocks[normalized]}{Colors.RESET}"

        return sparkline

    def draw_gauge(self, temp, width=50):
        """Draw a semicircular gauge-style indicator"""
        marks = "├" + "─" * (width - 2) + "┤"

        percent = temp / 100.0
        needle_pos = int(width * percent)

        needle = " " * needle_pos + "▼"

        zones = ""
        for i in range(width):
            pos_percent = i / width
            if pos_percent < 0.45:
                zones += f"{Colors.COOL}│{Colors.RESET}"
            elif pos_percent < 0.55:
                zones += f"{Colors.NORMAL}│{Colors.RESET}"
            elif pos_percent < 0.70:
                zones += f"{Colors.WARM}│{Colors.RESET}"
            elif pos_percent < 0.80:
                zones += f"{Colors.HOT}│{Colors.RESET}"
            else:
                zones += f"{Colors.CRITICAL}│{Colors.RESET}"

        return f"{marks}\n{zones}\n{needle}"

    def get_header_text(self):
        """Generate dynamic header based on mode"""
        if self.is_local:
            return "IIO Temperature Monitor - Local System"
        elif self.is_remote:
            return f"Remote IIO Temperature Monitor - {self.remote_ip}"
        else:
            return f"IIO Temperature Monitor - {self.backend_uri}"

    def display(self):
        """Main display loop with all visualizations"""

        try:
            while True:
                print("\033[H\033[J", end="")

                try:
                    temp = self.get_temperature()

                    self.min_temp = min(self.min_temp, temp)
                    self.max_temp = max(self.max_temp, temp)
                    self.history.append(temp)

                    avg_temp = (
                        sum(self.history) / len(self.history) if self.history else temp
                    )

                    zone_name, zone_color = self.get_temp_zone(temp)

                    header_text = self.get_header_text()
                    header_width = 64
                    padding = (header_width - len(header_text) + 10) // 2

                    print(f"{Colors.HEADER}{Colors.BOLD}╔{'═' * header_width}╗")
                    print(
                        f"║{' ' * padding}{header_text}{' ' * (header_width - padding - len(header_text))}║"
                    )
                    print(f"╚{'═' * header_width}╝{Colors.RESET}\n")

                    if self.is_remote:
                        print(f"{Colors.NETWORK}Network Connection:{Colors.RESET}")
                        print(
                            f"  Target IP: {Colors.BOLD}{self.remote_ip}{Colors.RESET}"
                        )
                        print(f"  Status: {Colors.NORMAL}Connected{Colors.RESET}")
                        print(
                            f"  Remote Kernel: {Colors.DIM}{self.backend_desc}{Colors.RESET}\n"
                        )

                    color = self.get_temp_color(temp)
                    print(f"{Colors.BOLD}Current Temperature:{Colors.RESET}")
                    print(
                        f"{color}{Colors.BOLD}     {temp:6.2f}°C {Colors.RESET}  {zone_color}{zone_name}{Colors.RESET}\n"
                    )

                    print(f"{Colors.BOLD}Temperature Bar:{Colors.RESET}")
                    bar = self.draw_thermometer_bar(temp, width=50)
                    print(f"  0°C {bar} 100°C\n")

                    print(f"{Colors.BOLD}Gauge View:{Colors.RESET}")
                    gauge = self.draw_gauge(temp, width=50)
                    print(f"{gauge}\n")

                    print(f"{Colors.BOLD}Statistics:{Colors.RESET}")
                    print(
                        f"  Min: {Colors.COOL}{self.min_temp:5.2f}°C{Colors.RESET}  ",
                        end="",
                    )
                    print(
                        f"Max: {Colors.HOT}{self.max_temp:5.2f}°C{Colors.RESET}  ",
                        end="",
                    )
                    print(f"Avg: {Colors.NORMAL}{avg_temp:5.2f}°C{Colors.RESET}\n")

                    print(
                        f"{Colors.BOLD}Temperature Trend (last {len(self.history)} readings):{Colors.RESET}"
                    )
                    sparkline = self.draw_sparkline()
                    print(f"  {sparkline}\n")

                    print(f"{Colors.BOLD}Temperature Zones:{Colors.RESET}")
                    print(f"  {Colors.COOL}● Cool{Colors.RESET} (<45°C)  ", end="")
                    print(f"{Colors.NORMAL}● Normal{Colors.RESET} (45-55°C)  ", end="")
                    print(f"{Colors.WARM}● Warm{Colors.RESET} (55-70°C)  ", end="")
                    print(f"{Colors.HOT}● Hot{Colors.RESET} (70-80°C)  ", end="")
                    print(f"{Colors.CRITICAL}● Critical{Colors.RESET} (>80°C)\n")

                    print(
                        f"{Colors.DIM}Press CTRL+C to stop | Refresh: 0.5s | Device: cpu_thermal{Colors.RESET}"
                    )

                except Exception as e:
                    print(f"{Colors.HOT}Error reading temperature: {e}{Colors.RESET}")
                    print(f"{Colors.DIM}Retrying in 2 seconds...{Colors.RESET}")
                    time.sleep(2)
                    continue

                time.sleep(0.5)

        except KeyboardInterrupt:
            print(f"\n\n{Colors.BOLD}Monitoring stopped.{Colors.RESET}")

            print(f"\n{Colors.BOLD}Session Statistics:{Colors.RESET}")
            if self.is_remote:
                print(
                    f"Mode: {Colors.NETWORK}Remote (monitored {self.remote_ip}){Colors.RESET}"
                )
            else:
                print(
                    f"Mode: {Colors.NORMAL}Local (monitored this system){Colors.RESET}"
                )

            print(f"Duration: {len(self.history) * 0.5:.1f} seconds")
            print(f"Min temperature: {self.min_temp:.2f}°C")
            print(f"Max temperature: {self.max_temp:.2f}°C")

            if len(self.history) > 0:
                print(f"Avg temperature: {sum(self.history)/len(self.history):.2f}°C")
                print(f"Temperature range: {self.max_temp - self.min_temp:.2f}°C")

            if self.read_errors > 0:
                print(f"Read errors: {self.read_errors}")
            print()


def main():
    """Run the temperature monitor"""
    try:
        monitor = Thermometer(history_size=60)
        monitor.display()
    except Exception as e:
        print(f"{Colors.HOT}Fatal error: {e}{Colors.RESET}")
        sys.exit(1)


if __name__ == "__main__":
    main()
