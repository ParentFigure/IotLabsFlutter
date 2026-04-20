from uuid import uuid4

from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, EmailStr
from pymysql import IntegrityError

import db

app = FastAPI(title='smart-lamp-api')
security = HTTPBearer()
db.initialize()


class AuthPayload(BaseModel):
    email: EmailStr
    password: str


class UserPayload(AuthPayload):
    name: str


class LampPayload(BaseModel):
    lampState: dict


def _extract_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    if credentials.scheme.lower() != 'bearer':
        raise HTTPException(status_code=401, detail='Invalid auth scheme.')
    return credentials.credentials


def _public_user(user: dict) -> dict:
    return {'email': user['email'], 'password': user['password'], 'name': user['name']}


def _current_user(token: str) -> dict:
    user = db.fetch_user_by_token(token)
    if user is None:
        raise HTTPException(status_code=401, detail='Invalid token.')
    return user


@app.get('/health')
def health() -> dict:
    return {'status': 'ok'}


@app.post('/auth/register')
def register(payload: UserPayload) -> dict:
    if db.fetch_user_by_email(payload.email):
        raise HTTPException(status_code=409, detail='Email already exists.')
    try:
        user = db.create_user(payload.name, payload.email, payload.password)
    except IntegrityError as exc:
        raise HTTPException(status_code=409, detail='Email already exists.') from exc
    token = uuid4().hex
    db.replace_session_email(token, user['id'])
    return {'access_token': token, 'token_type': 'bearer', 'user': _public_user(user)}


@app.post('/auth/login')
def login(payload: AuthPayload) -> dict:
    user = db.fetch_user_by_email(payload.email)
    if user is None or user['password'] != payload.password:
        raise HTTPException(status_code=401, detail='Invalid credentials.')
    token = uuid4().hex
    db.replace_session_email(token, user['id'])
    return {'access_token': token, 'token_type': 'bearer', 'user': _public_user(user)}


@app.get('/auth/me')
def me(token: str = Depends(_extract_token)) -> dict:
    return {'user': _public_user(_current_user(token))}


@app.put('/auth/me')
def update_me(payload: UserPayload, token: str = Depends(_extract_token)) -> dict:
    current = _current_user(token)
    existing = db.fetch_user_by_email(payload.email)
    if existing and existing['id'] != current['id']:
        raise HTTPException(status_code=409, detail='Email already exists.')
    try:
        user = db.update_user(current['id'], payload.name, payload.email, payload.password)
    except IntegrityError as exc:
        raise HTTPException(status_code=409, detail='Email already exists.') from exc
    db.replace_session_email(token, current['id'])
    return {'user': _public_user(user)}


@app.get('/lamp/state')
def get_lamp_state() -> dict:
    return {'lampState': db.fetch_lamp_state()}


@app.put('/lamp/state')
def put_lamp_state(payload: LampPayload) -> dict:
    return {'lampState': db.save_lamp_state(payload.lampState)}
