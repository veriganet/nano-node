#!/usr/bin/env python3

import CloudFlare
import logging
import os
import subprocess

"""
gets hostname of container
finds peering node number from container hostname / name
finds public IP address of the server that container is running
finds value of A record of peering address
compares public IP of the server with A record 
if they are different update A record with current public IP of the server
else do nothing
"""

log_level = os.environ.get('LOGGING', default="INFO")
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=log_level)


def get_env_variable(env):
    if not os.environ.get(env, None):
        return logging.error("%s is not defined!" % env)
    else:
        logging.debug("%s properly set." % env)
        return os.environ.get(env)


hostname = subprocess.getoutput('hostname')
#hostname = "kor-node-live-0"
logging.debug("Hostname %s" % hostname)
peer_number = hostname.split("-")[-1]
network = hostname.split("-")[-2]
logging.debug("Peer Number %s" % peer_number)

server_public_ip = subprocess.getoutput('dig +short myip.opendns.com @resolver1.opendns.com')

cloudflare_api_token = get_env_variable('CLOUDFLARE_API_TOKEN')
zone_name = get_env_variable('CLOUDFLARE_ZONE_NAME')
zone_id = get_env_variable('CLOUDFLARE_ZONE_ID')
abbreviation = get_env_variable('ABBREVIATION')
dns_name = "%s-peering%s.%s" % (abbreviation, peer_number, zone_name)

# init cloudflare api
cf = CloudFlare.CloudFlare(token=cloudflare_api_token)

# get current A record from cloudflare
logging.info("Getting DNS record information...")
try:
    params = {'name': dns_name, 'match': 'all', 'type': "A"}
    dns_records = cf.zones.dns_records.get(zone_id, params=params)
    logging.debug("dns_records %s" % dns_records)
except CloudFlare.exceptions.CloudFlareAPIError as e:
    logging.error('/zones/dns_records %s - %d %s - api call failed' % (dns_name, e, e))

current_dns_record = dns_records[0]['content']


if server_public_ip != current_dns_record:
    logging.info("Server Public IP: %s" % server_public_ip)
    logging.info("Current DNS A Record: %s" % current_dns_record)
    logging.info("Server Public IP is different then current DNS A record!")

    dns_record_id = dns_records[0]['id']
    dns_data = {
        'name': dns_name,
        'type': "A",
        'content': server_public_ip
    }

    logging.info("Updating DNS A record...")
    try:
        dns_record = cf.zones.dns_records.put(zone_id, dns_record_id, data=dns_data)
    except CloudFlare.exceptions.CloudFlareAPIError as e:
        logging.error('/zones.dns_records.put %s - %d %s - api call failed' % (dns_name, e, e))
else:
    logging.info("Server Public IP: %s" % server_public_ip)
    logging.info("Current DNS A Record: %s" % current_dns_record)
    logging.info("Looks good! Doing nothing.")
