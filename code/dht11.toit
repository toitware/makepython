import dhtxx
import gpio

GPIO_PIN_NUM ::=  14

main:
  pin := gpio.Pin GPIO_PIN_NUM
  driver := dhtxx.Dht11 pin

  (Duration --ms=500).periodic:
    print driver.read
