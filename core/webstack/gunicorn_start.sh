#!/usr/bin/env bash
cd "$( dirname "$0" )"
gunicorn --name webstack \
    --bind 127.0.0.1:6847 \
    --error-logfile "$(pwd)/../../logs/core/gunicorn.log" \
    --log-level warning \
    project.wsgi:application