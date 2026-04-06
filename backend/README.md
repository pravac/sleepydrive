# backend folder

Backend now contains:

1. `ble/`: BLE notifier stack for direct Bluetooth alerts.
2. `realtime/`: MQTT uplink + Postgres consumer + WebSocket gateway.

Realtime gateway: install with `pip install -r requirements.txt`, then from `backend/` run `python run_server.py` (or the same under `backend/realtime/`).
