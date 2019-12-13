tmux new -s "EVE" -d gunicorn --bind 0.0.0.0:8000 wsgi:eve_rest -w 12
