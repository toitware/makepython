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
  for i := 200; i < 2000; i += 10:
    buzz buzzer --frequency=i --ms=250
  buzzer.close
