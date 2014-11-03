## mysql  config 


### git 
https://guides.github.com/
http://python-guide.readthedocs.org/en/latest/
http://marklodato.github.io/visual-git-guide/index-en.html ***
http://git-scm.com/ ***
http://think-like-a-git.net/
http://rogerdudler.github.io/git-guide/
http://jiongks.name/blog/a-successful-git-branching-model
http://blog.jobbole.com/54184/
http://blog.jobbole.com/50603/  **

### mysql

replication doc
http://dev.mysql.com/doc/refman/5.6/en/replication.html

----------------mysql master conf-----------------------
	mysql master config(my.conf) demo:
	[mysqld]
	datadir=/var/lib/mysql
	socket=/var/lib/mysql/mysql.sock
	user=mysql
	# Disabling symbolic-links is recommended to prevent assorted security risks
	symbolic-links=0

	#  pid and error log and bin-log

	pid-file=/var/run/mysqld/mysqld.pid
	log-error=/var/log/mysqld.log
	log-bin=/var/lib/mysql/mysql-bin   ### set the loin-bin

	# set the default DB and conn character
	collation-server 		= utf8_unicode_ci
	init-connect			='SET NAMES utf8'
	character-set-server 	= utf8

	#
	#
	#
	# for cluster  and replication
	server_id	=1

	# log-slave-updates
	bin-log		=mysql-bin
	relay-log	=mysql-relay
	
	# If you have multi databases to be replicated, /etc/my.cnf should be like this:
	# replicate-do-db=db01
	# replicate-do-db=db02
	# If you just want slave to ignore some database, you can set replicate-ignore-db:
	# replicate-ignore-db=db01

	[client]
	default-character-set = utf8

	[mysqld_safe]
	log-error=/var/log/mysqld.log
	pid-file=/var/run/mysqld/mysqld.pid

------------------mysql slave conf-----------------------
mysql slave config demo:
	[mysql]
	default-character-set = utf8
	[client]
	default-character-set = utf8
	[mysqld]
	collation-server 	= utf8_unicode_ci
	init-connect		='SET NAMES utf8'
	character-set-server = utf8
	socket=/var/run/mysql.sock

	# for cluster  and replication
	server_id	=2

	# log-slave-updates
	bin-log		=mysql-bin
	relay-log	=mysql-relay
	relay-only 	=1

-------------------------------------------------------
	


### mysql replication configration 

1.  setup DB slave  128.88
http://dev.mysql.com/doc/refman/5.1/en/replication-howto-newservers.html
http://m.oschina.net/blog/29671	
https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-in-mysql
http://blog.sina.com.cn/s/blog_6b92dce10101hgxn.html
http://babaoqi.iteye.com/blog/1954471
http://raugher.blog.51cto.com/3472678/1169604

#####################################################
Check the config file content
	 egrep -v '^#|^$' /etc/my.cnf

1) master : 
			SHOW MASTER STATUS;
2)			GRANT REPLICATION SLAVE ON *.* to 'slave1'@'<Slave1 IP>' identified by 'slave1_pwd';
	eg: GRANT REPLICATION SLAVE ON *.* to 'slave88'@'10.210.128.88' identified by 'slave88pwd';

3)			FLUSH TABLES WITH READ LOCK;
4)	backup  master db data 
5)  rsync backup db data file to salve data dir 
	
6)  master:
		unlock tables;
#####################################################
##slave##： 
mysql> reset master;
mysql>	hange master to 
		master_host='<Master_ip>',
		master_user='<Slave_repl-username>',
		master_password='<slave-repl-passwd>',
		master_log_file='mysql-bin-xxx',
		master_log_pos=xxx;
eg :
		change master to master_host='10.212.0.61',	master_user='slave88',master_password='slave88pwd',master_log_file='mysql-bin-xxx',master_log_pos=xxx;

8）
mysql>	start slave;
9）
mysql>	show slave status ;

to check the :
 	Slave_IO_Running: Yes
  	Slave_SQL_Running: Yes


#####################################################
2. change the dcm domain  A record to 128.88 


3.  change the DB  master to 128.88

#####################################################
MYSQL主从切换(主库未宕机)  
http://babaoqi.iteye.com/blog/1954471
将主从(3307主--3309从)切换 
前提：3307正常 

