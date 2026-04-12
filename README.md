# Smart Lamp IoT Flutter Lab 4

Готовий проєкт для ЛР2–ЛР4:
- 4 екрани: splash, login, register, home, profile;
- локальна реєстрація, логін, автологін, logout з підтвердженням;
- перевірка мережі через `connectivity_plus`;
- MQTT підключення до брокера, підписка на дані ESP32/VEML7700;
- ручне керування лампою, авто-режим, чутливість, weekly schedule;
- локальне збереження профілю, сесії та стану лампи;
- архітектура: `data / domain / presentation` + `Provider`.

## Як запустити

1. Розпакуйте архів.
2. Відкрийте папку `src` у VS Code або Android Studio.
3. Виконайте:
   ```bash
   flutter pub get
   flutter run
   ```
4. Для Android-емулятора або телефона переконайтесь, що Інтернет увімкнений.

## MQTT налаштування за замовчуванням

У застосунку використано такі дефолтні параметри:
- broker: `broker.emqx.io`
- port: `1883`
- topic prefix: `smartlamp/demo`

Топіки:
- `smartlamp/demo/telemetry/lux`
- `smartlamp/demo/telemetry/state`
- `smartlamp/demo/command/manual`
- `smartlamp/demo/command/mode`
- `smartlamp/demo/command/threshold`
- `smartlamp/demo/command/schedule`

## Як перевірити без ESP32

Можна підключитися через MQTT Explorer або будь-який web client і публікувати:
- в `smartlamp/demo/telemetry/lux` число, наприклад `84.5`
- в `smartlamp/demo/telemetry/state` JSON, наприклад:
  ```json
  {"lampOn": true, "autoMode": true, "threshold": 90}
  ```

## ESP32 + VEML7700

У папці `esp32_example` є приклад скетчу для ESP32:
- читає VEML7700;
- автоматично вмикає лампу при низькій освітленості;
- слухає MQTT-команди з Flutter;
- публікує lux та поточний стан.

## Що показувати на захисті

- реєстрація і валідація;
- логін;
- автологін;
- вхід без мережі при збереженій сесії;
- повідомлення про втрату Інтернету;
- MQTT telemetry update;
- ручне керування лампою;
- зміна чутливості;
- додавання/редагування/видалення розкладу;
- logout з confirm dialog.
