# pip install netmiko

import threading
from netmiko import ConnectHandler
from my_devices_2 import device_list as devices

def task(a_device):
    with open('config_file') as f:
        config_list = f.read().splitlines()

    session = ConnectHandler(**a_device)
    output = session.send_config_set(config_list)
    # output = session.send_command('write mem')                  // send a single global command instead
    # print (output)

def main():
    for a_device in devices:
        my_thread = threading.Thread(target=task, args=(a_device,))
        my_thread.start()

    main_thread = threading.currentThread()
    for some_thread in threading.enumerate():
        if some_thread != main_thread:
            print(some_thread)
            some_thread.join()

if __name__ == "__main__":
    main()