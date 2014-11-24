import skiff
from info import api_key

s = skiff.rig(api_key)
my_droplet = s.Droplet.create({
    "name": "Testing",
    "region": "ams2",
    "size": "512mb",
    "image": "ubuntu-14-04-x64",
    "ssh_keys": [s.Key.get('my public key')],
    "backups": False,
    "ipv6": False,
})
print("Created, Waiting...")
my_droplet.wait_till_done()
print my_droplet.refresh().networks["v4"][0]["ip_address"]
