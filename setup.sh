#!/bin/sh
set -eu

CONF_FILE="${CONF_FILE:-sc_serv.conf}"

# Required secrets
: "${DJPASSWORD:?DJPASSWORD is required}"
: "${ADMINPASSWORD:?ADMINPASSWORD is required}"

# Optional values with sensible defaults
STREAMPORT="${STREAMPORT:-8000}"
LISTENERS="${LISTENERS:-512}"
BITRATELOW="${BITRATELOW:-64000}"
BITRATEHIGH="${BITRATEHIGH:-320000}"

if [ "$DJPASSWORD" = "$ADMINPASSWORD" ]; then
	echo "ADMINPASSWORD must be different from DJPASSWORD" >&2
	exit 1
fi

for n in "$STREAMPORT" "$LISTENERS" "$BITRATELOW" "$BITRATEHIGH"; do
	case "$n" in
		''|*[!0-9]*)
			echo "Numeric env values are required for STREAMPORT, LISTENERS, BITRATELOW, BITRATEHIGH" >&2
			exit 1
			;;
	esac
done

escape_for_sed() {
	printf '%s' "$1" | sed 's/[&/]/\\&/g'
}

tmp_file="$(mktemp)"
sed \
	-e "s/\[\[DJPASSWORD\]\]/$(escape_for_sed "$DJPASSWORD")/g" \
	-e "s/\[\[ADMINPASSWORD\]\]/$(escape_for_sed "$ADMINPASSWORD")/g" \
	-e "s/\[\[STREAMPORT\]\]/$(escape_for_sed "$STREAMPORT")/g" \
	-e "s/\[\[LISTENERS\]\]/$(escape_for_sed "$LISTENERS")/g" \
	-e "s/\[\[BITRATELOW\]\]/$(escape_for_sed "$BITRATELOW")/g" \
	-e "s/\[\[BITRATEHIGH\]\]/$(escape_for_sed "$BITRATEHIGH")/g" \
	"$CONF_FILE" > "$tmp_file"
mv "$tmp_file" "$CONF_FILE"

chmod a+x sc_serv
./sc_serv "$CONF_FILE"