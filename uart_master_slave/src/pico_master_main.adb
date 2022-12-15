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

procedure Pico_Master_Main is
   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Released;

   Trigger      : RP.GPIO.GPIO_Point renames Pico.GP15;

   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

   UART           : RP.UART.UART_Port renames RP.Device.UART_0;
   UART_TX        : RP.GPIO.GPIO_Point renames Pico.GP0;
   UART_RX        : RP.GPIO.GPIO_Point renames Pico.GP1;
   UART_Buffer_T  : HAL.UART.UART_Data_8b (1 .. 1)
     := (others => 16#A5#);
   UART_Buffer_R  : HAL.UART.UART_Data_8b (1 .. 1);
   UART_Status_T    : HAL.UART.UART_Status;
   UART_Status_R    : HAL.UART.UART_Status;

   procedure Wait_For_Trigger_Fired is
   begin
      if False then
         loop
            exit when not Button.Get;
         end loop;
      end if;
   end Wait_For_Trigger_Fired;

   procedure Wait_For_Trigger_Released is
   begin
      if False then
         loop
            exit when Button.Get;
         end loop;
      end if;
   end Wait_For_Trigger_Released;

   use HAL;

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   Pico.LED.Configure (RP.GPIO.Output);
   RP.Device.Timer.Enable;

   Button.Configure (Mode => RP.GPIO.Input,
                     Pull => RP.GPIO.Pull_Up,
                     Func => RP.GPIO.SIO);

   Trigger.Configure (Mode => RP.GPIO.Output,
                     Pull => RP.GPIO.Pull_Up,
                     Func => RP.GPIO.SIO);

   UART_TX.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.UART);
   UART_RX.Configure (RP.GPIO.Input, RP.GPIO.Floating, RP.GPIO.UART);
   UART.Configure
     (Config =>
        (Baud      => 115_200,
         Word_Size => 8,
         Parity    => False,
         Stop_Bits => 1,
         others    => <>));

   Trigger.Set;

   loop
      Wait_For_Trigger_Fired;
      Pico.LED.Set;
      Trigger.Clear;
      UART.Transmit (Data    => UART_Buffer_T,
                     Status  => UART_Status_T,
                     Timeout => 0);
      Wait_For_Trigger_Released;
      UART.Receive (Data    => UART_Buffer_R,
                    Status  => UART_Status_R,
                    Timeout => 0);

      Wait_For_Trigger_Fired;
      Trigger.Set;
      Pico.LED.Clear;
      Wait_For_Trigger_Released;
      UART_Buffer_T (1) := UART_Buffer_T (1) + 1;
   end loop;

end Pico_Master_Main;
