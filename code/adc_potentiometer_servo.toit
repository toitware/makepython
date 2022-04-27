import gpio
import gpio.adc
import gpio.pwm

main:
  MIN_VOLTAGE ::= 0.0
  MAX_VOLTAGE ::= 3.3

  pin := gpio.Pin 32
  adc := adc.Adc pin

  MAX_ANGLE ::= 0.125
  MIN_ANGLE ::= 0.025

  servo := gpio.Pin 14
  generator := pwm.Pwm --frequency=50
  channel := generator.start servo --duty_factor=0.075
  sleep --ms=10 // https://github.com/toitlang/toit/issues/518

  while true:
    v := adc.get --samples=1

    duty := MIN_ANGLE +
        ((v - MIN_VOLTAGE) / (MAX_VOLTAGE - MIN_VOLTAGE)) * (MAX_ANGLE - MIN_ANGLE)
    channel.set_duty_factor duty

    sleep --ms=1
