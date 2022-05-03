import ds18b20
import one_wire
import gpio

GPIO_PIN_NUM ::=  14

main:
  pin := gpio.Pin GPIO_PIN_NUM
  ow := one_wire.Protocol pin
  driver := ds18b20.Driver ow

  (Duration --ms=500).periodic:
    print "Temperature: $(%.2f driver.read_temperature) C"
