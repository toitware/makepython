import hc_sr04
import gpio
import rmt

main:
  trigger := rmt.Channel
      gpio.Pin 21 --output
      0

  echo := rmt.Channel
      gpio.Pin 22 --input
      1

  sensor := hc_sr04.Driver --echo=echo --trigger=trigger

  while true:
    distance := sensor.distance_mm
    print "Measured: $(distance)mm"
    sleep --ms=300
