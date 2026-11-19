#!/usr/bin/env sh
# Posts one category question (with `instructions`, which choice questions require) and asserts a 200
# whose body carries an answer for it.   LAYA_URL=http://localhost:8080 LAYA_API_KEY=... ./smoke.sh
set -eu
: "${LAYA_API_KEY:?set LAYA_API_KEY}"
out=$(mktemp)
code=$(curl -sS -o "$out" -w '%{http_code}' "${LAYA_URL:-http://localhost:8080}/v1/systemone" \
  -H "Authorization: Bearer $LAYA_API_KEY" -H 'Content-Type: application/json' \
  -d '{"model":"laya-multilingual","state":"Beitragsrechnung Nr. 4711 fuer den Zeitraum 01.01.2026 bis 31.12.2026, faellig am 15.01.2026.","questions":{"category":{"type":"choice","instructions":"Which category does this German insurance document belong to?","criteria":{"BILLING_AND_PAYMENT":"Premium invoices and payment confirmations.","CLAIM_DOCUMENTS":"Claim forms and evidence.","OTHER":"Anything else."}}}}')
[ "$code" = 200 ] || { echo "FAIL: HTTP $code"; cat "$out"; exit 1; }
grep -q '"choice"' "$out" || { echo "FAIL: no choice in body"; cat "$out"; exit 1; }
echo "OK: 200 $(cat "$out")"
