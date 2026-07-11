#!/bin/bash
# Automated smoke test for the phpmyadmin container.
# Builds the image, runs it, waits for apache to come up on port 80 and
# asserts that the phpMyAdmin app page actually renders (not just apache).
set -e

IMG=phpmyadmin-test
CN=phpmyadmin-test-run

cleanup() { docker rm -f "$CN" >/dev/null 2>&1 || true; }
trap cleanup EXIT

fail() { echo "FAIL: $1"; exit 1; }

# raw HTTP GET over bash /dev/tcp (base image has neither wget nor curl)
http_get() {
  docker exec "$CN" bash -c '
    p="$1"
    exec 3<>/dev/tcp/127.0.0.1/80
    printf "GET %s HTTP/1.0\r\nHost: localhost\r\n\r\n" "$p" >&3
    cat <&3
  ' _ "$1"
}

echo ">> building image"
docker build -t "$IMG" .

echo ">> starting container"
docker rm -f "$CN" >/dev/null 2>&1 || true
docker run -d --name "$CN" \
  -e DISABLE_TLS=disable \
  -e SECRET=testblowfishsecret0123456789abcd \
  "$IMG" >/dev/null

echo ">> waiting for apache to listen on 80 (up to 120s)"
up=0
for _ in $(seq 1 60); do
  if docker exec "$CN" bash -c 'exec 3<>/dev/tcp/127.0.0.1/80' 2>/dev/null; then up=1; break; fi
  sleep 2
done
[ "$up" = 1 ] || fail "apache did not start listening on 80 in time"

echo ">> assert: container is running"
[ "$(docker inspect -f '{{.State.Running}}' "$CN")" = true ] || fail "container not running"
echo "ok - container running"

echo ">> assert: HTTP GET / returns a status line"
status=$(http_get / | head -1 | tr -d '\r')
echo "$status" | grep -q '^HTTP/' || fail "no HTTP status line (got: $status)"
echo "ok - status line: $status"

echo ">> assert: served HTML contains phpMyAdmin"
http_get /phpmyadmin/ | grep -q 'phpMyAdmin' || fail "phpMyAdmin app page did not render"
echo "ok - phpMyAdmin page rendered"

echo ">> assert: no PHP Fatal in apache error log"
docker exec "$CN" tail -n 200 /var/log/apache2/error.log 2>/dev/null | grep -i 'PHP Fatal' \
  && fail "PHP Fatal error found in apache error log" || true
echo "ok - no PHP Fatal in error log"

echo ""
echo "ALL TESTS PASSED"
