#!/usr/bin/env python3
"""
Safe CPU Stress Test for RPi5 with Temperature Protection
Automatically stops when temperature exceeds safe threshold
"""
import iio
import multiprocessing
import time
import sys

MAX_SAFE_TEMP = 80.0  # Celsius


def stress_cpu():
    """CPU-intensive workload"""
    while True:
        _ = sum(i * i for i in range(10000))


def get_temperature(ctx, device_name="cpu_thermal"):
    """Read CPU temperature in Celsius"""
    try:
        cpu_thermal = ctx.find_device(device_name)
        temp_channel = cpu_thermal.find_channel("temp1")
        raw = int(temp_channel.attrs["input"].value)
        return raw / 1000.0
    except Exception as e:
        print(f"Error reading temperature: {e}")
        sys.exit(1)


def main():
    """Run safe stress test with temperature monitoring"""
    try:
        ctx = iio.Context()
    except Exception as e:
        print(f"Failed to initialize IIO: {e}")
        sys.exit(1)

    start_temp = get_temperature(ctx)

    print(f"RPi5 Safe Stress Test")
    print(f"Starting temperature: {start_temp:.1f}°C")
    print(f"Safety limit: {MAX_SAFE_TEMP:.1f}°C")
    print(f"Running... (Press CTRL+C to stop manually)\n")

    cpu_count = multiprocessing.cpu_count()
    workers = []
    for _ in range(cpu_count):
        p = multiprocessing.Process(target=stress_cpu)
        p.start()
        workers.append(p)

    try:
        while True:
            temp = get_temperature(ctx)

            if temp >= MAX_SAFE_TEMP:
                print(f"Safety limit reached: {temp:.1f}°C")
                print(f"Stopping stress test to protect hardware.")
                break

            time.sleep(0.5)

    except KeyboardInterrupt:
        print(f"\nStopped by user")

    finally:
        for p in workers:
            p.terminate()
            p.join()

        final_temp = get_temperature(ctx)
        temp_rise = final_temp - start_temp

        print(f"\nStress test completed")
        print(f"Final temperature: {final_temp:.1f}°C")
        print(f"Temperature rise: {temp_rise:.1f}°C")


if __name__ == "__main__":
    main()
