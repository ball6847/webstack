from settings import *

TIME_ZONE = 'Asia/Bangkok'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': '/var/lib/webstack/data/webstack.db',                      # Or path to database file if using sqlite3.
    }
}

SECRET_KEY = 'y^412nwur)o7#9xwc^3i=noz)td!pk47hx5^ec2tw^=s+0k2=='
