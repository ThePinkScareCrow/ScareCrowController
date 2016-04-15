/* Processing code which accepts user input writes commands out to the
 * Arduino. Uses the mouse to control pitch and roll. Uses 'ws' to
 * control throttle and 'sd' to control yaw. The other keys can be
 * used to tune the PID. */

final int WINDOW_HEIGHT = 600;
final int WINDOW_WIDTH = 600;
final float PITCH_RANGE_SIZE = 20;
final float ROLL_RANGE_SIZE = 20;
final int SERIAL_PRINT_TIME_INTERVAL = 10;

import processing.serial.*;


Serial serial_port;
/*                          PITCH P I D          ROLL P I D           YAW P I D      */
char increase_keys[][] = { {'r',  't',  'y'}, {'u',  'i',  'o'}, {'p',  '[',  ']' } };
char decrease_keys[][] = { {'R',  'T',  'Y'}, {'U',  'I',  'O'}, {'P',  '{',  '}' } };
char lookup_controls[] = {'p', 'r', 'y'}; /* pitch, roll, yaw */
char lookup_pid[]      = {'p', 'i', 'd'}; /* proportional, integral, derivative */
float values[][]       = { {0, 0, 0}, {0, 0, 0}, {0, 0, 0} }; /* pitch, roll, yaw PIDs */
float throttle         = 0;
float controls[]       = {0, 0, 0}; /* pitch, roll, yaw */
int last_time = 0;

void setup()
{
    serial_port = new Serial(this, Serial.list()[0], 115200);
    serial_port.buffer(5);
    size(600, 600);
}

void draw()
{
    background(255);
    /* draw centered crosshair */
    stroke(255, 170, 170);
    line(0, WINDOW_HEIGHT / 2, WINDOW_WIDTH, WINDOW_HEIGHT / 2);
    line(WINDOW_WIDTH / 2, 0, WINDOW_WIDTH / 2, WINDOW_HEIGHT);

    /* draw crosshair at the position of mouse  */
    stroke(0);
    line(0, mouseY, WINDOW_HEIGHT, mouseY);
    line(mouseX, 0, mouseX, WINDOW_WIDTH);

    fill(0);
    String display_text = "";
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            display_text += String.format("%s%s: %s\n", lookup_controls[i],
                                          lookup_pid[j], values[i][j]);
        }
        display_text += "\n";
    }
    display_text += String.format("t: %s\np: %s\nr: %s\ny: %s", throttle,
                                  controls[0], controls[1], controls[2]);
    text(display_text, 100, 100);

    int cur_time = millis();
    if (cur_time - last_time > SERIAL_PRINT_TIME_INTERVAL) {
        String temp;

        temp = String.format("p %.2f\nr %.2f\ny %.2f\nt %.2f\n",
                             controls[0], controls[1], controls[2], throttle);
        serial_port.write(temp);
        print(temp);

        last_time = cur_time;
    }
}

float get_transformed_pitch()
{
    /* convert to pitch from position of mouse */
    return (PITCH_RANGE_SIZE / WINDOW_HEIGHT) * (WINDOW_HEIGHT / 2 - mouseY);
}

float get_transformed_roll()
{
    /* convert to roll from position of mouse */
    return (ROLL_RANGE_SIZE / WINDOW_WIDTH) * (mouseX - WINDOW_WIDTH / 2);
}

void mouseMoved()
{
    controls[0] = get_transformed_pitch();
    controls[1] = get_transformed_roll();
}

void mousePressed()
{
    if (mouseButton == LEFT)
        controls[2]++;
    else if (mouseButton == RIGHT)
        controls[2]--;
}

void mouseWheel(MouseEvent event)
{
    throttle -= event.getCount();
}

void keyPressed()
{
    switch(key) {
    case 'w':
        throttle++;
        break;
    case 's':
        throttle--;
        break;
    case 'a':
        // yaw controls
        controls[2]++;
        break;
    case 'd':
        controls[2]--;
        break;
    default:
        for(int j = 0; j < 3; j++) {
            for(int k = 0; k < 3; k++) {
                if (key == increase_keys[j][k]) {
                    values[j][k] += 0.01;
                    serial_port.write(String.format("%s%s %.3f\n",
                                                    lookup_controls[j],
                                                    lookup_pid[k],
                                                    values[j][k])
                                      );
                    print(String.format("%s%s %.3f\n",
                                        lookup_controls[j],
                                        lookup_pid[k],
                                        values[j][k])
                          );
                }
                else if (key == decrease_keys[j][k]) {
                    values[j][k] -= 0.01;
                    serial_port.write(String.format("%s%s %.3f\n",
                                                    lookup_controls[j],
                                                    lookup_pid[k],
                                                    values[j][k])
                                      );
                    print(String.format("%s%s %.3f\n", lookup_controls[j],
                                        lookup_pid[k], values[j][k])
                          );
                }
            }
        }
    }
}
