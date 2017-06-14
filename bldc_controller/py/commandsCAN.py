import can
from math import*
import time
import struct
import matplotlib.pyplot as plt
import scipy.io as sio

cmd_SR_create = 0x10
cmd_SR_read = 0x11
cmd_SR_tr_off = 0x12
cmd_SR_tr_on = 0x13
cmd_IQ = 0x20
cmd_POS_ref = 0x22
cmd_POS_read = 0x32
cmd_SYN = 0x61
cmd_IMP_prms = 0x40
cmd_CUR_prms = 0x41
cmd_PS_offset = 0x50
cmd_MODE = 0x60

# Send reference on q current
def iq(bus, ref):
    ref_in_bytes = struct.pack('f', ref)
    msg = can.Message(arbitration_id = cmd_IQ, data = ref_in_bytes, extended_id = False)
    bus.send(msg)

# Send reference on pos
def pos_ref(bus, ref):
    ref_in_bytes = struct.pack('f', ref)
    msg = can.Message(arbitration_id = cmd_POS_ref, data = ref_in_bytes, extended_id = False)
    bus.send(msg)


# Read pos
def pos_read(bus):
    msg = can.Message(arbitration_id = cmd_POS_read, data =[], extended_id = False)
    bus.send(msg)
    while True:
        msg = bus.recv(1)
        if msg is not None and msg.arbitration_id == 0xa2:
            break
    print(struct.unpack('f', msg.data)[0])

    
# # Set joint damping
# def setB(bus, m_id, val):
#     val = max(min(val, B_Max), 0)
#     b_u16 = floor(val*65278/B_Max)
#     b1 = b_u16>>8
#     b2 = b_u16-(b1<<8)
#     checksum = calcChecksum([motor_id[m_id], B_ID, b1, b2])
#     ser.write(bytes([255, 255, motor_id[m_id], B_ID, b1, b2, checksum]))


# #Set joint position
# def setP(ser, m_id, val):
#     val = max(min(val, P_Max), 0)
#     p_u16 = floor(val*65278/P_Max)
#     b1 = p_u16>>8
#     b2 = p_u16-(b1<<8)
#     checksum = calcChecksum([motor_id[m_id], P_ID, b1, b2])
#     ser.write(bytes([255, 255, motor_id[m_id], P_ID, b1, b2, checksum]))

# # Read Signal Recorder buffer
# def src(ser, ch_id = 0, sig_id = 0, buff_size = 1000, freq = 20000, immediate_trig = True):
#     # Flush the buffer of the serial port
#     _ = ser.read(10000)
    
#     # Send the requirement for reading the buffer
#     cmd_id = cmd_SR_create
#     packet = formPacket([cmd_id, ch_id, sig_id] + list(struct.pack('IIB', buff_size, freq, immediate_trig)))
#     ser.write(packet)

#     # Read the one byte indicating the result
#     result = bool(ser.read(1)[0])

#     if not result:
#         print('The channel was not initialized!')

# # Disbale the signal trigger
# def sro(ser):
#     cmd_id = cmd_SR_tr_off
#     packet = formPacket([cmd_id])
#     ser.write(packet)


# # Enable the signal trigger
# def sri(ser):
#     cmd_id = cmd_SR_tr_on
#     packet = formPacket([cmd_id])
#     ser.write(packet)

# # Read Signal Recorder buffer
# def srr(ser, ch_id = 0, savemat = False):
#     # Flush the buffer of the serial port
#     _ = ser.read(10000)
    
#     # Send the requirement for reading the buffer
#     cmd_id = cmd_SR_read

#     fig = plt.figure()

#     captured_data = []

#     for i in range(len(ch_id)):
#         packet = formPacket([cmd_id, ch_id[i]])
#         ser.write(packet)

#         # Read the first four bytes indicating the size of the buffer
#         buff_size = int.from_bytes(ser.read(4), byteorder='big')

#         if buff_size == 0:
#             print('Buffer of zero size was returned. Either the channel is is out of range or the channel is not currently active.')
#             return

#         # Read the first four bytes indicating the size of the buffer
#         Ts = struct.unpack('f', ser.read(4))[0]

#         # Read the buffer
#         buff = ser.read(4 * buff_size)

#         # Convert the buffer of bytes to floats
#         data = struct.unpack(str(buff_size) + 'f', buff)

#         captured_data

#         if len(ch_id) > 1:
#             ax = fig.add_subplot(len(ch_id), 1, i+1)
#             ax.plot([1000*Ts*i for i in range(buff_size)], data)
#             ax.set_xlabel('Time [ms]')
#             ax.set_title('Channel: ' + str(ch_id[i]))
#             ax.grid()            
#         else:
#             plt.plot([1000*Ts*i for i in range(buff_size)], data)
#             plt.xlabel('Time [ms]')
#             plt.title('Channel: ' + str(ch_id[i]))
#             plt.grid()
#     plt.show()

#     # return data, Ts