一、将3307设为只读。命令行操作 
# 修改配置文件 
vim /home/bbq/mysql/mysql-3307/cnf/my.cnf 
# 在[mysqld]中增加 
read_only 

# 重启3307 
service mysqld3307 restart 

二、等待从库执行完主库的所有sql。mysql客户端操作 
# 3307执行: 
show master status # 记录File、Position 
# 3309执行: 
select master_pos_wait(File, Position); 

三、将3309设为可写。命令行操作 
# 修改配置文件 
vim /home/bbq/mysql/mysql-3309/cnf/my.cnf 
# 在[mysqld]中删除 
# read_only 

# 重新启动mysqld3309 
service mysqld3309 restart 

四、将3307设为3309的从库。mysql客户端操作 

# 3309 从库变主库 
RESET MASTER;STOP SLAVE;RESET SLAVE; 

show master status; #记录FILE Position 

# 3307 主库变从库 
RESET MASTER;

CHANGE MASTER TO master_host='localhost',master_port=3309, master_user='repl',master_password='repl@pwd', master_log_file='新主库FILE',master_log_pos=新主库Position; 

START SLAVE;

SELECT SLEEP(1);SHOW SLAVE STATUS\G; 

--- chk replication status;
若是SQL线程(Slave_IO_Running)和I/O线程(Slave_SQL_Running)都显示为YES状态，则搭建成功. 

===========================================================
一主一从切换示例

1.修改配置文件
=== master 配置文件
innodb_flush_log_at_trx_commit=1
sync_binlog=1
read_only=1

=== slave 配置文件
innodb_flush_log_at_trx_commit=1
sync_binlog=1
#read_only=1

2.查询主，从库的状态
--master
 mysql>  show processlist \G

--slave
 mysql>  show processlist \G
 
 mysql> show slave status \G

3.主库置只读状态
--master
mysql> set global read_only=1;

4.再次查看主，从状态，从接收完所有日志后,停止io线程
--slave
mysql> stop slave io_thread;
Query OK, 0 rows affected (0.00 sec)
mysql>  show processlist \G
mysql> show slave status \G

Make sure that the slave have processed any statements in their relay log.
show processlist \G中显示 State: Slave has read all relay log; 

5.从库置为主库
--slave
mysql> stop slave;
Query OK, 0 rows affected (0.00 sec)

mysql> reset master;
Query OK, 0 rows affected (0.01 sec)

mysql> reset slave;
Query OK, 0 rows affected (0.01 sec)

mysql> show master status \G

6.主库置为从库
mysql> reset master;
Query OK, 0 rows affected (0.01 sec)

mysql>  CHANGE MASTER TO MASTER_HOST='master_host',	MASTER_USER='repl',MASTER_PASSWORD='repl',     	MASTER_LOG_FILE='mysql-bin.000001',	MASTER_LOG_POS=107;

Query OK, 0 rows affected (0.03 sec)

mysql> start slave;
Query OK, 0 rows affected (0.00 sec)

mysql> show slave status \G



=================================================
 you want to replicate just on database from master, you can set replicate-do-db in your /etc/my.cnf or set replicate-do-db as mysql argument, for example:

replicate-do-db=db01
If you have multi databases to be replicated, /etc/my.cnf should be like this:

replicate-do-db=db01
replicate-do-db=db02
If you just want slave to ignore some database, you can set replicate-ignore-db:

replicate-ignore-db=db01
More details on MySQL document: http://dev.mysql.com/doc/refman/5.1/en/replication-options-slave.html#option_mysqld_replicate-do-db
=================================================

### DCM product updating

====================
DCM  product 
DCM API and UDP product_id

1. 
 alter table api_keys add column product_id  varchar(40) after  product; 
2.
use dns_issue;
set names utf8;
update api_keys set product = 'SINA.Weibo.Music.乐库' where product = 'SINA.Mobile.Music.乐库';
update api_keys set product = 'SINA.Weibo.Game Portal.游戏'  where product = 'SINA.Game.Game Portal.游戏';
update api_keys set product = 'SINA.Weibo.Game Portal.手机游戏'  where product = 'SINA.Game.Game Portal.手机游戏';
update api_keys set product = 'SINA.Weibo.Wei Pan.微盘'  where product = 'SINA.Other.Wei Pan.微盘';


