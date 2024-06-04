
#include <Servo.h>

// Arduino sketch to use the robotic hands with BCI

#define num_servo 2
// ************************************* To tune if hands have changed  ******************************* //
int servpinright = 4;
int servpinleft = 13;
int up_angle[num_servo]={140,140};
int low_angle[num_servo]={30,50};
int push_angle[num_servo] ={60,60};

Servo servoR = Servo();
Servo servoL = Servo();

bool is_ready = false;



int val=0;
void setup()
{
  Serial.begin(115200);  delay(1000);
  Serial.println("Connection created");
  //test(); // tests if the servos are working and the parameters are correct
}

void loop() {
  if (Serial.available() > 0){
    char cmd = Serial.read();
    // activate the hands
    if (cmd == 'a'){
      init_servo();
      is_ready = true;
    }
    // deactivate the hands
    else if (cmd == 'd'){
      if (is_ready){
        deactivate();
        is_ready = false;
      }
    }
    // check if the hands are ready
    else if (cmd == 'c'){
      if (is_ready) {
        Serial.println("Ready for movement.");
      }
      else{
        Serial.println("The fingers are deactivated. Use activate function before you want to do a movement.");
      }
    }
    // move a finger
    else actuateFinger(cmd);
  }
}

void actuateFinger(int cmd)
{
  if (cmd == 'l'){
    servoL.write(push_angle[0]);
    delay(800);
    servoL.write(up_angle[0]);
  }
  else if (cmd == 'r'){
    servoR.write(push_angle[1]);
    delay(800);
    servoR.write(up_angle[1]);
  }
}

void test(){
  // Test the servos
  // The servos should move to the up position and then to the button push position
  servoR.attach(servpinright);
  servoR.write(up_angle[1]);
  delay(2000);
  servoR.write(push_angle[1]);
  delay(1000);
  servoR.detach();

  servoL.attach(servpinleft);
  servoL.write(up_angle[0]);
  delay(2000);
  servoL.write(push_angle[0]);
  delay(1000);
  servoL.detach();
}

void init_servo(){
  // Initialize the servos
  servoR.attach(servpinright);
  servoR.write(up_angle[0]);
  servoL.attach(servpinleft);
  servoL.write(up_angle[1]);
}

void deactivate(){
  // Deactivate the servos
  servoR.detach();
  servoL.detach();
}