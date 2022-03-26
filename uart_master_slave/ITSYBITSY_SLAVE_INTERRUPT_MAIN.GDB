file bin/itsybitsy_slave_interrupt_main
target extended-remote localhost:7777
load
break ItsyBitsy_Slave_Interrupt_Main
set print element 0
