import gpio

main:
  leds := [
    gpio.Pin 12 --output,
    gpio.Pin 13 --output,
    gpio.Pin 14 --output,
    gpio.Pin 15 --output,
  ]

  i := 0
  while true:
    // Take the next led and turn it on for 200ms.
    led := leds[i]
    led.set 1
    sleep --ms=200
    led.set 0
    // Increment the index, wrapping around when we reach the
    // end of the list.
    i = (i + 1) % leds.size
