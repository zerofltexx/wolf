#!/bin/sh
# Rebuild steam:fullscreen-fix-icu after a `docker prune -a` removed it.
# The build is a few seconds (FROM steam:edge, an apt install and two small
# layers). Then relaunch Steam.
#
# The tag has to match `image =` on the Steam apps in Wolf's config.toml.
set -e
cd "$(dirname "$0")"
docker image inspect ghcr.io/games-on-whales/steam:edge >/dev/null 2>&1 \
  || docker pull ghcr.io/games-on-whales/steam:edge
docker build -t steam:fullscreen-fix-icu .
echo "done, relaunch Steam from Moonlight to pick it up"
