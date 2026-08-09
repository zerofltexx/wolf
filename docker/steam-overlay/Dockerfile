# steam:fullscreen-fix-icu -- thin overlay of games-on-whales/steam:edge.
#
# Adds two things the base image lacks, both hit while running Ryujinx as a
# non-Steam shortcut inside a Wolf session:
#   1. libicu, without which any .NET app aborts at startup
#   2. a Sway rule so native (non-Steam) windows are given fullscreen
#
# Also carries the Big Picture fullscreen-restore fix
# (gow branch fix/steam-bigpicture-fullscreen-restore).
#
# Build:  docker build -t steam:fullscreen-fix-icu docker/steam-overlay
FROM ghcr.io/games-on-whales/steam:edge

# .NET hard-aborts before reaching Main when ICU is missing:
#   "Couldn't find a valid ICU package installed on the system"
# The Arch host has libicu so Ryujinx runs fine there, but the base image is
# Ubuntu 25.04 with no libicu, so launching it through Wolf died instantly and
# Steam surfaced no error. Setting DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 gets
# past the abort but then throws CultureNotFoundException the moment anything
# formats a string with a real culture, so install ICU instead.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libicu76 \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig -p | grep -q libicuuc

COPY --chmod=777 steam-fullscreen-watch.sh /opt/gow/steam-fullscreen-watch.sh

# The stock config only fullscreens windows whose class matches steam_app_*,
# which Steam sets on games it owns. A non-Steam shortcut keeps its toolkit's
# own class (Ryujinx reports "Ryujinx"), so it opens tiled behind Big Picture:
# the game runs and audio plays, but nothing is ever shown.
RUN printf '\n# Restore Big Picture fullscreen after a game exits (steam-fullscreen-watch.sh)\nexec /opt/gow/steam-fullscreen-watch.sh\n' >> /cfg/sway/config \
    && printf '\n# Non-Steam shortcuts keep their own window class, so the steam_app_ rule\n# never matches them.\nfor_window [class="Ryujinx"] fullscreen enable\n' >> /cfg/sway/config \
    && grep -q 'steam-fullscreen-watch.sh' /cfg/sway/config \
    && grep -q 'class="Ryujinx"' /cfg/sway/config
