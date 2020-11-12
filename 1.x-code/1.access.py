# apt install python3-pip
# sudo pip3 install --upgrade pip
# sudo pip3 install netmiko

from netmiko import ConnectHandler
from all_devices import access_switches as devices

with open('config_file_access_switches') as f:
    config_list = f.read().splitlines()

for a_device in devices:
    session = ConnectHandler(**a_device)
    output = session.send_config_set(config_list)
    output += session.save_config()
    # print (output)