_atrocity_init_file="${BASH_SOURCE[0]}"
if [ "$(basename -- "$_atrocity_init_file")" != "load.sh" ] || [ "${#BASH_SOURCE[@]}" -lt 2 ]; then
	echo "ERROR: Atrocity must be sourced. If you have atrocity in a sub module, use \`source \"\$(dirname -- \"\$0\")\"/atrocity/load.sh\`"
	exit 1
fi
_atrocity_base="$(dirname -- "$(readlink -f -- _atrocity_init_file)")"

source "$_atrocity_base"/logger.sh
source "$_atrocity_base"/connect.sh

atrocity_debug "Loaded atrocity from $_atrocity_base"
_atrocity_prepare
