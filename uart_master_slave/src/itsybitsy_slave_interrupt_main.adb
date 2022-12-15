with HAL.UART;

with Cortex_M.NVIC;

with RP2040_SVD.Interrupts;

with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.Reset;
with RP.UART;

with ItsyBitsy;

with ItsyBitsy_UART_Interrupt_Handlers;

procedure ItsyBitsy_Slave_Interrupt_Main is

   subtype Buffer_Range is Integer range 1 .. 1;

   UART             : RP.UART.UART_Port renames ItsyBitsy.UART;
   UART_TX          : RP.GPIO.GPIO_Point renames ItsyBitsy.TX;
   UART_RX          : RP.GPIO.GPIO_Point renames ItsyBitsy.RX;
   UART_Buffer_T    : HAL.UART.UART_Data_8b (Buffer_Range);
   UART_Buffer_R    : HAL.UART.UART_Data_8b (Buffer_Range);
   UART_Status_T    : HAL.UART.UART_Status;
   UART_Status_R    : HAL.UART.UART_Status;

   use HAL;

begin
   RP.Clock.Initialize (ItsyBitsy.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   RP.Device.Timer.Enable;
   RP.Reset.Reset_Peripheral (Peripheral => RP.Reset.Reset_SPI0);
   RP.Reset.Reset_Peripheral (Peripheral => RP.Reset.Reset_UART0);
   RP.GPIO.Enable;

   ItsyBitsy.LED.Configure (RP.GPIO.Output);
   ItsyBitsy.LED.Set;

   UART_TX.Configure (Mode => RP.GPIO.Output,
                      Pull      => RP.GPIO.Pull_Up,
                      Func      => RP.GPIO.UART);
   UART_RX.Configure (Mode => RP.GPIO.Input,
                      Pull      => RP.GPIO.Floating,
                      Func      => RP.GPIO.UART);
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
   Cortex_M.NVIC.Clear_Pending (RP2040_SVD.Interrupts.UART0_Interrupt);
   Cortex_M.NVIC.Enable_Interrupt (RP2040_SVD.Interrupts.UART0_Interrupt);

   loop
      ItsyBitsy.LED.Set;
      loop
         exit when ItsyBitsy_UART_Interrupt_Handlers.UART0_Data_Received;
      end loop;
      ItsyBitsy_UART_Interrupt_Handlers.UART0_Data_Received := False;

      UART.Receive (Data    => UART_Buffer_R,
                    Status  => UART_Status_R,
                    Timeout => 0);

      ItsyBitsy.LED.Clear;
      for Idx in Buffer_Range loop
         UART_Buffer_T (Idx) := not UART_Buffer_R (Idx);
      end loop;

      ItsyBitsy.LED.Set;
      UART.Transmit (Data    => UART_Buffer_T,
                     Status  => UART_Status_T,
                     Timeout => 0);
      ItsyBitsy.LED.Clear;
   end loop;

   Cortex_M.NVIC.Disable_Interrupt (RP2040_SVD.Interrupts.UART0_Interrupt);

end ItsyBitsy_Slave_Interrupt_Main;
