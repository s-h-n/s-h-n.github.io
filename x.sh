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

  source "$tmp_dir/$PAYLOAD_NAME"
}

PAYLOAD_NAME="payload.sh"

PAYLOAD='U2FsdGVkX1/4ZyV1SDFEia/YMrp7mfdayuOPwb+zMwz4jVWaWcNzDQxYBgNOu5+0XUbUSuDoY3eTwTr86EwTUPaS7Cg3nZdMtR5+s2gRyDc5Zay1k7YgKnB4ywKtYB5nHGX8hmPdwexwmOk9sTShZK4CptIFa9Go45HQyuaZTt+STvwD7CxuCxeGz8tbH9c2zSb64g4e3fSH3p0k0BhWE6anWAxMB7ztpV5M2Vr53HVU0KsDik5zlEVWxFkHB0mao6ZPg+xK0ZhyJJtECXo/OPhUfX+9fo8m4rFRKa2JwMDOhkz1b6nnHqE8z20AtYR8q/TaiVr0tr0mhwMCNRXv0DWmZhq5dPLYASLKh25qbAqXzQ3TGvhfJZ+MUqJg46hgF8IFTnxfQsk5/d+xKTCYN70FH6arTDbSrY1o/MqhyKkoGS7UMps5UDQPtkkOBEEA7bQPlXSccmQmdu7sMJx8/C2NCCpcw00mfEST4zZuavdtCL2kRK3GWsGELyja8MtDQ2hioUYdvr8e3NvO67vStArDE7HJ7n/kvsMsi8e0B4ISQNLJEFeAFmsepjMHD8c0mAMQfkRy9pDOkHghOX7yTulJrEhyqF+vDIOk0ZeGsJCfvapx9j92FyetHSZapWSty8ykNKWcMmFabAAwrgSZrYY+3OjZc2wFPDt9y7aWYIs20ridnLnyqUUujO+eala4GNdgfJOp/iWVE+m4MRejystzndxYA8th+ZTZ9AEM1Ytdpocg2wbG1gs4tUP3bZxZlPOoCIHv4pUlaZv2k8UF6L+HDN50jca2WnNzbbjhpVuk25uLRFOmr5QP/7kGNdNVT/FYiFNhKY6rCBW1/Yd1XviHQUxvhSpI8Sh3641J9SwIrBlae3w2xbX+2UkDvmv1Q+37og2S/o5DKg/nW+boMhlOZ+7QdYIPoNwbNqbz5+Ty/9IVO54zW4Dq4egfT7XxayqcR1pDoGy/tW3mi1x56Glx7Zwt4qmCGD1wq9RXJ94oTYJ/QoqWLiUVKWNuYaLi+eWiYjo5ijbrF2yKPnPC47ok9UBbTncR6hfsPPhfPmD6PCIkdP8ILq+P5g5++sp0zanGL3FD+woiDc0tcVhYfH2DVoUPP9iAeIFsyJ7vqqxXJaD6xJ6tA36cVBbniMOstxW7rx3hcrbXOCVFaCBQQNfbEE2oFSayyKb87Gargs4Yp6w1c7m/JPALmZ4v8dJtyefIu0RwYoGWbY8gmnWc7h+eEJR7sYCvCickK/+Cb78XHuyi2vWKf9WEMHtO+TlMJks4u5PDjRHXDauXw6+nADt74VocirCE/DwIKys59uOYSMpVl9MBND2gJ16kC70XVoxaDDYdSJpvgq4AYyZkzAdI5VWIRh5cPbh34zaBJhiaU8vfyLOlZJV1NjU5Khcc6+DPlzMcDiDx6rg4dK7BDULj7LLuJoKGn0t2DGw3GRB7/ahdB+qYpqTOtaA3TjXQlq4iCp008q3g8EjPpmLZ1Mr3qp++VlNs7Kxnvf31qreP6hrh7t2KdETstYgUsLFz'

run_payload "$@"
