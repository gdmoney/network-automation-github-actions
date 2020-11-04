# pip install netmiko

from netmiko import ConnectHandler
from my_devices_2 import device_list as devices

with open('C:/Users/gdavitiani/Documents/GitHub/network-automation-github-actions/config_file') as f:
    config_list = f.read().splitlines()

for a_device in devices:
    session = ConnectHandler(**a_device)
    output = session.send_config_set(config_list)
    output += session.save_config()
    print (output)