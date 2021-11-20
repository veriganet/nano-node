FROM 776553443280.dkr.ecr.eu-west-1.amazonaws.com/kor-node:V22.1

ENV ABBREVIATION=""
ENV PRIVATE_KEY_REP0=""
ENV PRIVATE_KEY_REP1=""
ENV PRIVATE_KEY_REP2=""

RUN apt update -y
RUN apt install curl -y
RUN apt install jq -y

ADD preprep/entry_preprep.sh /usr/bin/entry_preprep.sh
RUN chmod +x /usr/bin/entry_preprep.sh

ENTRYPOINT ["/usr/bin/entry_preprep.sh"]
