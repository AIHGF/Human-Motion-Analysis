#include <RFduinoGZLL.h>

// Define GZLL node configuration
device_t role = DEVICE0;

// Define connections to accelerometer (ADXL335)
const int pinAX = 3;
const int pinAY = 4;
const int pinAZ = 2;

void setup()
{

  // Initialize GZLL stack
  RFduinoGZLL.begin(role);

}

void loop()
{

  // Retrieve acceleration
  int valueAX = analogRead(pinAX);
  int valueAY = analogRead(pinAY);
  int valueAZ = analogRead(pinAZ);
  
  // Send raw sensor data across network
  RFduinoGZLL.sendToHost(char(valueAX));
  RFduinoGZLL.sendToHost(char(valueAY));
  RFduinoGZLL.sendToHost(char(valueAZ));
  
}

void RFduinoGZLL_onReceive(device_t device, int rssi, char *data, int len)
{
}
