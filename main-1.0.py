# pip install netmiko

from netmiko import ConnectHandler

with open('config_file') as f:
    commands_list = f.read().splitlines()

with open('devices_file') as f:
    devices_list = f.read().splitlines()

for devices in devices_list:
    print ('Connecting to device ' + devices)
    ip_address_of_device = devices
    ios_device = {
        'device_type': 'cisco_ios',
        'ip': ip_address_of_device,
        'username': 'siteadmin',
        'password': 'H0ck3y*'
    }

    session = ConnectHandler(**ios_device)
    output = session.send_config_set(commands_list)                     # send configs statements in the commands_file
    print (output)

# end of script


    output = session.send_config_set('username test password test')     # send a single config command

    commands = ['interface vlan2', 'no shut']                           # send multiple config commands
    output = session.send_config_set(commands)

    output = session.send_command('show ip int brief')                  # send a single show command