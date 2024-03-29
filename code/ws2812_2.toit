import pixel_strip

WHEEL := [
  [255, 125, 0],
  [255, 255, 0],
  [125, 255, 0],
  [0, 255, 0],
  [0, 255, 125],
  [0, 255, 255],
  [0, 125, 255],
  [0, 0, 255],
  [125, 0, 255],
  [255, 0, 255],
  [255, 0, 125],
  [255, 0, 0],
]

PIXELS ::= 12
DEGREES_PER_LED ::= 30

/**
Linearily interpolates the integer values $a and $b by $t (in range 0-1.0).
*/
lerp a/int b/int t/float -> int:
  return (a + t * (b - a)).to_int

main:
  strip := pixel_strip.UartPixelStrip PIXELS --pin=12

  r := ByteArray PIXELS
  g := ByteArray PIXELS
  b := ByteArray PIXELS

  current := 0
  while true:
    PIXELS.repeat:
      lower := (current / DEGREES_PER_LED + it) % WHEEL.size
      higher := (lower + 1) % WHEEL.size
      t := (current % DEGREES_PER_LED) / 360.0
      r[it] = lerp WHEEL[lower][0] WHEEL[higher][0] t
      g[it] = lerp WHEEL[lower][1] WHEEL[higher][1] t
      b[it] = lerp WHEEL[lower][2] WHEEL[higher][1] t

    strip.output r g b
    current -= 10
    if current < 0: current += 360
    sleep --ms=10
