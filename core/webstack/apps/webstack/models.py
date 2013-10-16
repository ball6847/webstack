from django.conf import settings
from django.db import models
from django_extensions.db.models import TimeStampedModel
from django.core.validators import RegexValidator
from django.template.loader import render_to_string
from unipath import Path
import re

from .utils import shell_exec, update_hostfile, Apache

DomainValidator = RegexValidator(
    r"^[a-z0-9\-\.]+\.[a-z0-9]{1,4}$",
    "Invalid domain, it should be something like domain.tld"
)

class Project(TimeStampedModel):
    domain = models.CharField(max_length=100,
                              blank=False,
                              unique=True,
                              validators=[DomainValidator])
    path   = models.CharField(max_length=255,
                              blank=True)
    status = models.BooleanField(default=True)
    
    _unipath = None
    
    def __unicode__(self):
        return self.domain
    
    """ --------------------------------------------------------- """
    
    def save(self, *args, **kwargs):
        # create directory before create object
        if self.pk == None:
            path = Path(self.path)
            # @todo do not allowed create on root permission
            if not path.isdir():
                uid = 0
                gid = 0
                # find uid and gid of closest parent directory
                iterator = path.ancestor(1)
                component = len(iterator.components())
                for i in xrange(component):
                    if iterator.isdir():
                        stat = iterator.stat()
                        uid = stat.st_uid
                        gid = stat.st_gid
                        break
                    iterator = iterator.ancestor(1)
                # create all neccesary files and directories
                path.child('public').mkdir(True)
                path.child('logs').mkdir(True)
                self.apache_vhost_file().write_file('')
                self.apache_access_log().write_file('')
                self.apache_error_log().write_file('')
                # need 777 or apache won't sent errors here
                self.php_error_log().write_file('')
                self.php_error_log().chmod(0777)
                # make files available to user
                shell_exec(["chown", "-R", "%d:%d" % (uid, gid), iterator])
        else:
            # get its previous domain value, if it changes, rename virtualhost file
            old = Project.objects.get(pk=self.pk)
            if self.domain != old.domain:
                old.apache_vhost_file().rename(self.apache_vhost_file())
            
        # update database, /etc/hosts and apache virtualhost then reload apache
        super(Project, self).save(*args, **kwargs)
        update_hostfile()
        self.apache_vhost_file().write_file(
            render_to_string("vhost.html", {'project': self}))
        Apache().reload()
    
    def _delete(self, *args, **kwargs):
        """ currently not used, will move this part to ProjectAdmin """
        super(Project, self).delete(*args, **kwargs)
        self.apache_vhost_file().remove()
        self.apache_access_log().remove()
        self.apache_error_log().remove()
        self.php_error_log().remove()
        Path(self.path).rmdir()
        update_hostfile()
        Apache().reload()

    def safe_domain_name(self):
        return re.sub(r"\.+", "_", self.domain)

    def get_path(self):
        if self._unipath == None :
            self._unipath = Path(self.path)
        return self._unipath

    def document_root(self):
        return Path(self.path).child('public')

    def apache_vhost_file(self):
        return Path(
            settings.WEBSTACK_ROOT,
            'etc/apache2/conf.d/%s.conf' % self.safe_domain_name())

    def apache_access_log(self):
        return self.get_path().child('logs', 'access.log')
    
    def apache_error_log(self):
        return self.get_path().child('logs', 'error.log')
    
    def php_error_log(self):
        return self.get_path().child('logs', 'error-php.log')
    

""" end webstack/models.py """