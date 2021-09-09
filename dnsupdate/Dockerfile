FROM python:buster

ADD dnsupdate/dnsupdate.py /usr/local/bin/dnsupdate
RUN chmox +x /usr/local/bin/dnsupdate

ENTRYPOINT ["dnsupdate"]