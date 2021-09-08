#!/usr/bin/env python3

import logging
import os
import subprocess

log_level = os.environ.get('LOGGING', default="INFO")
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=log_level)

hostname = subprocess.getoutput('hostname')
#hostname = "kor-node-live-0"
logging.debug("Hostname %s" % hostname)
peer_number = hostname.split("-")[-1]
logging.debug("Peer Number %s" % peer_number)

server_public_ip = subprocess.getoutput('dig +short myip.opendns.com @resolver1.opendns.com')
current_dns_record = subprocess.getoutput('dig +short kor-peering%s.verigasvc.com' % peer_number)

if server_public_ip != current_dns_record:
    logging.info("Server Public IP: %s" % server_public_ip)
    logging.info("Current DNS A Record: %s" % current_dns_record)
    logging.info("Server Public IP is different then current DNS A record!")
    logging.info("Updating DNS A record...")
else:
    logging.info("Looks good! Doing nothing.")
