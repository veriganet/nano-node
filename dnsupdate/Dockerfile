FROM python:buster

ADD dnsupdate.py /usr/local/bin/dnsupdate
RUN chmox +x /usr/local/bin/dnsupdate

ENTRYPOINT ["dnsupdate"]