#!/bin/sh
set -eu
cd "$(dirname "$0")"
demo_check_dir=$(mktemp -d)
trap 'rm -rf "$demo_check_dir"' EXIT
swiftc Sources/StreamHealthDemo/TradeStreamHealth.swift Tests/main.swift -o "$demo_check_dir/checks"
"$demo_check_dir/checks"
