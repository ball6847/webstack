FROM alpine:edge
MAINTAINER Porawit Poboonma <ball6847@gmail.com>

ADD ./ /app

RUN apk add --update --no-cache gcc musl-dev python-dev py-pip bash wget ca-certificates openssl && \
    sh -c "wget https://bootstrap.pypa.io/ez_setup.py -O - | python"

RUN cd /app/core/webstack && \
    pip install -r requirements.txt && \
    python manage.py migrate && \
    python manage.py collectstatic --noinput && \
    sh -c "echo \"
from django.contrib.auth.models import User
User.objects.create_superuser('admin', 'admim@domain.com', 'changethis987654321')
\" | python manage.py shell > /dev/null 2>&1"

# RUN apl del gcc musl-dev python-dev 

VOLUME ['/var/lib/webstack/data']
