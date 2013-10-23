<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "{{ WEBSTACK_ROOT }}/core/webstack/"
    
    # 3rdparty software
    ProxyPass /phpmyadmin !
    Alias /phpmyadmin "{{ WEBSTACK_ROOT }}/core/phpmyadmin"
    
    # webstack static files
    ProxyPass /static !
    Alias /static "{{ WEBSTACK_ROOT }}/core/webstack/static"
    
    ProxyPass / http://127.0.0.1:6847/
    ProxyPassReverse / http://127.0.0.1:6847/
    
	<Directory />
		Options +FollowSymLinks
		AllowOverride None
	</Directory>
    
    <Directory "{{ WEBSTACK_ROOT }}/core">
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
        <IfVersion >= 2.4>
        Require all granted
        </IfVersion> 
    </Directory>
    
    LogLevel warn
    ErrorLog "{{ WEBSTACK_ROOT }}/logs/core/error.log"
    CustomLog "{{ WEBSTACK_ROOT }}/logs/core/access.log" combined
</VirtualHost>