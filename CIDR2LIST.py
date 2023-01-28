import ipaddress
import sys
try:
    Input = ipaddress.ip_network(sys.argv[1])
    for IPS in Input.hosts():
        print(IPS)
except:
    print('No valid CIDR found!')
    print('Script.py [IPv4/IPv6 CIDR]')