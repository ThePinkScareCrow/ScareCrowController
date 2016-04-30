/* Arduino code for simply forwarding read data to the receiver via
   the nRF24L01 chip */

#include <SPI.h>
#include "RF24.h"

RF24 radio(7,8);

void setup()
{
    bool radioNumber = 0;
    byte addresses[][6] = {"1Node","2Node"};
    Serial.begin(115200);
    radio.begin();
    radio.setPALevel(RF24_PA_MAX);
    radio.setChannel(50);
    radio.setRetries(5, 15);
    radio.enableDynamicPayloads();

    if(radioNumber){
        radio.openWritingPipe(addresses[1]);
        radio.openReadingPipe(1,addresses[0]);
    }else{
        radio.openWritingPipe(addresses[0]);
        radio.openReadingPipe(1,addresses[1]);
    }
    radio.startListening();
}

void loop()
{
    char msg_buffer[15];
    int msg_size;

    radio.stopListening();
    if (Serial.available() > 0) {
        msg_size = Serial.readBytesUntil('\n', msg_buffer, 15);
        radio.write(msg_buffer, msg_size);
    }
    radio.startListening();
}
