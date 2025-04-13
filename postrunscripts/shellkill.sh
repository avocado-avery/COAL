#!/usr/bin/env bash

if command -v killall &> /dev/null; then
        killall dash zsh ksh tcsh fish python python3 php php5 php8 php7 perl 
else
	pkill -f 'dash|zsh|ksh|tcsh|fish|python|python3|php|php5|php8|php7|perl'
fi
