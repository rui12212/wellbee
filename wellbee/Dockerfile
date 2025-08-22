FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    default-libmysqlclient-dev \
 && rm -rf /var/lib/apt/lists/*

# Python の出力をバッファリングせず直接ログ出力する
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN mkdir /wellbee
# 
WORKDIR /wellbee

# Copy the requirements file first (better caching)
COPY requirements.txt /wellbee/

RUN pip install --upgrade pip 

# pip をアップグレードし、requirements.txt から必要なパッケージをインストール
RUN pip install --no-cache-dir -r requirements.txt

COPY . /wellbee/

# Expose the Django port
EXPOSE 8000
 
# Run Django’s development server

# ---------DEV---------
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# ---------PRODUCTION---------
# CMD ["./entrypoint.prod.sh"]

# entrypoint.shに実行権限を付与 for 自動migration
# ---------DEV---------
RUN chmod 755 entrypoint.sh

# ---------PRODUCTION---------
# RUN chmod 755 entrypoint.prod.sh

# init.sqlをコンテナの/docker-entrypoint-init.db.dと共有
# COPY init.sql /docker-entrypoint-initdb.d