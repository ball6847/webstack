from django  import forms 
from unipath import Path
from .utils  import make_clean_filename
import re

class ProjectForm(forms.ModelForm):
    
    """ display path as readonly for existing object """
    
    def __init__(self, *args, **kwargs):
        super(ProjectForm, self).__init__(*args, **kwargs)
        instance = getattr(self, 'instance', None)
        if instance and instance.pk:
            self.fields['path'].widget.attrs['readonly'] = True
    
    """ --------------------------------------------------------- """
    
    """ prevent user from updating path on existing object
        use webstack's default on create new with empty value """
        
    def clean_path(self):
        # prevent user from changing docroot on existing object
        instance = getattr(self, 'instance', None)
        if instance and instance.pk:
            return instance.path
        
        domain = self.cleaned_data['domain']
        path = self.cleaned_data['path']
        
        # use webstack's default
        if path == "":
            path = "/home/ball6847/webstack/www/" + re.sub(r"\.+", "_", domain)
        
        return path
    
    """ --------------------------------------------------------- """