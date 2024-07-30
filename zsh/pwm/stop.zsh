#!/usr/bin/env zsh

MYDIR=${0:a:h}

pid=$(< ${MYDIR}/run_zsh_pid)

if [[ -n "$pid" ]]; then
    kill -SIGUSR1 $pid
else
    echo "No PID found. Is run.zsh running?"
fi