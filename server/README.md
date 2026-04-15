# Smart Lamp API

## Run

```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`
- `PUT /auth/me`
- `GET /lamp/state`
- `PUT /lamp/state`

Flutter app uses bearer token after login and keeps user plus lamp state in
`SharedPreferences`, so the last successful data remains visible offline.
