FROM docker.io/library/python:slim-buster

ADD dnsupdate/dnsupdate.py /usr/local/bin/dnsupdate
RUN chmod +x /usr/local/bin/dnsupdate

RUN apt update -y
RUN apt install dnsutils -y
RUN pip install CloudFlare

ENTRYPOINT ["dnsupdate"]