/* 
  LeBox v2
  The first version with the arduino built in

  Created: 29 June 2011
  by C. Frauenberger
  
  GPL License
 */
 
 #include <NewSoftSerial.h>
 

// these constants won't change:
const int knockSensor = A0; // the piezo is connected to analog pin 0
const int knockThreshold = 50;  // threshold value to decide when the detected sound is a knock or not
const int speakerOut = 9;               
const int MAX_COUNT = 24;
const int acX = A5;
const int acY = A4;
const int acZ = A3;
const int minVal = 265;
const int maxVal = 407;
const int btRxPin = 5; // BlueSMiRF module tx
const int btTxPin = 6; // BlueSMiRF module rx

// tones and meoldy
byte names[] = {'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C'};  
int tones[] = {1915, 1700, 1519, 1432, 1275, 1136, 1014, 956};
byte melody[] = "2d2a1f2c2d2a2d2c2f2d2a2c2d2a1f2c2d2a2a2g2p8p8p8p";

// the BT serial
NewSoftSerial btSerial(btRxPin, btTxPin);

// these variables will change:
int knockReading = 0;      // variable to store the value read from the sensor pin
int count = 0;
int count2 = 0;
int count3 = 0;

void setup() {

  btSerial.begin(115200);
  Serial.begin(115200); 
}


void playTune() {
 analogWrite(speakerOut, 0);     
  for (count = 0; count < MAX_COUNT; count++) {
    for (count3 = 0; count3 <= (melody[count*2] - 48) * 30; count3++) {
      for (count2=0;count2<8;count2++) {
        if (names[count2] == melody[count*2 + 1]) {       
          analogWrite(speakerOut,500);
          delayMicroseconds(tones[count2]);
          analogWrite(speakerOut, 0);
          delayMicroseconds(tones[count2]);
        } 
        if (melody[count*2 + 1] == 'p') {
          // make a pause of a certain size
          analogWrite(speakerOut, 0);
          delayMicroseconds(500);
        }
      }
    }
  }  
}

void loop() {
  // the degree values
  int x,y,z;
  
  //read the analog values from the accelerometer
  int xRead = analogRead(acX);
  int yRead = analogRead(acY);
  int zRead = analogRead(acZ);  
  
  //convert read values to degrees -90 to 90 - Needed for atan2
  int xAng = map(xRead, minVal, maxVal, -90, 90);
  int yAng = map(yRead, minVal, maxVal, -90, 90);
  int zAng = map(zRead, minVal, maxVal, -90, 90);

  //Caculate 360deg values like so: atan2(-yAng, -zAng)
  //atan2 outputs the value of -π to π (radians)
  //We are then converting the radians to degrees
  x = RAD_TO_DEG * (atan2(-yAng, -zAng) + PI);
  y = RAD_TO_DEG * (atan2(-xAng, -zAng) + PI);
  z = RAD_TO_DEG * (atan2(-yAng, -xAng) + PI);

  //Output the caculations
  btSerial.print("DA");
  btSerial.print(x);
  btSerial.print(",");
  btSerial.print(y);
  btSerial.print(",");
  btSerial.print(z);
  btSerial.print(",");
  
  // read the sensor and store it in the variable sensorReading:
  knockReading = analogRead(knockSensor);    
  
  // if the sensor reading is greater than the threshold:
  if (knockReading >= knockThreshold) {
    //playTune();
    btSerial.print("DK");         
  }
  delay(100);  // delay to avoid overloading the serial port buffer
}
