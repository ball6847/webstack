import re, subprocess

""" --------------------------------------------------------- """

def make_clean_filename(filename):
    keepcharacters = ('.', '-', '_')
    return "".join(c for c in filename if c.isalnum() or c in keepcharacters).rstrip()

""" --------------------------------------------------------- """

def shell_exec(cmd):
	return subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).communicate()[0]

""" --------------------------------------------------------- """

def update_hostfile():
    # we need to import here or it will cause recursion
    from .models import Project
    
    filename = "/etc/hosts"
    ip = "127.0.0.1"
    commentopen = "## webstack-start"
    commentclose = "## webstack-end"
    
    # get all domain from all projects
    projects = Project.objects.filter(status=True).order_by('created')
    
    # create hostfile entries
    buff = []
    buff.append(commentopen)
    for p in projects:
        buff.append(ip + " " + p.domain)
    buff.append(commentclose)
    buff = "\n".join(buff)
    
    # add webstack entries to hostfile
    with open(filename, 'r+') as fp:
        cache = fp.read()
        fp.seek(0)
        
        if cache.find(commentopen) == -1:
            cache = cache + "\n\n" + buff
        else:
            pattern = "%s.*%s" % (re.escape(commentopen), re.escape(commentclose))
            cache = re.sub(pattern, buff, cache, 1, re.DOTALL)
        
        fp.write(cache)
        fp.close()
        return True
    
    return False

""" --------------------------------------------------------- """

class Apache():
    
    def start(self):
        shell_exec(["service", "apache2", "restart"])
        
    def stop(self):
        shell_exec(["service", "apache2", "restart"])
        
    def reload(self):
        shell_exec(["service", "apache2", "reload"])

    def restart(self):
        shell_exec(["service", "apache2", "restart"])
