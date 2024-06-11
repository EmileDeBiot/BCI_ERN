# Guide for using robotic hands with Arduino Uno

Arduino Uno is a microcontroller that allows you to control mechanical elements to create automated systems, for example. (see documentation https://www.arduino.cc/en/Guide/ArduinoUno)

After installing the prerequisites (Arduino IDE, board drivers...), connect the two robotic hands.

## Using with MATLAB (Servo Library)

MATLAB provides libraries for using Arduino, particularly for connecting to ports and controlling servomotors. These extensions need to be installed.

### Connection

To connect to the hands and create an associated Arduino object, you need to use the arduino() class and provide it with the USB port to which the Uno board is connected ('COM12' for example). This can be checked in your device manager. This connection can be automated in a script.

### Usage

Each servo motor is associated with a PWM pin. To move the motor to a specific position, you simply need to create a servo() object for each finger and move it to a position using writePosition() between 0 and 1. Unfortunately, the positions [0,1] depend on the wiring and are therefore different (extension, voltage) for each finger. The hand configuration is saved in the hand_config.json file to be used automatically and changed.

### Testing

To test the operation of the hands, you can run the test_hands() function. The fingers are supposed to activate from thumb to little finger, from right hand to left hand. Each finger is supposed to flex and extend.


## Using with an Arduino sketch

The arduino IDE provides a more complex way to deal with the controllers. You can parametrize your board to understand specific commands which makes the control of the robotic hands easier. 

### Connection

To connect to the hands and create the associated serial port object, use the init_hands function. Beforehand, remember to check the config file for the port. It should be initialised when you run set_env. 

### Arduino Sketch and Usage

The sketch written in C++ allows you to implement the given behavior into your arduino controller. A sketch is provided in BCI_robotic_hand.ino. It allows you to write a command to the serial port to:
- Activate the hands: the hands are ready to move (command 'a')
- Check if the hands are activated (command 'c')
- Action the hands: the finger described in the sketch moves (command 'r' for right, 'l' for left)
- Deactivate the hands: they cannot move (command 'd')

To send a command, you can use the functions implemented or use the write(hands: serialport object, command, type). For example action(hands, y) corresponds to write(hands, y, "char").

### Testing

To test the use of the hands with the arduino sketch, you can run test_activation. It should activate hands, move both fingers, deactivate the hands and try to move both fingers (which should not work).

