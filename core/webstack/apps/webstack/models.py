from django.db import models
from django_extensions.db.models import TimeStampedModel
import re

# Create your models here.
class Project(TimeStampedModel):
    domain = models.CharField(max_length=100, blank=False, unique=True)
    path   = models.CharField(max_length=255, blank=True)
    status = models.BooleanField(default=True)
    
    def save(self, *args, **kwargs):
        super(Project, self).save(*args, **kwargs)
        update_hostfile()
    

def update_hostfile():
    filename = "/etc/hosts"
    ip = "127.0.0.1"
    commentopen = "## webstack-start"
    commentclose = "## webstack-end"
    
    # get all domain from all projects
    projects = Project.objects.filter(status=True)
    
    # create hostfile entries
    buff = []
    buff.append(commentopen)
    for p in projects:
        buff.append(ip + " " + p.domain)
    buff.append(commentclose)
    buff = "\n".join(buff)
    
    # add webstack entries to hostfile
    with open(filename, 'rw+') as fp:
        cache = fp.read()
        fp.seek(0)
        
        if cache.find(commentopen) == -1:
            cache = cache + "\n\n" + buff
        else:
            cache = re.sub(
                "%s\s+(.*)\s+%s" % (re.escape(commentopen), re.escape(commentclose)),
                buff,
                cache
            )
        
        fp.write(cache)
