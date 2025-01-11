all: clean compile


clean:
	rm -rf lua/*

compile:
	sh transpile.sh laux lua
