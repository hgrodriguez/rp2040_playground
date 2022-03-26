file bin/pico_master_main
target extended-remote localhost:3333
load
break Pico_Master_Main
set print element 0
