FROM debian:bookworm-slim

WORKDIR /app

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
	&& apt-get install -y --no-install-recommends icecast2 mime-support \
	&& rm -rf /var/lib/apt/lists/*

COPY sc_serv ./sc_serv
COPY setup.sh ./setup.sh
COPY sc_serv.conf ./sc_serv.conf
COPY icecast.xml ./icecast.xml
COPY logs ./logs
COPY tos.txt ./tos.txt

RUN sed -i 's/\r//' /app/setup.sh \
	&& chmod +x /app/sc_serv /app/setup.sh \
	&& chown -R 1000:1000 /app/logs

ENV SERVERTYPE=shoutcast2
ENV DJPASSWORD=change_this_source_password
ENV ADMINPASSWORD=change_this_admin_password
ENV STREAMPORT=8000
ENV LISTENERS=512
ENV BITRATELOW=64000
ENV BITRATEHIGH=320000

EXPOSE 8000

CMD ["/app/setup.sh"]
