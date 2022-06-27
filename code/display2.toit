import pictogrammers_icons.size_48 as icons
import gpio
import i2c
import pixel_display show *
import pixel_display.two_color show *
import ssd1306 show *

get_display -> TwoColorPixelDisplay:
  sda := gpio.Pin 4
  scl := gpio.Pin 5
  frequency := 400_000

  bus := i2c.Bus --sda=sda --scl=scl --frequency=frequency

  devices := bus.scan
  if not devices.contains SSD1306.I2C_ADDRESS:
    throw "No SSD1306 display found"

  driver := SSD1306.i2c (bus.device SSD1306.I2C_ADDRESS)
  return TwoColorPixelDisplay driver

main:
  display := get_display
  display.background = BLACK

  context := display.context --landscape --color=WHITE
  icon := display.icon context 0 50 icons.HUMAN_SCOOTER
  while true:
    80.repeat:
      icon.move_to it 50
      display.draw
      sleep --ms=1
    sleep --ms=2_000

