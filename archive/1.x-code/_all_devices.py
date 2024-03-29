import keyring

username = 'siteadmin'
password = keyring.get_password('cisco', 'siteadmin')

ROUTER_1 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.254.1',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

ROUTER_2 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.254.5',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_CORE = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.1',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_1 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.11',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_2 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.12',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_3 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.13',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_4 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.14',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_5 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.15',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

SWITCH_ACCESS_6 = {
    'device_type': 'cisco_ios',
    'ip': '192.168.255.16',
    'username': username,
    'password': password,
    'default_enter': '\r\n'
    }

router_1 = [ROUTER_1]

router_2 = [ROUTER_2]

core_switch = [SWITCH_CORE]

access_switches = [
    SWITCH_ACCESS_1,
    SWITCH_ACCESS_2,
    SWITCH_ACCESS_3,
    SWITCH_ACCESS_4,
    SWITCH_ACCESS_5,
    SWITCH_ACCESS_6
    ]
