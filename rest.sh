atrocity_rest() {
	curl -X "$1" "https://discord.com/api/v10/$2" -H "authorization: Bot $ATROCITY_TOKEN" -H "content-type: application/json" --data "$3" 2>/dev/null
}
