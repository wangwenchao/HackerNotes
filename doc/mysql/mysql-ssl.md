- <http://www.percona.com/blog/2013/06/22/setting-up-mysql-ssl-and-secure-connections/>
- <http://www.percona.com/blog/2014/10/16/percona-toolkit-for-mysql-with-mysql-ssl-connections/>

```
Setting up MySQL SSL and secure connections
June 22, 2013 by Roman Vynar 10 Comments

There are different articles on how to setup MySQL with SSL but it’s sometimes difficult to end up with a good simple one. Usually, setting up MySQL SSL is not really a smooth process due to such factors like “it’s not your day”, something is broken apparently or the documentation lies :) I am going to provide the brief instructions on how to setup MySQL with SSL, SSL replication and how to establish secure connections from the console and scripts showing the working examples.
SSLQuick links:
Setup SSL on MySQL
Establish secure connection from console
Setup SSL replication
Establish secure connection from PHP
Establish secure connection from Python
Notes
 
Setup SSL on MySQL
1. Generate SSL certificates according to the example 1. Use the different Common Name for server and client certificates.
2. For the reference, I store the generated files under /etc/mysql-ssl/
3. Add the following lines to /etc/my.cnf under [mysqld] section:

# SSL
ssl-ca=/etc/mysql-ssl/ca-cert.pem
ssl-cert=/etc/mysql-ssl/server-cert.pem
ssl-key=/etc/mysql-ssl/server-key.pem
4. Restart MySQL.
5. Create an user to permit only SSL-encrypted connection:
GRANT ALL PRIVILEGES ON *.* TO ‘ssluser’@’%’ IDENTIFIED BY ‘pass’ REQUIRE SSL;
Establish secure connection from console
1. If the client is on a different node, copy /etc/mysql-ssl/ from the server to that node.
2. Add the following lines to /etc/my.cnf under [client]:

# SSL
ssl-cert=/etc/mysql-ssl/client-cert.pem
ssl-key=/etc/mysql-ssl/client-key.pem
3. Test a secure connection:
[root@centos6 ~]# mysql -u ssluser -p -sss -e ‘\s’ | grep SSL
SSL: Cipher in use is DHE-RSA-AES256-SHA
Setup SSL replication
1. Establish a secure connection from the console on slave like described above, to make sure SSL works fine.
2. On Master add “REQUIRE SSL” to the replication user:
GRANT REPLICATION SLAVE ON *.* to ‘repl’@’%’ REQUIRE SSL;
3. Change master options and restart slave:
STOP SLAVE;
CHANGE MASTER MASTER_SSL=1,
MASTER_SSL_CA=’/etc/mysql-ssl/ca-cert.pem’,
MASTER_SSL_CERT=’/etc/mysql-ssl/client-cert.pem’,
MASTER_SSL_KEY=’/etc/mysql-ssl/client-key.pem';
SHOW SLAVE STATUSG
START SLAVE;
SHOW SLAVE STATUSG
Establish secure connection from PHP
1. Install php and php-mysql packages. I use the version >=5.3.3, otherwise, it may not work.
2. Create the script:
[root@centos6 ~]# cat mysqli-ssl.php
$conn=mysqli_init();
mysqli_ssl_set($conn, ‘/etc/mysql-ssl/client-key.pem’, ‘/etc/mysql-ssl/client-cert.pem’, NULL, NULL, NULL);
if (!mysqli_real_connect($conn, ‘127.0.0.1’, ‘ssluser’, ‘pass’)) { die(); }
$res = mysqli_query($conn, ‘SHOW STATUS like “Ssl_cipher”‘);
print_r(mysqli_fetch_row($res));
mysqli_close($conn);
3. Test it:
[root@centos6 ~]# php mysqli-ssl.php
Array
(
[0] => Ssl_cipher
[1] => DHE-RSA-AES256-SHA
)
Establish secure connection from Python
1. Install MySQL-python package.
2. Create the script:
[root@centos6 ~]# cat mysql-ssl.py
#!/usr/bin/env python
import MySQLdb
ssl = {‘cert': ‘/etc/mysql-ssl/client-cert.pem’, ‘key': ‘/etc/mysql-ssl/client-key.pem’}
conn = MySQLdb.connect(host=’127.0.0.1′, user=’ssluser’, passwd=’pass’, ssl=ssl)
cursor = conn.cursor()
cursor.execute(‘SHOW STATUS like “Ssl_cipher”‘)
print cursor.fetchone()
3. Test it:
[root@centos6 ~]# python mysql-ssl.py
(‘Ssl_cipher’, ‘DHE-RSA-AES256-SHA’)
Notes
Alternative local SSL connection setup
If you connect locally to the server enabled for SSL you can also establish a secure connection this way:
1. Create ca.pem:
cd /etc/mysql-ssl/
cat server-cert.pem client-cert.pem > ca.pem
2. Have only the following ssl- lines in /etc/my.cnf under [client]:

# SSL
ssl-ca=/etc/mysql-ssl/ca.pem
Error with “ssl-ca” on local connections
If you left the line “ssl-ca=/etc/mysql-ssl/ca-cert.pem” under [client] section in /etc/my.cnf on the server enabled for SSL and try to establish local SSL connection, you will get “ERROR 2026 (HY000): SSL connection error: error:00000001:lib(0):func(0):reason(1)”.
Discrepancy in documentation
http://dev.mysql.com/doc/refman/5.5/en/using-ssl-connections.html says “A client can connect securely like this: shell> mysql –ssl-ca=ca-cert.pem” which does not work with “REQUIRE SSL”. You still have to supply the client cert and key for any or a combined client+server cert for a local secure connection.


```
