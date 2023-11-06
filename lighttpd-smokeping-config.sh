#!/bin/bash

# Set variables for easy file references
conf="/etc/lighttpd/lighttpd.conf"
dir="/etc/lighttpd/conf-available"
header="setenv.add-response-header"

# Modify Lighttpd configurations
sed -i '/server.errorlog/s|^|#|' $conf
sed -i '/server.document-root/s|/html||' $conf
sed -i '/server.modules = (/a \\t"mod_setenv",' $conf

# Add security headers
echo "$header"' += ( "X-XSS-Protection" => "1; mode=block" )' >>$conf
echo "$header"' += ( "X-Content-Type-Options" => "nosniff" )' >>$conf
echo "$header"' += ( "X-Robots-Tag" => "none" )' >>$conf
echo "$header"' += ( "X-Frame-Options" => "SAMEORIGIN" )' >>$conf

# Configure Smokeping CGI
sed -i '/^#cgi\.assign/,$s/^#//; /"\.pl"/i\ \t".cgi"  => "/usr/bin/perl",' $dir/10-cgi.conf
#echo '\nfastcgi.server += ( ".cgi" =>\n\t((' >>$dir/10-fastcgi.conf


# Modify the access log location
sed -i 's|var/log/lighttpd/access.log|tmp/log|' $dir/10-accesslog.conf

# Modify Smokeping configurations
sed -i '/^syslogfacility/s/^/#/' /etc/smokeping/config.d/General
sed -i 's/the \(SmokePing website\) of xxx Company/our \1/' /etc/smokeping/config.d/General

# Enable required Lighttpd modules
lighttpd-enable-mod cgi
lighttpd-enable-mod fastcgi
# ...and any other modules you need...

# Set the correct permissions
chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping /run/smokeping
chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /run/smokeping

# Set suid for fping
chmod u+s /usr/bin/fping

# Final cleanup, if necessary
rm -rf /tmp/* /var/tmp/*

# Make script executable
chmod +x /usr/bin/smokeping.sh

