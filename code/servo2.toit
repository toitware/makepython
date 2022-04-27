import gpio
import .motor as servo

main:
  motor := servo.Motor (gpio.Pin 14)
  motor.degrees = 90
  sleep --ms=1500
  motor.degrees = 0
  sleep --ms=1500
  motor.degrees = 100
  sleep --ms=1500
  motor.degrees = -150
  sleep --ms=1500
