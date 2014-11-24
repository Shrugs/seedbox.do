import skiff
from time import sleep
from info import api_key

s = skiff.rig(api_key)
my_droplet = s.Droplet.create({
    "name": "Viking",
    "region": "ams2",
    "size": "512mb",
    "image": "ubuntu-14-04-x64",
    "ssh_keys": [s.Key.get('my public key')],
    "backups": False,
    "ipv6": False,
})
print("Created, Waiting...")
sleep(2)
my_droplet.wait_till_done(5)
my_droplet = my_droplet.reload()
print my_droplet.networks["v4"][0]["ip_address"]
