file bin/itsybitsy_slave_poll_main
target extended-remote localhost:7777
load
break ItsyBitsy_Slave_Poll_Main
set print element 0
