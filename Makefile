docker-dnsupdate:
	podman build . -t nano-node:dnsupdate-latest -f dnsupdate/Dockerfile

dockerrun-dnsupdate:
	podman run -it --hostname kor-node-live-0 localhost/nano-node:dnsupdate-latest bash