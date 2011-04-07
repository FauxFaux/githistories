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

	g merge dev
	git branch -d dev

	commits "ninth on master"

	g merge patch
	git branch -d patch
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
	git checkout dev
	g rebase $master
	master
	g merge dev
	git branch -d dev

	commits "ninth on master"

	git checkout patch
	g rebase $master
	master
	g merge patch
	git branch -d patch
}

onlymerges() {
	echo
}

supercommits() {
	echo
}

naturist
flat

