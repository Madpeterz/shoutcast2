#!/bin/sh
set -eu

SERVERTYPE="${SERVERTYPE:-shoutcast2}"

escape_for_sed() {
	printf '%s' "$1" | sed 's/[&/]/\\&/g'
}

render_template() {
	template_file="$1"
	target_file="$2"
	shift 2

	tmp_file="$(mktemp)"
	sed "$@" "$template_file" > "$tmp_file"
	mv "$tmp_file" "$target_file"
}

validate_numeric() {
	value="$1"
	name="$2"
	case "$value" in
		''|*[!0-9]*)
			echo "$name must be numeric" >&2
			exit 1
			;;
	esac
}

case "$SERVERTYPE" in
	shoutcast2|icecast)
		;;
	*)
		echo "SERVERTYPE must be shoutcast2 or icecast" >&2
		exit 1
		;;
esac

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

case "$SERVERTYPE" in
	shoutcast2)
		CONF_FILE="${CONF_FILE:-sc_serv.conf}"
		validate_numeric "$STREAMPORT" STREAMPORT
		validate_numeric "$LISTENERS" LISTENERS
		validate_numeric "$BITRATELOW" BITRATELOW
		validate_numeric "$BITRATEHIGH" BITRATEHIGH

		render_template "$CONF_FILE" "$CONF_FILE" \
			-e "s/\[\[DJPASSWORD\]\]/$(escape_for_sed "$DJPASSWORD")/g" \
			-e "s/\[\[ADMINPASSWORD\]\]/$(escape_for_sed "$ADMINPASSWORD")/g" \
			-e "s/\[\[STREAMPORT\]\]/$(escape_for_sed "$STREAMPORT")/g" \
			-e "s/\[\[LISTENERS\]\]/$(escape_for_sed "$LISTENERS")/g" \
			-e "s/\[\[BITRATELOW\]\]/$(escape_for_sed "$BITRATELOW")/g" \
			-e "s/\[\[BITRATEHIGH\]\]/$(escape_for_sed "$BITRATEHIGH")/g"

		chmod a+x sc_serv
		exec ./sc_serv "$CONF_FILE"
		;;
	icecast)
		CONF_FILE="${CONF_FILE:-icecast.xml}"
		validate_numeric "$STREAMPORT" STREAMPORT
		validate_numeric "$LISTENERS" LISTENERS

		render_template "$CONF_FILE" "$CONF_FILE" \
			-e "s/\[\[DJPASSWORD\]\]/$(escape_for_sed "$DJPASSWORD")/g" \
			-e "s/\[\[ADMINPASSWORD\]\]/$(escape_for_sed "$ADMINPASSWORD")/g" \
			-e "s/\[\[STREAMPORT\]\]/$(escape_for_sed "$STREAMPORT")/g" \
			-e "s/\[\[LISTENERS\]\]/$(escape_for_sed "$LISTENERS")/g"

		exec icecast2 -c "$CONF_FILE"
		;;
esac