# drowsiness_guide

This is the App that will display the nearby rest-stops

## Backend + Realtime Defaults

By default, this app is configured to use the deployed Render backend for both HTTP APIs and websocket alerts:

- `BACKEND_BASE_URL = https://sleepydrive.onrender.com`
- `JETSON_WS_URL = wss://sleepydrive.onrender.com/ws/alerts?replay=0`

This means you can run the Flutter app without a local backend server:

```bash
flutter run
```

## Optional overrides

If you need to point to a different backend (local or another environment), set both values at run time:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=https://<your-backend-domain> \
  --dart-define=JETSON_WS_URL=wss://<your-backend-domain>/ws/alerts?replay=0
```

TODO:
- Display nearby rest stops
- Redirect to Google Maps
- Add weather data

Backloog:
- Add Apple Maps functionality
