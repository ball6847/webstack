#!/bin/sh

python manage.py migrate
python manage.py collectstatic --noinput

echo "
from django.contrib.auth.models import User
User.objects.create_superuser('admin', 'admim@domain.com', 'changethis987654321')
" | python manage.py shell > /dev/null 2>&1

python manage.py runserver 0.0.0.0:8000
