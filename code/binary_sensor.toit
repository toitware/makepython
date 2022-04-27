import gpio

main:
  led := gpio.Pin 5 --output
  sensor := gpio.Pin 13 --input

  while true:
    sensor.wait_for 1
    led.set 1
    sleep --ms=1000
    led.set 0
