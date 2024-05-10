_atrocity_log_output="${ATROCITY_LOG:-$(tty)}"
if [ "$_atrocity_log_output" = "not a tty" ]; then
	exec {_atrocity_log_descriptor}>&1
else
	exec {_atrocity_log_descriptor}>"$_atrocity_log_output"
fi

atrocity_debug() {
	printf 'DBG : %s\n' "${*}" >&"$_atrocity_log_descriptor"
}
