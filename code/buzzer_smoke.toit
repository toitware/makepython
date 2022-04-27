import gpio
import gpio.pwm

FREQ_A ::= 440
FREQ_G ::= 392
FREQ_B_FLAT ::= 466
FREQ_C ::= 523
FREQ_C_SHARP ::= 554

buzz pin --frequency --ms:
  generator := pwm.Pwm --frequency=frequency
  channel := generator.start pin --duty_factor=0.5
  sleep --ms=ms
  channel.close
  generator.close

main:
  buzzer := gpio.Pin 14
  buzz buzzer --frequency=FREQ_G --ms=700
  buzz buzzer --frequency=FREQ_B_FLAT --ms=700
  buzz buzzer --frequency=FREQ_C --ms=700
  sleep --ms=250
  buzz buzzer --frequency=FREQ_G --ms=700
  buzz buzzer --frequency=FREQ_B_FLAT --ms=700
  buzz buzzer --frequency=FREQ_C_SHARP --ms=400
  buzz buzzer --frequency=FREQ_C --ms=1200
  buzzer.close
