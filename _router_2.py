# apt install python3-pip
# sudo pip3 install --upgrade pip
# sudo pip3 install netmiko

import threading
from netmiko import ConnectHandler
from all_devices import router_2 as devices

def task(a_device):
    with open('config_file_router_2') as f:
        config_list = f.read().splitlines()

    session = ConnectHandler(**a_device)
    output = session.send_config_set(config_list)
    output += session.save_config()
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