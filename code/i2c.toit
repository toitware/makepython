import gpio
import i2c

main:
  sda := gpio.Pin 4
  scl := gpio.Pin 5
  frequency := 100_000

  bus := i2c.Bus --sda=sda --scl=scl --frequency=frequency

  devices := bus.scan
  devices.do: print it
