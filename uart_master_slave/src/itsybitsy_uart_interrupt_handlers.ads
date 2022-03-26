package ItsyBitsy_UART_Interrupt_Handlers is

   UART0_Data_Received : Boolean := False;

private
   procedure UART0_IRQ_Handler
     with Export => True,
     Convention => C,
     External_Name => "isr_irq20";

end ItsyBitsy_UART_Interrupt_Handlers;
