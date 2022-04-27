import gpio

main:
  pin := gpio.Pin 5 --output
  while true:
    pin.set 0
    sleep --ms=500
    pin.set 1
    sleep --ms=500
