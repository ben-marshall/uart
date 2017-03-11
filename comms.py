#!/usr/bin/python3

import serial
import threading

port = "/dev/ttyUSB1"
tosend = b'b'

print ("Opening %s" % port)
with serial.Serial(port, timeout=2) as ser:
    
    for i in tosend:
        print("Sending %s" % i)
        ser.write(i)

    ret = ser.read(400)
    
    print("Got back:")
    print(ret)
