// Copyright (C) 2021 Toitware ApS. All rights reserved.
import math
import gpio
import gpio.pwm as gpio

/**
A Servo Motor abstraction for configuring and working with a servo motor
  using the Pulse-Width Modulation (PWM) sub-system.

The default configuration of an servo motor is to operate at 50 Hz with the
  following mappings:
  * 1500 us pulse for angle of 0 degrees.
  * 2500 us pulse for angle of 90 degrees.
  *  500 us pulse for minimum angle.
  * 2500 us pulse for maximum angle.
  which gives a total angle of +/- 90 degrees.
*/
class Motor:
  static DEFAULT_FREQUENCY ::= 50
  static ANGLE_0_US_   ::= 1500.0
  static ANGLE_90_US_  ::= 2500.0
  static ANGLE_MIN_US_ ::= 500.0
  static ANGLE_MAX_US_ ::= 2500.0

  static DEGREES_PER_RAD_ := 180.0 / math.PI

  pwm/gpio.Pwm?
  channel/gpio.PwmChannel

  us_/float := 0.0

  angle_0_us_/float := ANGLE_0_US_
  angle_90_us_/float := ANGLE_90_US_
  angle_min_us_/float := ANGLE_MIN_US_
  angle_max_us_/float := ANGLE_MAX_US_

  constructor.from_channel .channel/gpio.PwmChannel:
    pwm = null

  constructor pin/gpio.Pin --pwm/gpio.Pwm?=null --frequency/int=DEFAULT_FREQUENCY:
    if not pwm: pwm = gpio.Pwm --frequency=frequency
    this.pwm = pwm
    channel = pwm.start pin

  config --min_us/float?=null --max_us/float?=null:
    if min_us: angle_min_us_ = min_us
    if max_us: angle_max_us_ = max_us

  degrees -> float: return radians * DEGREES_PER_RAD_

  degrees= degrees/num:
    radians = degrees / DEGREES_PER_RAD_

  radians -> float: return us_to_radians_ us_

  radians= radians/num:
    us := radians_to_us_ radians
    apply_us_ us

  gain -> float:
    return (us_ - angle_min_us_) / (angle_max_us_ - angle_min_us_)

  /**
  Set the output as a gain between 0.0 and 1.0.

  That means the default configuration will map a gain of 0.5 to 0 degrees.
  */
  gain= gain/num:
    gain = min 1.0 (max 0.0 gain)
    us := (angle_max_us_ - angle_min_us_) * gain + angle_min_us_
    apply_us_ us

  radians_to_us_ radians/num -> float:
    us_per_rad := (angle_90_us_ - angle_0_us_) * 2.0 / math.PI
    us := angle_0_us_ + radians * us_per_rad
    return min
      max us angle_min_us_
      angle_max_us_

  us_to_radians_ us/float -> float:
    us_per_rad := (angle_90_us_ - angle_0_us_) * 2.0 / math.PI
    return (us - angle_0_us_) / us_per_rad

  apply_us_ us/float:
    cycle_us := (1.0 / /*channel.pwm.frequency*/ DEFAULT_FREQUENCY) * 1_000_000
    print "Setting $(us / cycle_us)"
    channel.set_duty_factor us / cycle_us
    us_ = us
