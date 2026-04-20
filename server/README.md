# Smart Lamp API with MySQL

## 1. Create the database in MySQL Workbench

Open MySQL Workbench, connect to your local server, then open and run `schema.sql`.
It creates database `smart_lamp_lab`, tables `users`, `sessions`, `lamp_state`, and default lamp data.

## 2. Configure connection

Defaults are:
- host: `127.0.0.1`
- port: `3306`
- user: `root`
- password: empty
- database: `smart_lamp_lab`

If your MySQL uses other credentials, set environment variables before running:

### PowerShell
```powershell
$env:MYSQL_HOST="127.0.0.1"
$env:MYSQL_PORT="3306"
$env:MYSQL_USER="root"
$env:MYSQL_PASSWORD="your_password"
$env:MYSQL_DATABASE="smart_lamp_lab"
```

## 3. Run the API server

```bash
cd server
python -m venv .venv
```

### Windows PowerShell
```powershell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python init_db.py
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### macOS/Linux
```bash
source .venv/bin/activate
pip install -r requirements.txt
python init_db.py
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## 4. Check data in Workbench

Use these queries in Workbench:

```sql
USE smart_lamp_lab;
SELECT * FROM users;
SELECT * FROM sessions;
SELECT * FROM lamp_state;
```

If you want to see lamp JSON clearly:

```sql
SELECT JSON_PRETTY(state_json) FROM lamp_state WHERE id = 1;
```

## Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`
- `PUT /auth/me`
- `GET /lamp/state`
- `PUT /lamp/state`

Flutter still uses `SharedPreferences` for offline cache, so user data and lamp state remain visible without internet after first sync.
