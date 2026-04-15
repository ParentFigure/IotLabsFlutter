from pathlib import Path
from uuid import uuid4

from fastapi import Depends, FastAPI, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, EmailStr

from storage import JsonStore

store = JsonStore(Path(__file__).parent / 'data' / 'store.json')
app = FastAPI(title='smart-lamp-api')
security = HTTPBearer()


class AuthPayload(BaseModel):
    email: EmailStr
    password: str


class UserPayload(AuthPayload):
    name: str


class LampPayload(BaseModel):
    lampState: dict


def _user_by_token(token: str) -> dict:
    data = store.read()
    email = data['sessions'].get(token)
    if email is None:
        raise HTTPException(status_code=401, detail='Invalid token.')

    for user in data['users']:
        if user['email'] == email:
            return user

    raise HTTPException(status_code=404, detail='User not found.')


def _extract_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    if credentials.scheme.lower() != 'bearer':
        raise HTTPException(status_code=401, detail='Invalid auth scheme.')
    return credentials.credentials


@app.get('/health')
def health() -> dict:
    return {'status': 'ok'}


@app.post('/auth/register')
def register(payload: UserPayload) -> dict:
    data = store.read()
    if any(user['email'] == payload.email for user in data['users']):
        raise HTTPException(status_code=409, detail='Email already exists.')

    user = payload.model_dump()
    data['users'].append(user)

    token = uuid4().hex
    data['sessions'][token] = payload.email

    store.write(data)
    return {
        'access_token': token,
        'token_type': 'bearer',
        'user': user,
    }


@app.post('/auth/login')
def login(payload: AuthPayload) -> dict:
    data = store.read()

    for user in data['users']:
        if user['email'] == payload.email and user['password'] == payload.password:
            token = uuid4().hex
            data['sessions'][token] = payload.email
            store.write(data)
            return {
                'access_token': token,
                'token_type': 'bearer',
                'user': user,
            }

    raise HTTPException(status_code=401, detail='Invalid credentials.')


@app.get('/auth/me')
def me(token: str = Depends(_extract_token)) -> dict:
    return _user_by_token(token)


@app.put('/auth/me')
def update_me(
    payload: UserPayload,
    token: str = Depends(_extract_token),
) -> dict:
    current_user = _user_by_token(token)
    data = store.read()
    updated = payload.model_dump()

    data['users'] = [
        updated if user['email'] == current_user['email'] else user
        for user in data['users']
    ]

    data['sessions'][token] = payload.email
    store.write(data)
    return updated


@app.get('/lamp/state')
def get_lamp_state() -> dict:
    return {'lampState': store.read()['lamp_state']}


@app.put('/lamp/state')
def save_lamp_state(payload: LampPayload) -> dict:
    data = store.read()
    data['lamp_state'] = payload.lampState
    store.write(data)
    return {'lampState': data['lamp_state']}