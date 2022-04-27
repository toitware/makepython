import gpio
import gpio.adc
import i2c
import pixel_display show *
import pixel_display.two_color show *
import pixel_display.histogram show *
import ssd1306 show *

WIDTH ::= 128
HEIGHT ::= 64

/**
A chart that shows the given data as a histogram.
The bar height is computed based on the max and min of recent
  values. New values are linearly interpolated between the
  min/max of the remembered values.
*/
class AdaptiveChart:
  current_bar_ := 0
  current_remembered_ := 0
  bars_ / List
  remembered_ / List
  width / int
  height / int

  constructor
      display /TwoColorPixelDisplay
      context /GraphicsContext
      .width /int
      .height /int
      --initial_value/float:
    remembered_ = List width/2: initial_value
    half_height := height / 2
    bars_ = List width:
      display.line context it half_height it (half_height + 1)
    bars_.do: display.add it

  add value/float:
    if current_bar_ >= bars_.size: current_bar_ = 0
    if current_remembered_ >= remembered_.size:
      current_remembered_ = 0
    min_value := remembered_.reduce: | a b | min a b
    max_value := remembered_.reduce: | a b | max a b
    remembered_[current_remembered_++] = value
    // Bring the given value into a range 0.0 to 1.0 where
    //   0.0 represents the min value and 1.0 the max.
    // Linearly interpolate between them.
    scaled := ?
    if value <= min_value: scaled = 0.0
    else if value >= max_value: scaled = 1.0
    else:
      range := max_value - min_value
      scaled = (value - min_value) / range
    bar / FilledRectangle := bars_[current_bar_++]
    y := (scaled - 0.5) * (height - 1)
    bar.height = y.to_int

main:
  pin := gpio.Pin 32
  sensor := adc.Adc pin

  sda := gpio.Pin 4
  scl := gpio.Pin 5
  frequency := 800_000

  bus := i2c.Bus --sda=sda --scl=scl --frequency=frequency

  devices := bus.scan
  if not devices.contains SSD1306_ID: throw "No SSD1306 display found"

  driver := SSD1306.i2c (bus.device SSD1306_ID)
  display := TwoColorPixelDisplay driver
  display.background = BLACK
  context := display.context --color=WHITE
  chart := AdaptiveChart display context WIDTH HEIGHT --initial_value=1.65

  while true:
    chart.add sensor.get
    display.draw
    sleep --ms=40
