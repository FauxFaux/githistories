#!/bin/sh
set -eu

NOW=$(($(date +%s)-(60)))
TZO=$(date +%z)

g() {
	if [ "$1" = "commit" ]; then
		touch $NOW
		git add $NOW
	fi
	GIT_COMMITTER_DATE="$NOW $TZO" \
		GIT_AUTHOR_DATE="$NOW $TZO" \
		git "$@"
	NOW=$(($NOW+1))
}

commits() {
	for a in "$@"; do
		g commit -m "$a"
	done
}

rm -rf tmp
mkdir tmp
cd tmp
git init
commits "bleh"

initial() {
	git checkout --orphan $master
	commits "initial commit on $master"
}

master() {
	git checkout $master
}

merge() {
	g merge "$@"
	git branch -d $1
}

naturist() {
	master="naturist"
	initial
	commits "first" "second"
	git checkout -b dev
	commits "third" "fourth"
	git branch patch
	master
	commits "fifth on master"
	git checkout dev
	commits "sixth on dev"
	git checkout patch
	commits "seventh on patch"
	master
	commits "eighth on master"

	merge dev

	commits "ninth on master"

	merge patch
}

flat() {
	master="flat"
	initial
	commits "first" "second"
	git checkout -b dev
	commits "third" "fourth"
	git branch patch
	master
	commits "fifth on master"
	git checkout dev
	commits "sixth on dev"
	git checkout patch
	commits "seventh on patch"
	master
	commits "eighth on master"
	g rebase $master dev
	master
	merge dev

	commits "ninth on master"

	g rebase $master patch
	master
	merge patch
}

onlymerges() {
	master="onlymerges"
	initial
	git checkout -b firstandsecond
	commits "first" "second"
	master
	merge firstandsecond --no-ff
	git checkout -b dev
	commits "third" "fourth"
	git branch patch
	git checkout -b fifth
	commits "fifth on master"
	master
	merge fifth --no-ff
	git checkout dev
	commits "sixth on dev"
	git checkout patch
	commits "seventh on patch"
	master
	git checkout -b eigth
	commits "eighth on master"
	master
	merge eigth --no-ff
	merge dev
	git checkout -b ninth
	commits "ninth on master"
	master
	merge ninth --no-ff
	merge patch --no-ff
}

supercommits() {
	master="supercommits"
	initial
	commits "first" "second"
	git checkout -b dev
	commits "third" "fourth"
	git branch patch
	master
	commits "fifth on master"
	git checkout dev
	commits "sixth on dev"
	git checkout patch
	commits "seventh on patch"
	master
	commits "eighth on master"
	g rebase $master dev
	master
	merge dev --no-ff

	commits "ninth on master"

	g rebase $master patch
	master
	merge patch --no-ff
}

lg() {
	git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' "$@" | cat
}
CMDS='naturist flat onlymerges supercommits'
for cmd in naturist flat onlymerges supercommits; do
	$cmd
done

lg $CMDS
echo
echo but..
lg --first-parent $CMDS

