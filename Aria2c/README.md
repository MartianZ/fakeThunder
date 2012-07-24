Aria2c[改]
===========

偶尔需要调整一下aria2c的部分设定，满足需求。

###目前修改的内容：

1. 文件下载过程中，每次输出后添加flush，解决管道因为缓存读取不到内容的问题

###编译Configure参数：

./configure --disable-bittorrent --disable-nls --without-sqlite3

其中sqlite3会引起OS X 10.7和10.8编译出来的二进制文件不能通用的问题。