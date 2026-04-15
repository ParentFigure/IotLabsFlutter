import json
from pathlib import Path

DEFAULT_STORE = {
    'users': [],
    'sessions': {},
    'lamp_state': {
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
    },
}


class JsonStore:
    def __init__(self, path: Path):
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)
        if not self.path.exists():
            self.write(DEFAULT_STORE)

    def read(self) -> dict:
        with self.path.open('r', encoding='utf-8') as file:
            return json.load(file)

    def write(self, data: dict) -> None:
        with self.path.open('w', encoding='utf-8') as file:
            json.dump(data, file, indent=2)
