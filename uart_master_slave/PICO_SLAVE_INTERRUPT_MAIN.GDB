file bin/pico_slave_interrupt_main
target extended-remote localhost:7777
load
break Pico_Slave_Interrupt_Main
set print element 0
