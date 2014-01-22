#!/bin/bash

sudo apt-get install -f nginx


VAR=$(cat <<'END_HEREDOC'

# Set another default user than root for security reasons
user       www-data;

# As a thumb rule: One per CPU. If you are serving a large amount
# of static files, which requires blocking disk reads, you may want
# to increase this from the number of cpu_cores available on your
# system.
#
# The maximum number of connections for Nginx is calculated by:
# max_clients = worker_processes * worker_connections
worker_processes 1;

# Maximum file descriptors that can be opened per process
# This should be > worker_connections
worker_rlimit_nofile 8192;

events {
  # When you need > 8000 * cpu_cores connections, you start optimizing
  # your OS, and this is probably the point at where you hire people
  # who are smarter than you, this is *a lot* of requests.
  worker_connections  8000;

  # This sets up some smart queueing for accept(2)'ing requests
  # Set it to "on" if you have > worker_processes
  accept_mutex off;

  # These settings are OS specific, by defualt Nginx uses select(2),
  # however, for a large number of requests epoll(2) and kqueue(2)
  # are generally faster than the default (select(2))
  # use epoll; # enable for Linux 2.6+
  # use kqueue; # enable for *BSD (FreeBSD, OS X, ..)
}

# Change these paths to somewhere that suits you!
error_log  logs/error.log;
pid        logs/nginx.pid;

http {
  # Set the mime-types via the mime.types external file
  include       nginx-mime.types;

  # And the fallback mime-type
  default_type  application/octet-stream;

  # Format for our log files
  log_format   main '$remote_addr - $remote_user [$time_local]  $status '
    '"$request" $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';

  # Click tracking!
  access_log   logs/access.log  main;

  # ~2 seconds is often enough for HTML/CSS, but connections in
  # Nginx are cheap, so generally it's safe to increase it
  keepalive_timeout  5;

  # You usually want to serve static files with Nginx
  sendfile on;

  tcp_nopush on; # off may be better for Comet/long-poll stuff
  tcp_nodelay off; # on may be better for Comet/long-poll stuff

  # Enable Gzip
  gzip  on;
  gzip_http_version 1.0;
  gzip_comp_level 2;
  gzip_min_length 1100;
  gzip_buffers     4 8k;
  gzip_proxied any;
  gzip_types
    # text/html is always compressed by HttpGzipModule
    text/css
    text/javascript
    text/xml
    text/plain
    text/x-component
    application/javascript
    application/json
    application/xml
    application/rss+xml
    font/truetype
    font/opentype
    application/vnd.ms-fontobject
    image/svg+xml;

  gzip_static on;

  gzip_proxied        expired no-cache no-store private auth;
  gzip_disable        "MSIE [1-6]\.";
  gzip_vary           on;

  server {
    # listen 80 default deferred; # for Linux
    # listen 80 default accept_filter=httpready; # for FreeBSD
    listen 80 default;

    # e.g. "localhost" to accept all connections, or "www.example.com"
    # to handle the requests for "example.com" (and www.example.com)
    server_name _;

    # Path for static files
    root /sites/example.com/public;

    # Custom 404 page
    error_page 404 /404.html;

    expires 1M;

    # Static assets
    location ~* ^.+\.(manifest|appcache)$ {
      expires -1;
      root   /sites/example.com/public;
      access_log logs/static.log;
    }

    # Set expires max on static file types
    location ~* ^.+\.(css|js|jpg|jpeg|gif|png|ico|gz|svg|svgz|ttf|otf|woff|eot|mp4|ogg|ogv|webm)$ {
      expires max;
      root   /sites/example.com/public;
      access_log off;
    }

    # opt-in to the future
    add_header "X-UA-Compatible" "IE=Edge,chrome=1";

  }
}

END_HEREDOC
)

echo "$VAR" >> /etc/nginx/nginx.conf 








VAR=$(cat <<'END_HEREDOC'
types {

# Audio
  audio/midi                            mid midi kar;
  audio/mp4                             aac f4a f4b m4a;
  audio/mpeg                            mp3;
  audio/ogg                             oga ogg;
  audio/x-realaudio                     ra;
  audio/x-wav                           wav;

# Images
  image/bmp                             bmp;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  image/png                             png;
  image/tiff                            tif tiff;
  image/vnd.wap.wbmp                    wbmp;
  image/webp                            webp;
  image/x-icon                          ico cur;
  image/x-jng                           jng;

# JavaScript
  application/javascript                js;
  application/json                      json;

# Manifest files
  application/x-web-app-manifest+json   webapp;
  text/cache-manifest                   manifest appcache;

# Microsoft Office
  application/msword                                                         doc;
  application/vnd.ms-excel                                                   xls;
  application/vnd.ms-powerpoint                                              ppt;
  application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
  application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

# Video
  video/3gpp                            3gpp 3gp;
  video/mp4                             mp4 m4v f4v f4p;
  video/mpeg                            mpeg mpg;
  video/ogg                             ogv;
  video/quicktime                       mov;
  video/webm                            webm;
  video/x-flv                           flv;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;

# Web feeds
  application/xml                       atom rdf rss xml;

# Web fonts
  application/font-woff                 woff;
  application/vnd.ms-fontobject         eot;
  application/x-font-ttf                ttc ttf;
  font/opentype                         otf;
  image/svg+xml                         svg svgz;

# Other
  application/java-archive              jar war ear;
  application/mac-binhex40              hqx;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.wap.wmlc              wmlc;
  application/xhtml+xml                 xhtml;
  application/vnd.google-earth.kml+xml  kml;
  application/vnd.google-earth.kmz      kmz;
  application/x-7z-compressed           7z;
  application/x-chrome-extension        crx;
  application/x-opera-extension         oex;
  application/x-xpinstall               xpi;
  application/x-cocoa                   cco;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-bittorrent              torrent;
  application/zip                       zip;

  application/octet-stream              bin exe dll;
  application/octet-stream              deb;
  application/octet-stream              dmg;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;
  application/octet-stream              safariextz;

  text/css                              css;
  text/html                             html htm shtml;
  text/mathml                           mml;
  text/plain                            txt;
  text/vnd.sun.j2me.app-descriptor      jad;
  text/vnd.wap.wml                      wml;
  text/vtt                              vtt;
  text/x-component                      htc;
  text/x-vcard                          vcf;

}





END_HEREDOC
)

echo "$VAR" >> /etc/nginx/mime.types 






