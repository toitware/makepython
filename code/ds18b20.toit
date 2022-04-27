import ds18b20
import one_wire
import rmt
import gpio

GPIO_PIN_NUM ::=  14

RX_CHANNEL_NUM ::= 0
TX_CHANNEL_NUM ::= 1

main:
  pin := gpio.Pin GPIO_PIN_NUM
  rx_channel := rmt.Channel pin RX_CHANNEL_NUM
  tx_channel := rmt.Channel pin TX_CHANNEL_NUM

  driver := ds18b20.Driver
      one_wire.Protocol --rx=rx_channel --tx=tx_channel

  is_parasitic := driver.is_parasitic
  print "is parasitic: $is_parasitic"
  if is_parasitic: return

  (Duration --s=1).periodic:
    print "Temperature: $(%.2f driver.read_temperature_C) C"