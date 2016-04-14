final int WINDOW_HEIGHT = 600;
final int WINDOW_WIDTH = 600;
final float PITCH_RANGE_SIZE = 10;
final float ROLL_RANGE_SIZE = 10;

import processing.serial.*;


Serial serial_port;
char increase_keys[][] = { {'r',  't',  'y'}, {'u',  'i',  'o'}, {'p',  '[',  ']'} };
char decrease_keys[][] = { {'R',  'T',  'Y'}, {'U',  'I',  'O'}, {'P',  '{',  '}'} };
char lookup_controls[] = {'p', 'r', 'y'};
char lookup_pid[]      = {'p', 'i', 'd'};
float values[][]       = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
float throttle         = 0;
float controls[]       = {0, 0, 0};

void setup()
{
  //serial_port = new Serial(this, Serial.list()[0], 115200);
  //serial_port.buffer(5);
  size(600, 600);
}

void draw()
{
  background(255);
  stroke(255, 170, 170);
  line(0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, WINDOW_HEIGHT / 2);
  line(WINDOW_WIDTH / 2, 0, WINDOW_WIDTH / 2, WINDOW_HEIGHT);
  stroke(0);
  line(0, mouseY, WINDOW_HEIGHT, mouseY);
  line(mouseX, 0, mouseX, WINDOW_WIDTH);
}

float get_transformed_pitch()
{
  return (PITCH_RANGE_SIZE / WINDOW_HEIGHT) * (WINDOW_HEIGHT / 2 - mouseY);
}

float get_transformed_roll()
{
  return (ROLL_RANGE_SIZE / WINDOW_WIDTH) * (mouseX - WINDOW_WIDTH / 2);
}

void mouseMoved()
{
  controls[0] = get_transformed_pitch();
  controls[1] = get_transformed_roll();

//  serial_port.write("p" + pitch + "\n");
//  serial_port.write("r" + roll + "\n");
  print("p ", String.format("%.2f\n", controls[0]));
  print("r ", String.format("%.2f\n", controls[1]));
  flush();
}

void keyPressed()
{
  switch(key) {
    case 'w':
      throttle++;
      print("t " + throttle + "\n");
      break;
    case 's':
      throttle--;
      print("t " + throttle + "\n");
      break;
    case 'a':
      // yaw controls
      controls[2]++;
      print("t " + controls[2] + "\n");
      break;
    case 'd':
      controls[2]--;
      print("t " + controls[2] + "\n");
      break;
    default:
      for(int j = 0; j < 3; j++) {
        for(int k = 0; k < 3; k++) {
           if (key == increase_keys[j][k]) {
             values[j][k] += 0.01;
             //serial_port.write(String.format("%s%s %.3f\n", lookup_controls[j], lookup_pid[k], values[j][k]);
             print(String.format("%s%s %.3f\n", lookup_controls[j], lookup_pid[k], values[j][k]));
           }
           else if (key == decrease_keys[j][k]) {
             values[j][k] -= 0.01;
            // serial_port.write(String.format("%s%s %.3f\n", lookup_controls[j], lookup_pid[k], values[j][k]));
             print(String.format("%s%s %.3f\n", lookup_controls[j], lookup_pid[k], values[j][k]));
           }
        }
      }
  }
}
