#!/usr/bin/env bash

# Utility Functions
sep () {
    echo "======================================================================================================="
}
dash_sep () {
    echo "-------------------------------------------------------------------------------------------------------"
}
empty_line () {
    echo ""
}

empty_line
sep
echo "Checking For Ping Shells"
sep
empty_line
echo -e "ss -a -p -f link"
empty_line
printf "%s\n" "$(ss -a -p -f link)"
dash_sep
echo -e "ss -a -p -f vsock"
empty_line
printf "%s\n" "$(ss -a -p -f vsock)"
dash_sep
echo -e "ss -a -p -f xdp"
empty_line
printf "%s\n" "$(ss -a -p -f xdp)"
dash_sep
empty_line


