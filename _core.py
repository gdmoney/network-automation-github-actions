import threading
from netmiko import ConnectHandler
from _all_devices import core_switch as devices

command = 'config replace tftp://172.17.0.2/config_file_core_switch force'

def task(a_device):
    # with open('config_file_core_switch') as f:
        # config_list = f.read().splitlines()

    session = ConnectHandler(**a_device)
    output = session.send_config_set(command)
    output += session.save_config()
    # print (output)

def main():
    for a_device in devices:
        my_thread = threading.Thread(target=task, args=(a_device,))
        my_thread.start()

    main_thread = threading.current_thread()
    for some_thread in threading.enumerate():
        if some_thread != main_thread:
            print(some_thread)
            some_thread.join()

if __name__ == "__main__":
    main()