import os
from os import path
import psutil

def find_aviliable_devices():
    all = psutil.disk_partitions()
    devices = []
    for i in range(len(all)):
            devices.append(all[i][0])
    return devices

def write_devices_into_file(devices):
    #return path file
    name = 'file.txt'
    f = open(name, "w+")
    for device in devices:
        f.write(str(device)+'\n')
    f.close()
    return os.path.abspath(name)

def read_file_with_information(file_with_information):
    with open(file_with_information, 'r') as myfile:
          data = myfile.read()

def find_type():
    pass

def find_space():
    pass

def find_etc():
    pass

def find_info_about_device(file_with_information):
    info = read_file_with_information(file_with_information)
    type = find_type(info)
    space = find_space(info)
    etc = find_etc(info)

    return type, space, etc


def find_information_about_devices(file = 'file.txt'):
    if not path.exists(file):
        devices = find_aviliable_devices()
        file_with_information = write_devices_into_file(devices)

#    type, space, etc = find_info_about_device(file_with_information)
#    print(type, space, etc)


if __name__ =="__main__":
    find_information_about_devices()
