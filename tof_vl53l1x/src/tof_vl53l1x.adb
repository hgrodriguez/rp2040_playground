with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;
with RP.Timer;
with RP.Timer.Interrupts;

with Pico;

with VL53L1X;

procedure Tof_Vl53l1x is
   My_I2C     : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   My_Delay   : aliased RP.Timer.Interrupts.Delays;
   use VL53L1X;
   My_Sensor  : VL53L1X_Ranging_Sensor (Port   => My_I2C'Access,
                                        Timing => My_Delay'Unchecked_Access);

   procedure Initialize_Device;
   procedure Initialize_I2C_0;

   procedure Initialize_Device is
   begin
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;
      Pico.LED.Configure (RP.GPIO.Output);
   end Initialize_Device;

   procedure Initialize_I2C_0 is
      SDA     : RP.GPIO.GPIO_Point renames Pico.GP0;
      SCL     : RP.GPIO.GPIO_Point renames Pico.GP1;
   begin
      SDA.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      SCL.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      My_I2C.Configure (Baudrate => 100_000);
   end Initialize_I2C_0;

   My_Status : VL53L1X.Boot_Status;
   My_Measurement : VL53L1X.Measurement;
   My_Millimetres : VL53L1X.Millimetres;

begin
   Initialize_Device;
   Pico.LED.Set;
   Initialize_I2C_0;

   VL53L1X.Boot_Device (This             => My_Sensor,
                        Status           => My_Status);

   VL53L1X.Sensor_Init (This => My_Sensor);
   VL53L1X.Start_Ranging (This => My_Sensor);

   loop
      VL53L1X.Wait_For_Measurement (This             => My_Sensor);
      My_Measurement := VL53L1X.Get_Measurement (This => My_Sensor);
      My_Millimetres := My_Measurement.Distance;
      My_Millimetres := My_Millimetres + 0;
   end loop;
end Tof_Vl53l1x;
