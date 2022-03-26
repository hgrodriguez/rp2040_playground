file bin/pico_interrupt_main
target extended-remote localhost:3333
load
break Pico_Interrupt_Main
set print element 0
