#!/bin/bash
loginctl lock-session "$(loginctl list-sessions --no-legend | grep "$(whoami)" | head -1 | awk '{print $1}')"
