import os


def find_aviliable_devices():
    pass

def write_devices_into_file(devices):
    #return path file
    pass

def read_file_with_information():
    pass

def find_type():
    pass

def find_space():
    pass

def find_etc():
    pass

def find_info_about_device():
    type = find_type()
    space = find_space()
    etc = find_etc()

    return type, space, etc


def find_information_about_devices():
    devices = find_aviliable_devices()
    file_with_information = write_devices_into_file(devices)
    type, space, etc = find_info_about_device(file_with_information)
    print(type, space, etc)
