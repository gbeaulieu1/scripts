#!/bin/bash

function jsonValue() {
	KEY=$1
	num=$2
	awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | sed -n ${num}p
}

function delete(){
	# Delete default labels
	eval 'for word in '$labels'; do word=${word// /%20}; curl --user "$USER:$PASS" --include --request DELETE "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels/$word"; done'
}

function add_defaults(){
	# Create priority level labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"priority: critical", "color":"ff0000"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"priority: high", "color":"ff6666"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"priority: low", "color":"ffb3b3"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	
	# Create Status labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"blocked", "color":"66ffcc"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"blocker", "color":"66ffcc"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"question", "color":"66ffcc"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"needs estimate", "color":"66ffcc"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"needs revision", "color":"66ffcc"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"

	# Create Work-Type labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"pattern", "color":"ffcc00"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"theming", "color":"ffcc00"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"migration", "color":"ffeb99"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"drupal site building", "color":"ffeb99"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"UX/design", "color":"ffd9b3"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"content", "color":"ffa64d"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"documentation", "color":"ff8000"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	
	# Create DevOps labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"deployment", "color":"00e1ff"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"needs manual deployment", "color":"00e1ff"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"hotfix", "color":"00e1ff"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"

	# Create Planning labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"epic", "color":"cc0066"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"sprint", "color":"cc0066"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"sprint retrospective", "color":"cc0066"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"

	# Create Supplementary labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"security", "color":"b9b9b9"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"SEO", "color":"b9b9b9"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"

	# Create Inactive labels
	curl --user "$USER:$PASS" --include --request POST --data '{"name":"duplicate", "color":"3a2a9e"}' "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels"
}

echo -n "GitHub User: "
read USER

# Generate a personal access token at https://github.com/settings/tokens
echo -n "GitHub Password (or token if using 2fa): "
read -s PASS
echo

echo -n "GitHub Repo (expected format is 'owner/repository' e.g. 'isovera/intralinks'): "
read REPO

REPO_USER=$(echo "$REPO" | cut -f1 -d /)
REPO_NAME=$(echo "$REPO" | cut -f2 -d /)

# Get all labels
labels=$(curl --user "$USER:$PASS" "https://api.github.com/repos/"$REPO_USER"/"$REPO_NAME"/labels" | jsonValue name)

if [[ $* == *--nodelete* ]]; then
	read -e -p 'Are you sure you want to run without resetting labels? (Y/N):' ANSWER
	if [[ $ANSWER =~ ^[Nn]$ ]]; then
		echo 'Aborting'
		exit	
	else
		echo 'Running without resetting labels'
		add_defaults
	fi
else
	delete
	add_defaults
	
fi


