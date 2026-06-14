FROM debian:bookworm-slim

WORKDIR /app

COPY sc_serv ./sc_serv
COPY setup.sh ./setup.sh
COPY sc_serv.conf ./sc_serv.conf
COPY logs ./logs
COPY tos.txt ./tos.txt

RUN chmod +x /app/sc_serv /app/setup.sh

ENV DJPASSWORD=change_this_source_password
ENV ADMINPASSWORD=change_this_admin_password
ENV STREAMPORT=8000
ENV LISTENERS=512
ENV BITRATELOW=64000
ENV BITRATEHIGH=320000

EXPOSE 8000

CMD ["/app/setup.sh"]
