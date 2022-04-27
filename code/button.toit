import gpio

main:
  button := gpio.Pin 21 --input
  led := gpio.Pin 5 --output

  while true:
    if button.get == 1:
      led.set 1
    else:
      led.set 0
    sleep --ms=1
