# Lab 5

Flutter app now uses a REST API for auth and lamp state sync.

## What was added

- Python FastAPI server in `server/`
- token based auth
- remote sync for profile and lamp state
- local cache fallback via `SharedPreferences`
- `FutureBuilder` loading on the home screen

## Start backend

```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## Start Flutter app

```bash
flutter pub get
flutter run
```

Android emulator uses `10.0.2.2:8000`, other platforms use `127.0.0.1:8000`.
