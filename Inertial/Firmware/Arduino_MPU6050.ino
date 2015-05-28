#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"
#include "TimerOne.h"

// Declare sensor object
MPU6050 accelgyro;

// Declare variables to store raw sensor data
int16_t ax, ay, az;
int16_t gx, gy, gz;

// Declare variable to govern even sampling
// Polling + Interrupts since interrupts alone are faulty
unsigned int isr = 0;

void setup()
{
  
  // Initialize I2C bus connection
  Wire.begin();
  
  // Initiate handshakes with sensor
  accelgyro.initialize();
  
  // Initialize virtual COM port connection
  Serial.begin(9600);
  
  // Define timer interrupt
  Timer1.initialize(500000/25);
  Timer1.attachInterrupt(toggle);

}

void toggle()
{
  
 isr = 1-isr;
 
}

void loop()
{
  
  // Execute upon interrupt
  if(isr)
  {
    
    // Retrieve acceleration and rotation
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
    
    isr = 0;
    
    // Print raw sensor data
    Serial.println(ax);
    Serial.println(ay);
    Serial.println(az);
    Serial.println(gx);
    Serial.println(gy);
    Serial.println(gz);
    
  }

}
