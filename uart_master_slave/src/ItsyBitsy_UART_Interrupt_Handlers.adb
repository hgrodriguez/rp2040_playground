with RP2040_SVD.UART;

with RP.Device;
with RP.UART;

with ItsyBitsy;

package body ItsyBitsy_UART_Interrupt_Handlers is

   UART : RP.UART.UART_Port renames ItsyBitsy.UART;

   procedure UART0_IRQ_Handler is
   begin
      --        if UART.Masked_IRQ_Status (IRQ => RP.UART.Transmit) then
      --           UART.Clear_IRQ (IRQ => RP.UART.Transmit);
      --           UART0_Data_Received := True;
      --        end if;
      if UART.Masked_IRQ_Status (IRQ => RP.UART.Receive) then
         UART.Clear_IRQ (IRQ => RP.UART.Receive);
         UART0_Data_Received := True;
         ItsyBitsy.LED.Toggle;
      end if;
   end UART0_IRQ_Handler;

end ItsyBitsy_UART_Interrupt_Handlers;
