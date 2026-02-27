#!/usr/bin/env python3
"""
BLE Connection Test — SleepyDrive

Starts the BLE GATT server and sends alternating WARNING/DANGER
notifications every 30 seconds. Use this to verify your phone can
connect and receive alerts.

PHONE SETUP:
  1. Run this script on the Jetson:  sudo python3 ble_test.py
  2. Open the Flutter app (or nRF Connect) on your phone
  3. Tap the Bluetooth icon → you should see "SleepyDrive"
  4. Tap Connect → you should see alert notifications every 30 seconds

Usage:
    sudo python3 ble_test.py
"""

import sys
import time
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s │ %(levelname)-7s │ %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
log = logging.getLogger("ble_test")


def main():
    print()
    print("=" * 56)
    print("  🔵 BLE Connection Test — SleepyDrive")
    print("=" * 56)
    print()
    print("  📱 On your phone:")
    print("     1. Open the SleepyDrive Flutter app")
    print("        (or nRF Connect for testing)")
    print("     2. Tap the Bluetooth icon")
    print("     3. Find 'SleepyDrive' → Connect")
    print("     4. You should see alerts every 30 seconds")
    print()
    print("  Ctrl+C to stop")
    print("=" * 56)
    print()

    # Start BLE server
    log.info("Starting BLE GATT server...")
    try:
        from ble_notifier import BLENotifier
        notifier = BLENotifier()
        notifier.start()
    except Exception as e:
        log.error("BLE failed to start: %s", e)
        log.error("Make sure you're running with sudo!")
        sys.exit(1)

    log.info("✅ BLE server is running — device name: 'SleepyDrive'")
    log.info("Waiting for phone connection...")
    print()

    # Send test notifications every 30 seconds
    count = 0
    try:
        while True:
            time.sleep(30)
            count += 1

            if count % 2 == 1:
                level = 1  # WARNING
                msg = f"⚠️ Sleep Warning #{count} — driver showing signs of drowsiness"
            else:
                level = 2  # DANGER
                msg = f"🚨 Danger #{count} — driver is falling asleep! Pull over now!"

            notifier.send_alert(level, msg)
            log.info("📤 Sent: [%s] %s",
                     "WARNING" if level == 1 else "DANGER", msg)

    except KeyboardInterrupt:
        print()
        log.info("Stopping BLE server...")
        notifier.stop()
        log.info("Done! 👋")


if __name__ == "__main__":
    main()
