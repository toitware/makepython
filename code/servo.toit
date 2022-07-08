import gpio
import gpio.pwm

main:
  servo := gpio.Pin 14
  generator := pwm.Pwm --frequency=50

  // Start with the half-way angle.
  channel := generator.start servo --duty_factor=0.075
  sleep --ms=1500

  // Max angle.
  print "max"
  channel.set_duty_factor 0.125
  sleep --ms=1500

  // Min angle.
  print "min"
  channel.set_duty_factor 0.025
  sleep --ms=1500
