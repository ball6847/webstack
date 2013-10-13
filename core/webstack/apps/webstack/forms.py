from django  import forms 
from unipath import Path
from .utils  import make_clean_filename
import re

class ProjectForm(forms.ModelForm):
    
    def clean_domain(self):
        return make_clean_filename(self.cleaned_data['domain'])
    
    def validate(self):
        data = super(ProjectForm, self).clean()
        domain = data.get('domain')
        path = data.get('path')
        """
        # use webstack path
        if path == "":
            path = "/home/ball6847/webstack/www/" + re.sub(r"\.+", "_", domain)
            path = Path(path)
            path.mkdir()
        else:
            path = Path(path)
        
        # directory must does exist before continue
        if not path.exists():
            raise forms.ValidationError("%s does not exist in filesystem" % path)
        """
        return data    
    