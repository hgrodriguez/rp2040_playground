--------------------------------------------------------------------------
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.GPIO;
with HAL.UART;

with Cortex_M.NVIC;

with RP2040_SVD.Interrupts;

with RP.Device;
with RP.Clock;
with RP.GPIO;
with RP.Timer;
with RP.UART;

with Pico;

with Pico_UART_Interrupt_Handlers;

procedure Pico_Interrupt_Main is
   Port           : RP.UART.UART_Port renames RP.Device.UART_0;
   Config         : constant RP.UART.UART_Configuration :=
     (Loopback     => False,
      Enable_FIFOs => False,
      others       => <>);
   Status         : HAL.UART.UART_Status;
   Data           : HAL.UART.UART_Data_8b (1 .. 1) := (others => 16#55#);
   Delays         : RP.Timer.Delays;

   use HAL;

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   Pico.LED.Configure (RP.GPIO.Output);
   RP.Device.Timer.Enable;

   Port.Configure (Config);
   --   Port.Enable_IRQ (RP.UART.Transmit);
   Port.Enable_IRQ (RP.UART.Receive);
   Port.Clear_IRQ (RP.UART.Transmit);
   Port.Clear_IRQ (RP.UART.Receive);
   Cortex_M.NVIC.Clear_Pending (RP2040_SVD.Interrupts.UART0_Interrupt);
   Cortex_M.NVIC.Enable_Interrupt (RP2040_SVD.Interrupts.UART0_Interrupt);

   loop
      Port.Transmit (Data, Status);

      while not Pico_UART_Interrupt_Handlers.UART0_Data_Received loop
         null;
      end loop;

      Port.Receive (Data, Status);
      Data (1) := Data (1) + 1;
   end loop;

   Cortex_M.NVIC.Disable_Interrupt (RP2040_SVD.Interrupts.UART0_Interrupt);
end Pico_Interrupt_Main;
