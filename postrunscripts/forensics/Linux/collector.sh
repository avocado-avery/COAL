#!/bin/bash

# Run UAC from the Remote share /root/HOSTS
mkdir -p "/root/HOSTS/$(hostname)"
cd "/root/HOSTS/Tools/uac/"
source uac -p ir_triage /root/HOSTS/$(hostname)
