CREATE DATABASE IF NOT EXISTS smart_lamp_lab;
USE smart_lamp_lab;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    token VARCHAR(64) PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS lamp_state (
    id TINYINT PRIMARY KEY,
    state_json JSON NOT NULL
);

INSERT INTO lamp_state (id, state_json)
SELECT 1, JSON_OBJECT(
    'isLampOn', false,
    'autoMode', true,
    'sensitivity', 80,
    'sensorLux', 18,
    'broker', 'broker.emqx.io',
    'port', 1883,
    'topicPrefix', 'smartlamp/demo',
    'schedules', JSON_ARRAY(
        JSON_OBJECT('id', '1', 'day', 'Mon', 'time', '06:30', 'action', 'ON'),
        JSON_OBJECT('id', '2', 'day', 'Mon', 'time', '08:05', 'action', 'OFF'),
        JSON_OBJECT('id', '3', 'day', 'Fri', 'time', '18:40', 'action', 'ON')
    )
)
WHERE NOT EXISTS (SELECT 1 FROM lamp_state WHERE id = 1);
