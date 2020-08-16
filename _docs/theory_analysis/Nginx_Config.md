---
title: Nginx Config
category: Theory, Analysis
date: 2020-08-20T12:00:00Z
lastmod: 2020-08-20T12:00:00Z
comment: true
adsense: true
---


Nginx의 Config를 분석한다.

### 1. Nginx Config

{% highlight text %}
user       nginx;  ## Default: nobody
worker_processes  5;  ## Default: 1
error_log  logs/error.log;
pid        logs/nginx.pid;
worker_rlimit_nofile 8192;

events {
  worker_connections  4096;  ## Default: 1024
}

http {
  include    conf/mime.types;
  include    /etc/nginx/proxy.conf;
  include    /etc/nginx/fastcgi.conf;
  index    index.html index.htm index.php;

  default_type application/octet-stream;
  log_format   main '$remote_addr - $remote_user [$time_local]  $status '
    '"$request" $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
  access_log   logs/access.log  main;
  sendfile     on;
  tcp_nopush   on;
  server_names_hash_bucket_size 128; # this seems to be required for some vhosts

  server { # php/fastcgi
    listen       80;
    server_name  domain1.com www.domain1.com;
    access_log   logs/domain1.access.log  main;
    root         html;

    location ~ \.php$ {
      fastcgi_pass   127.0.0.1:1025;
    }
  }

  server { # simple reverse-proxy
    listen       80;
    server_name  domain2.com www.domain2.com;
    access_log   logs/domain2.access.log  main;

    # serve static files
    location ~ ^/(images|javascript|js|css|flash|media|static)/  {
      root    /var/www/virtual/big.server.com/htdocs;
      expires 30d;
    }

    # pass requests for dynamic content to rails/turbogears/zope, et al
    location / {
      proxy_pass      http://127.0.0.1:8080;
    }
  }

  upstream big_server_com {
    server 127.0.0.3:8000 weight=5;
    server 127.0.0.3:8001 weight=5;
    server 192.168.0.1:8000;
    server 192.168.0.1:8001;
  }

  server { # simple load balancing
    listen          80;
    server_name     big.server.com;
    access_log      logs/big.server.access.log main;

    location / {
      proxy_pass      http://big_server_com;
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] nginx.conf</figcaption>
</figure>

{% highlight text %}
proxy_redirect          off;
proxy_set_header        Host            $host;
proxy_set_header        X-Real-IP       $remote_addr;
proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
client_max_body_size    10m;
client_body_buffer_size 128k;
proxy_connect_timeout   90;
proxy_send_timeout      90;
proxy_read_timeout      90;
proxy_buffers           32 4k;
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] proxy.conf</figcaption>
</figure>

{% highlight text %}
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;
fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

fastcgi_index  index.php;

fastcgi_param  REDIRECT_STATUS    200;
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] fastcgi.conf</figcaption>
</figure>

{% highlight text %}
types {
  text/html                             html htm shtml;
  text/css                              css;
  text/xml                              xml rss;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  application/x-javascript              js;
  text/plain                            txt;
  text/x-component                      htc;
  text/mathml                           mml;
  image/png                             png;
  image/x-icon                          ico;
  image/x-jng                           jng;
  image/vnd.wap.wbmp                    wbmp;
  application/java-archive              jar war ear;
  application/mac-binhex40              hqx;
  application/pdf                       pdf;
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
  application/x-xpinstall               xpi;
  application/zip                       zip;
  application/octet-stream              deb;
  application/octet-stream              bin exe dll;
  application/octet-stream              dmg;
  application/octet-stream              eot;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;
  audio/mpeg                            mp3;
  audio/x-realaudio                     ra;
  video/mpeg                            mpeg mpg;
  video/quicktime                       mov;
  video/x-flv                           flv;
  video/x-msvideo                       avi;
  video/x-ms-wmv                        wmv;
  video/x-ms-asf                        asx asf;
  video/x-mng                           mng;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] mime.types</figcaption>
</figure>

nginx.conf 파일은 Nginx 주요 설정이 포함되어 있는 파일이다. [파일 1]은 nginx.conf 예제를 나타내고 있으며, [파일 2~4]를 Include하고 있다. [파일 1~4]의 설정 내용을 분석한다.

#### 1.1. Top

{% highlight text %}
user       nginx;  ## Default: nobody
worker_processes  5;  ## Default: 1
error_log  logs/error.log;
pid        logs/nginx.pid;
worker_rlimit_nofile 8192;
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] nginx.conf Top</figcaption>
</figure>

* user : Nginx Worker Process의 User를 의미한다. Worker Process의 권한을 설정할때 이용한다.
* worker_processes : Nginx Worker Process의 개수를 의미한다. 기본값은 1이다.
* error_log : Nginx Error Log의 경로를 의미한다.
* pid : Nginx Master Process의 PID가 저장되는 Log의 경로를 의미한다.
* worker_rlimit_nofile : Nginx Worker Process가 이용할 수 있는 최대 File Desciptor의 개수를 의미한다. 일반적으로 Worker Process 갖을 수 있는 최대 Connection 개수의 2배를 설정한다. 기본값은 1024이다.

#### 1.1. events Block

{% highlight text %}
events {
  worker_connections  4096;  ## Default: 1024
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] nginx.conf events Block</figcaption>
</figure>

events Block은 Network Connection 처리 관련 설정을 포함한다.

* worker_connections : Nginx Worker Process가 동시에 갖을 수 있는 최대 Connection의 개수를 의미한다.

#### 1.2. http Block

http Block은 HTTP, HTTPS 관련 설정을 포함하고 있다.

##### 1.2.1 http Block Top

{% highlight text %}
http {
  include    conf/mime.types;
  include    /etc/nginx/proxy.conf;
  include    /etc/nginx/fastcgi.conf;
  index    index.html index.htm index.php;
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] nginx.conf http block top</figcaption>
</figure>

* mime.types : 
* proxy.conf : 
* fastcgi.conf :
* index :

### 2. 참조

* [https://www.nginx.com/resources/wiki/start/topics/examples/full/](https://www.nginx.com/resources/wiki/start/topics/examples/full/)
* [https://stackoverflow.com/questions/37591784/nginx-worker-rlimit-nofile](https://stackoverflow.com/questions/37591784/nginx-worker-rlimit-nofile)