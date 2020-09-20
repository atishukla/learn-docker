FROM ubuntu:18.04

CMD ["python3", "/entrypoint.py"]

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends fontconfig python3 python3-jinja2 \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV HELLO    FOO

COPY entrypoint.py /