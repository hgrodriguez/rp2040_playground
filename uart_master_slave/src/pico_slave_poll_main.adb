--------------------------------------------------------------------------
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.GPIO;
with HAL.UART;

with RP.Device;
with RP.Clock;
with RP.GPIO;
with RP.UART;

with Pico;

procedure Pico_Slave_Poll_Main is

   UART           : RP.UART.UART_Port renames RP.Device.UART_0;
   UART_TX        : RP.GPIO.GPIO_Point renames Pico.GP0;
   UART_RX        : RP.GPIO.GPIO_Point renames Pico.GP1;
   UART_Buffer_T  : HAL.UART.UART_Data_8b (1 .. 1)
     := (others => 16#5A#);
   UART_Buffer_R  : HAL.UART.UART_Data_8b (1 .. 1);
   UART_Status_T    : HAL.UART.UART_Status;
   UART_Status_R    : HAL.UART.UART_Status;

   use HAL;

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   Pico.LED.Configure (RP.GPIO.Output);
   RP.Device.Timer.Enable;

   UART_TX.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.UART);
   UART_RX.Configure (RP.GPIO.Input, RP.GPIO.Floating, RP.GPIO.UART);
   UART.Configure
     (Config =>
        (Baud      => 115_200,
         Word_Size => 8,
         Parity    => False,
         Stop_Bits => 1,
         others    => <>));

   loop
      Pico.LED.Set;
      UART.Receive (Data    => UART_Buffer_R,
                    Status  => UART_Status_R,
                    Timeout => 0);

      for Idx in UART_Buffer_R'Range loop
         UART_Buffer_T (Idx) := not UART_Buffer_R (Idx);
      end loop;

      UART.Transmit (Data    => UART_Buffer_T,
                     Status  => UART_Status_T,
                     Timeout => 0);
      Pico.LED.Clear;
   end loop;

end Pico_Slave_Poll_Main;
