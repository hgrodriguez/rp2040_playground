with HAL.UART;

with Cortex_M.NVIC;

with RP2040_SVD.Interrupts;

with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.UART;

with Pico;

with Pico_UART_Interrupt_Handlers;

procedure Pico_Slave_Interrupt_Main is

   subtype Buffer_Range is Integer range 1 .. 1;

   UART             : RP.UART.UART_Port renames RP.Device.UART_0;
   UART_TX          : RP.GPIO.GPIO_Point renames Pico.GP0;
   UART_RX          : RP.GPIO.GPIO_Point renames Pico.GP1;
   UART_Buffer_T    : HAL.UART.UART_Data_8b (Buffer_Range);
   UART_Buffer_R    : HAL.UART.UART_Data_8b (Buffer_Range);
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
         Enable_FIFOs => False,
         others    => <>));

   --   UART.Enable_IRQ (RP.UART.Transmit);
   UART.Enable_IRQ (RP.UART.Receive);
   UART.Clear_IRQ (RP.UART.Transmit);
   UART.Clear_IRQ (RP.UART.Receive);

   Cortex_M.NVIC.Clear_Pending (IRQn => RP2040_SVD.Interrupts.UART0_Interrupt);
   Cortex_M.NVIC.Enable_Interrupt (IRQn => RP2040_SVD.Interrupts.UART0_Interrupt);

   loop
      Pico.LED.Set;
      loop
         exit when Pico_UART_Interrupt_Handlers.UART0_Data_Received;
      end loop;
      Pico_UART_Interrupt_Handlers.UART0_Data_Received := False;

      UART.Receive (Data    => UART_Buffer_R,
                    Status  => UART_Status_R,
                    Timeout => 0);

      Pico.LED.Clear;
      for Idx in Buffer_Range loop
         UART_Buffer_T (Idx) := not UART_Buffer_R (Idx);
      end loop;

      Pico.LED.Set;
      UART.Transmit (Data    => UART_Buffer_T,
                     Status  => UART_Status_T,
                     Timeout => 0);
      Pico.LED.Clear;
   end loop;

end Pico_Slave_Interrupt_Main;
