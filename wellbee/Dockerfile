FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    default-libmysqlclient-dev \
    ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /wellbee

COPY requirements.txt /wellbee/
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . /wellbee/

RUN chmod 755 entrypoint.sh entrypoint.prod.sh

EXPOSE 8000

CMD ["./entrypoint.prod.sh"]
