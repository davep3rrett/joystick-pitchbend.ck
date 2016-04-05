// IMPORTANT VALUES
// 224 = status byte for pitch bend change, channel 1
// 8192 = decimal representation of "resting" position
// for pitch bend wheel (2000H)
// 16383 = max bend value (bend value is 14 bits wide)

MidiOut midiOut;
MidiMsg midiMsg;

Hid hid;
HidMsg hidMsg;

int bendValue, lsb, msb;

// open a midi output and open the joystick - bail if something doesn't work

if(!midiOut.open(0)) me.exit();
if(!hid.openJoystick(0)) me.exit();

<<<hid.name()>>>; // tell us the joystick's name

// helper function to construct and send midi messages
fun void sendMsg(MidiOut midiOut, MidiMsg msg, int data1, int data2, int data3) {
  data1 => msg.data1;
  data2 => msg.data2;
  data3 => msg.data3;
  midiOut.send(msg);
}

// event loop

while(true) {
  hid => now;

  while(hid.recv(hidMsg)) {
    if(hidMsg.isAxisMotion()) {
      if(hidMsg.which == 1 && hidMsg.axisPosition <= 0) {
        ( (Std.fabs(hidMsg.axisPosition) * 8191) + 8192) $ int => bendValue;
      }

      else if(hidMsg.which == 1 && hidMsg.axisPosition > 0) {
        ((-1 * (Std.fabs(hidMsg.axisPosition) * 8191)) + 8192) $ int => bendValue;
      }

      // mask bendValue with 1111111 to get the least significant bits
      bendValue & 127 => lsb;

      // shift bendValue 7 bits right to get the most significant bits
      bendValue >> 7 => msb;

      // send the message
      sendMsg(midiOut, midiMsg, 224, lsb, msb);
    }
  }
}