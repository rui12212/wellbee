#!/bin/sh

set -e

echo "===1最新コードの取得==="
git pull origin main

echo "===2 app-reviewビルド・起動==="
docker compose -f docker-compose.prod.yml \
  --profile review up -d --build app-review

echo "===3 nginx設定更新（リビルドなし）==="
docker cp nginx/conf.d/default.conf \
  nginx:/etc/nginx/conf.d/default.conf
docker exec nginx nginx -s reload

echo "===4 起動確認 ==="
docker ps

echo "===5 動作確認 ==="
curl -s -o /dev/null -w "v4 API: %{http_code}\n" \
  https://api.wellbee-studio.com/api/v4/attendances/course/
curl -s -o /dev/null -w "既存API: %{http_code}\n" \
  https://api.wellbee-studio.com/attendances/course/


echo "===完了==="