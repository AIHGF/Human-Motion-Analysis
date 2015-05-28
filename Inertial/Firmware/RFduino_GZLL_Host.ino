#include <RFduinoGZLL.h>

// Define GZLL node configuration
device_t role = HOST;

void setup()
{
  
  // Initialize virtual COM port
  Serial.begin(9600);

  // Initialize GZLL stack  
  RFduinoGZLL.begin(role);
  
}

void loop()
{
}

void RFduinoGZLL_onReceive(device_t device, int rssi, char *data, int len)
{

  // Validate device identity
  if (device == DEVICE0)
  {
    
    // Print incoming data
    Serial.println(data[0] - '0');
    // Print RSSI (Received Signal Strength Indicator) value
    Serial.println(rssi);
    
  }
  
}
