#!/usr/bin/env python
import fileinput
from django.utils.crypto import get_random_string
from project.settings import PROJECT_ROOT, SECRET_KEY

# there is no means to run this script if SECRET KEY has already set
if SECRET_KEY != '':
    exit("secret key had already set.")

# check destination file
local_settings_file = PROJECT_ROOT.child("project", "settings_local.py")

if not local_settings_file.isfile():
    exit("not found %s, you should first create it before running this script." % \
         PROJECT_ROOT.rel_path_to(local_settings_file))

# generate secret key
secret_key_line = "SECRET_KEY = '%s'" % \
                  get_random_string(50, "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)")

# replace flag, need to track operation
replaced = False

# scan each line
for line in fileinput.input(local_settings_file, inplace=True):
    if line.find("SECRET_KEY = ''") != -1:
        line = line.replace("SECRET_KEY = ''", secret_key_line)
        replaced = True
    print line,

# not found any ? append SECRET KEY to the file
if not replaced:
    with open(local_settings_file, "a") as settings_file:
        settings_file.write("\n" + secret_key_line)

print "a new secret key has been added to %s" % local_settings_file.name
exit(0)