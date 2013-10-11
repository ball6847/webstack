This is my version of Django project skeleton ready made for my project. Since I'm quite a newbie to Django, this repository may frequently change as my experience rising.

## Installation

```bash
git clone https://github.com/ball6847/django-project-skel yourprojectname
cd yourprojectname

# setup virtualenv using virtualenvwrapper
mkvirtualenv yourprojectname

pip install -r requirements.txt

# create database for your project, skip this if you don't need it
mysql -u root -p -e "CREATE DATABASE yourprojectdb"

# create your local settings, override database settings and others
vim project/settings_local.py

# makesecret.py can generate a secret key for you
python makesecret.py

# create all neccessary tables, follow the instructions
python manage.py syncdb
python manage.py collectstatic

# enjoy!
python manage.py runserver

```