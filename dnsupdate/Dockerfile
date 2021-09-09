FROM python:buster

ADD dnsupdate/dnsupdate.py /usr/local/bin/dnsupdate
RUN chmod +x /usr/local/bin/dnsupdate

ENTRYPOINT ["dnsupdate"]