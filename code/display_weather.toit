import encoding.json
import font show *
import font.x11_100dpi.sans.sans_14_bold
import gpio
import i2c
import ssd1306 show *
import monitor show Mutex
import one_wire
import ds18b20
import ntp
import esp32 show adjust_real_time_clock

import pictogrammers_icons.size_48 as icons

import pixel_display.two_color show *
import pixel_display.texture show *
import pixel_display show TwoColorPixelDisplay

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

// Search for icon names on https://materialdesignicons.com/
// (hover over icons to get names).
WMO_4501_ICONS ::= [
  icons.WEATHER_SUNNY,
  icons.WEATHER_CLOUDY,
  icons.WEATHER_SNOWY,
  icons.WEATHER_SNOWY_HEAVY,
  icons.WEATHER_FOG,
  icons.WEATHER_PARTLY_RAINY,
  icons.WEATHER_RAINY,
  icons.WEATHER_SNOWY,
  icons.WEATHER_PARTLY_RAINY,
  icons.WEATHER_LIGHTNING,
]

// We don't want separate threads updating the display at the
// same time, so this mutex is used to ensure the tasks only
// have access one at a time.
display_mutex := Mutex

main:
  result ::= ntp.synchronize
  if result:
    adjust_real_time_clock result.adjustment

  // Uganda: "EAT-3"
  set_timezone "CET-1CEST,M3.5.0,M10.5.0/3"

  display := get_display

  sans_14_font ::= Font [
    sans_14_bold.ASCII,  // Regular characters.
    sans_14_bold.LATIN_1_SUPPLEMENT,  // Degree symbol.
  ]

  // Build a scene with the metods `add`, `text`, `icon`,
  // and `filled_rectangle`.

  display.background = BLACK
  context := display.context
    --landscape
    --color=WHITE
    --font=sans_14_font
  black_context := context.with --color=BLACK

  // White circle as background of weather icon.  We are just
  // using the window to draw a circle here, not as an actual
  // window with its own textures.
  DIAMETER ::= 56
  CORNER_RADIUS ::= DIAMETER / 2
  display.add
    RoundedCornerWindow 68 4 DIAMETER DIAMETER
      context.transform
      CORNER_RADIUS
      WHITE
  // Icon is added after the white dot so it is in a higher layer.
  icon_texture :=
    display.icon black_context 72 48 icons.WEATHER_CLOUDY

  // Temperature is black on white.
  display.filled_rectangle context 0 0 64 32
  temperature_context :=
    black_context.with --alignment=TEXT_TEXTURE_ALIGN_CENTER
  temperature_texture :=
    display.text temperature_context 32 23 "??°C"

  // Time is white on the black background, aligned by the
  // center so it looks right relative to the temperature
  // without having to zero-pad the hours.
  time_context := context.with --alignment=TEXT_TEXTURE_ALIGN_CENTER
  time_texture := display.text time_context 32 53 "??:??"

  // The scene is built, now start some tasks that will update
  // the display.

  task:: clock_task display time_texture
  task:: weather_task display icon_texture temperature_texture

weather_task display/TwoColorPixelDisplay
    weather_icon/IconTexture
    temperature_texture/TextTexture:
  pin := gpio.Pin 14
  ow := one_wire.Protocol pin
  driver := ds18b20.Driver ow

  while true:
    temp := driver.read_temperature
    // Just using the temperature we don't know if it's
    // sunny or not. We arbitrary decide that it's sunny if
    // the temperature is more than 20 degrees.
    // Otherwise it's cloudy.
    weather := ?
    if temp > 20: weather = WMO_4501_ICONS[0]
    else: weather = WMO_4501_ICONS[1]
    display_mutex.do:
      weather_icon.icon = weather
      temperature_texture.text = "$(%.1f temp)°C"
      display.draw
    sleep --ms=2_000

clock_task display/TwoColorPixelDisplay time_texture/TextTexture:
  while true:
    now := (Time.now).local
    display_mutex.do:
      // H:MM or HH:MM depending on time of day.
      time_texture.text = "$now.h:$(%02d now.m)"
      display.draw
    // Sleep this task until the next whole minute.
    sleep_time := 60 - now.s
    sleep --ms=sleep_time*1000
