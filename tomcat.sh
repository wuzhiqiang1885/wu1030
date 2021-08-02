#解压软件包
tar zxvf apache-tomcat-8.5.16.tar.gz
tar zxvf jdk-8u91-linux-x64.tar.gz
#复制到Java这个路径下
cp -rv jdk1.8.0_91/ /usr/local/java
#末尾新增
vi /etc/profile
export JAVA_HOME=/usr/local/java
export JRE_HOME=/usr/local/java/jre
export PATH=$PATH:/usr/local/java/bin
export CLASSPATH=./:/usr/local/java/lib:/usr/local/java/jre/lib
#开启服务
source /etc/profile
#创建脚本
vi abc.java
public class abc {
	public static void main (String[] args) {
		System.out.println("你好，世界！！！");
	}
}
#执行文件
javac abc.java
#测试，原样输出则为成功
java abc
#进入文本编辑
vi /usr/local/java/jre/lib/security/java.security
117 securerandom.source=file:/dev/random
#复制文件到此路径下
cp -r apache-tomcat-8.5.16 /usr/local/tomcat8
#做两条软连接
ln -s /usr/local/tomcat8/bin/startup.sh /usr/bin/tomcatup
ln -s /usr/local/tomcat8/bin/startup.sh /usr/bin/tomcatdown
#查看服务
tomcatup
#查看端口号是否打开
netstat -anpt | grep 8080
#创建web进行编辑
mkdir -p /web/webapp1
vi /web/webapp1/index.jsp
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<html>
 <head>
  <title>web1</title>
 </head>
 <body><h1>
  <% out.println("This is web1");%>
  </h1>
 </body>
</html>
mkdir -p /web/webapp2
vi /web/webapp2/index.jsp
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<html>
 <head>
  <title>web2</title>
 </head>
 <body><h1>
  <% out.println("This is web2");%>
  </h1>
 </body>
</html>
#进入文本到148，149，150行进行编辑
vi /usr/local/tomcat8/conf/server.xml
<Host name="www.aa.com"  appBase="webapps"
      unpackWARs="true" autoDeploy="true">
       <Context docBase="/web/webapp1" path="" reloadable="flase">
       </Context>
#还是在上面的文本167，168，169，170新增
<Host name="www.ab.com"  appBase="webapps"
      unpackWARs="true" autoDeploy="true">
      <Context docBase="/web/webapp2" path="" reloadable="flase">
      </Context>
#关掉服务重新启动
tomcatdown
tomcatup
#nginx配置
yum install pcre-devel zlib-devel openssl-devel gcc gcc-c++  make -y
useradd -s /bin/false www
#解压软件包
tar zxvf nginx-1.13.9.tar.gz
#进入解压后的目录
cd nginx-1.13.9/
#编译安装
./configure \
--prefix=/usr/local/nginx \
--user=www \
--group=www \
--with-file-aio \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_flv_module \
--with-http_ssl_module 
make && make install
#进入文本进行编辑
vim /usr/local/nginx/conf/nginx.conf
 30     #keepalive_timeout  0;
 31     keepalive_timeout  65;
 32 
 33     #gzip  on;
 34     upstream tomcat_server {
 35               server 192.168.1.100:8080 weight=1;
 36               server 192.168.1.102:8080 weight=1;
 37             }
 38 
 39     server {
 40         listen       80;
 41         server_name  localhost;
 
 47         location / {
 48             root   html;
 49             index  index.html index.htm;
 50             proxy_pass http://tomcat_server;
 51         }
#检测文本是否有错误
/usr/local/nginx/sbin/nginx -t
#做个软连接
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
#启用nginx服务
nginx
#查看端口号（如果80端口无法打开，netstat -anpt | grep 80 看看是被谁占用了，关掉它重新开启nginx服务）
netstat -ntap | grep nginx
#重启nginx
killall -1 nginx
