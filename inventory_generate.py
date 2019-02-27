#!/usr/bin/python
import siptracklib
import argparse
import yaml
import os

curr_dir = os.getcwd()
file_name = "inventory.yml"
config_file = os.path.join(os.getcwd(), file_name)
default_user = 'itek'


class siptrack_search():

    def getinfo(self, host, user):
        st = siptracklib.fconnect()
        res = st.quicksearch(host)
        if len(res) != 0:
            device = res[0]
            passwords = [p for p in device.listChildren() if
                         p.attributes.get('username') == user and not
                         (p.attributes.get('description') == 'drac' or
                         p.attributes.get('description') == 'iDRAC'
                         or p.attributes.get('description') == 'mysql'
                         or p.attributes.get('description') == 'cimc')]
            if passwords:
                pp = passwords[0]
                return pp.password
            else:
                return '[Error]: User-id not found.'
        else:
            return '[Error]: Host not found.'
        st.logout()


class config_gen(siptrack_search):

    def __init__(self):
        pass

    def read_config(self):
        hostlist = []

        with open(config_file, 'r') as ymlfile:
            cfg = yaml.load(ymlfile)

        for section in cfg:
            for i in range(len(cfg[section]['hosts'])):
                hostlist.append(cfg[section]['hosts'][i])
        data = {}
        data['_meta'] = {}
        data['_meta']['hostvars'] = {}
        hostvarsvariables = []
        for hts in hostlist:
            password = self.getinfo(hts, default_user)
            hostvarsvariables.append({hts: {'keys': 'false',
                                            'ansible_connection': 'ssh',
                                            'ansible_ssh_port': 22,
                                            'ansible_become': 'true',
                                            'ansible_ssh_user': default_user,
                                            'ansible_ssh_pass': password,
                                            'ansible_sudo_user': default_user,
                                            'ansible_sudo_pass': password,
                                            }})

        for i in range(len(hostvarsvariables)):
            data['_meta']['hostvars'].update(hostvarsvariables[i])
        a = cfg
        a.update(data)
        print a


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', action='store_true')
    args = parser.parse_args()
    if args.list:
        config_gen().read_config()
    if args.host:
        print {'_meta': {'hostvars': {}}}
