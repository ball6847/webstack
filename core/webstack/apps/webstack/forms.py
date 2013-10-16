from django      import forms
from django.conf import settings
from unipath     import Path
from .utils      import make_clean_filename
import re

class ProjectForm(forms.ModelForm):
    
    def __init__(self, *args, **kwargs):
        """
        display path as readonly for existing object
        """
        super(ProjectForm, self).__init__(*args, **kwargs)
        instance = getattr(self, 'instance', None)
        if instance and instance.pk:
            self.fields['path'].widget.attrs['readonly'] = True
    
    def clean_path(self):
        """
        prevent user from updating path on existing object
        use webstack's default on create new with empty value
        """
        instance = getattr(self, 'instance', None)
        if instance and instance.pk:
            return instance.path
        domain = self.cleaned_data['domain']
        path = self.cleaned_data['path']
        if path == "":
            path = settings.WEBSTACK_ROOT.child("www", re.sub(r"\.+", "_", domain))
        return path
