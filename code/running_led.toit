import gpio

main:
  leds := [
    gpio.Pin 12 --output,
    gpio.Pin 13 --output,
    gpio.Pin 14 --output,
    gpio.Pin 15 --output,
  ]

  while true:
    // Turn each LED on for 200ms.
    leds.do:
      it.set 1
      sleep --ms=200
      it.set 0
