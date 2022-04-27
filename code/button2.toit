import gpio

main:
  button := gpio.Pin 21 --input
  led := gpio.Pin 5 --output

  while true:
    led.set button.get
    sleep --ms=1
