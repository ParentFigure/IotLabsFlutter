import json
import os
from contextlib import contextmanager

import pymysql
from pymysql.cursors import DictCursor

DEFAULT_LAMP_STATE = {
    'isLampOn': False,
    'autoMode': True,
    'sensitivity': 80,
    'sensorLux': 18,
    'broker': 'broker.emqx.io',
    'port': 1883,
    'topicPrefix': 'smartlamp/demo',
    'schedules': [
        {'id': '1', 'day': 'Mon', 'time': '06:30', 'action': 'ON'},
        {'id': '2', 'day': 'Mon', 'time': '08:05', 'action': 'OFF'},
        {'id': '3', 'day': 'Fri', 'time': '18:40', 'action': 'ON'},
    ],
}


def _settings(include_db: bool = True) -> dict:
    cfg = {
        'host': os.getenv('MYSQL_HOST', '127.0.0.1'),
        'port': int(os.getenv('MYSQL_PORT', '3306')),
        'user': os.getenv('MYSQL_USER', 'root'),
        'password': os.getenv('MYSQL_PASSWORD', 'root'),
        'cursorclass': DictCursor,
        'autocommit': True,
    }
    if include_db:
        cfg['database'] = os.getenv('MYSQL_DATABASE', 'smart_lamp_lab')
    return cfg


@contextmanager
def connection(include_db: bool = True):
    conn = pymysql.connect(**_settings(include_db=include_db))
    try:
        yield conn
    finally:
        conn.close()


def initialize() -> None:
    db_name = os.getenv('MYSQL_DATABASE', 'smart_lamp_lab')
    with connection(include_db=False) as conn:
        with conn.cursor() as cur:
            cur.execute(f'CREATE DATABASE IF NOT EXISTS `{db_name}`')
    with connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                'CREATE TABLE IF NOT EXISTS users ('
                'id INT AUTO_INCREMENT PRIMARY KEY,'
                'email VARCHAR(255) NOT NULL UNIQUE,'
                'password VARCHAR(255) NOT NULL,'
                'name VARCHAR(255) NOT NULL'
                ')'
            )
            cur.execute(
                'CREATE TABLE IF NOT EXISTS sessions ('
                'token VARCHAR(64) PRIMARY KEY,'
                'user_id INT NOT NULL,'
                'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,'
                'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE'
                ')'
            )
            cur.execute(
                'CREATE TABLE IF NOT EXISTS lamp_state ('
                'id TINYINT PRIMARY KEY,'
                'state_json JSON NOT NULL'
                ')'
            )
            cur.execute('SELECT id FROM lamp_state WHERE id = 1')
            if cur.fetchone() is None:
                cur.execute(
                    'INSERT INTO lamp_state (id, state_json) VALUES (1, %s)',
                    (json.dumps(DEFAULT_LAMP_STATE),),
                )


def fetch_user_by_email(email: str):
    with connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT id, email, password, name FROM users WHERE email=%s', (email,))
        return cur.fetchone()


def create_user(name: str, email: str, password: str) -> dict:
    with connection() as conn, conn.cursor() as cur:
        cur.execute(
            'INSERT INTO users (name, email, password) VALUES (%s, %s, %s)',
            (name, email, password),
        )
        user_id = cur.lastrowid
        return {'id': user_id, 'name': name, 'email': email, 'password': password}


def update_user(user_id: int, name: str, email: str, password: str) -> dict:
    with connection() as conn, conn.cursor() as cur:
        cur.execute(
            'UPDATE users SET name=%s, email=%s, password=%s WHERE id=%s',
            (name, email, password, user_id),
        )
        return {'id': user_id, 'name': name, 'email': email, 'password': password}


def create_session(token: str, user_id: int) -> None:
    with connection() as conn, conn.cursor() as cur:
        cur.execute('INSERT INTO sessions (token, user_id) VALUES (%s, %s)', (token, user_id))


def replace_session_email(token: str, user_id: int) -> None:
    with connection() as conn, conn.cursor() as cur:
        cur.execute('DELETE FROM sessions WHERE user_id=%s', (user_id,))
        cur.execute('REPLACE INTO sessions (token, user_id) VALUES (%s, %s)', (token, user_id))


def fetch_user_by_token(token: str):
    query = (
        'SELECT u.id, u.email, u.password, u.name '
        'FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.token=%s'
    )
    with connection() as conn, conn.cursor() as cur:
        cur.execute(query, (token,))
        return cur.fetchone()


def fetch_lamp_state() -> dict:
    with connection() as conn, conn.cursor() as cur:
        cur.execute('SELECT state_json FROM lamp_state WHERE id = 1')
        row = cur.fetchone()
        return json.loads(row['state_json']) if row else DEFAULT_LAMP_STATE


def save_lamp_state(state: dict) -> dict:
    payload = json.dumps(state)
    with connection() as conn, conn.cursor() as cur:
        cur.execute(
            'UPDATE lamp_state SET state_json=%s WHERE id = 1',
            (payload,),
        )
    return state
