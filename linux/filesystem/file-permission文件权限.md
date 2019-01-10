# 权限说明

## 权限范围

| 权限范围 | 符号表示 | 说明                  |
| -------- | -------- | --------------------- |
| user     | u        | 文件所有者            |
| group    | g        | 文件所有者所在的群组  |
| others   | o        | 所有其他用户          |
| all      | a        | 所有用户（相当于ugo） |

*Linux系统中，预设的情況下，系统中所有的帐号信息记录在`/etc/passwd`文件中，每个用户的密码（经过加密）则记录在`/etc/shadow`文件中，所有的组群信息记录在`/etc/group`文件中。*

## 基本权限rwx

rwx是最基本的权限。

| 权限类型 | 字母表示 | 数字表示 | 说明                             |
| :------- | -------- | -------- | -------------------------------- |
| 读       | r        | 4        | 文件可读；目录下文件可列出       |
| 写       | w        | 2        | 文件可写；目录下可创建和删除文件 |
| 执行     | x        | 1        | 文件可执行；目录可进入           |
| 无权限   | -        | 0        | 无权限                           |

*此处数字是八进制*

使用`ls -l name`示例，`ls -l /etc/hosts`列出信息如下：

```shell
-rw-r--r--. 1 root root 65 Mar 12 03:24 /etc/hosts
```

提示：使用`stat -c %a 文件名`可以获取以数字表示的权限信息，例如`stat -c %a /etc/hosts `返回的信息是`644`。

``-rw-r--r--`即为权限信息，按顺序解释各个符号意义如下：

- 第1位：文件类型（查看[linux文件类型](#linux文件类型)）
- 第2-10位：不同用户对该文件的权限

  - 第2-4位：文件拥有者的权限

  - 第5-7位：文件所属群组（中的用户）的权限

  - 第8-10位：其他用户的权限
- 第11位：
  - 启用了selinux，该处以点号`.`字符表示

  - 设置了ACL后，该处以加号`+`表示

    提示：以`ls -l`看到的权限信息中有`+`号时，应当用`getfacl`查看权限信息，因为该种情况下`ls -l`展示的权限信息可能是ACL MASK有效权限，参看下文[ACL权限管理](#ACL权限管理)中关于MASK有效权限的描述。

## 特殊权限SUID SGID Sticky

- SUID

  具有SUID权限的**二进制可执行文件**在**执行中，执行者拥有与该文件所有者相同的权限**。

  - 仅对二进制可执行文件有效
  - 执行者对于该程序需要有可执行权限
  - 该权限仅在程序执行过程中有效
  - 执行过程中，执行者将具有该程序拥有者(owner)的权限。

  注意：如果所有者是 root 的话，那么该文件的执行者就有超级用户的特权。



  当`s` 标志出现在文件权限信息中所有者的x权限位置时，则此程序被设置了SUID特殊权限。

  > [root@cent7 ~]# ls -l /usr/bin/passwd                                                                                   -rwsr-xr-x. 1 root root 27832 Jun 10  2014 /usr/bin/passwd

- SGID

  特点同SUID，只是`s`出现在文件权限信息中所属群组的x位置，SGID权限对该群组（group）用户有效。

  > [root@cent7 ~]# ls -l /usr/bin/wall -a
  > -r-xr-sr-x. 1 root tty 15344 Jun 10  2014 /usr/bin/wall

- Sticky

  特点类似SUID，`s`出现在文件权限信息中其他用户的x位置，Sticky权限对其他用户有效。

  特别的：**Sticky只针对目录有效**，在目录设置Sticky位后，任何用户都能在该目录下创建文件，但是只有文件的所有者或root可以删除自己的目录或文件。

  例如`/tmp`目录

  > [root@cent7 ~]# ls -l / |grep tmp                                                                                       drwxrwxrwt.   7 root root  132 Sep  9 03:28 tmp  


注意：**如果s或t以大写的S或T出现，说明文件权限信息中原本没有x权限，此时该特殊权限不生效。**

# 权限更改

## chmod/chown/chgrp

- 常用参数：
  - `-c`或`--changes`  显示更改部分信息
  - `-R`或`--recursive`  作用于该目录下所有的文件和子目录
  - `-h`  修复符号链接
  - `--reference`  以指定的目录或文件的权限作为参照进行权限设置

- chmod修改权限

  ```shell
  chmod [参数] <权限范围>[+-=]<权限> <文件/目录>
  chmod -cR g+r /srv
  chmod -cR u+w,g+r /srv  #多条权限规则使用逗号分隔
  ```

  [权限范围](#权限范围)：u g o a

  `+`表示加权限，`-`表示减权限，`=`表示重设权限

  权限：r w x - s

- chown修改所有者和所属组

  ```shell
  chown [参数] <用户名>:<组名> <文件/目录>  #冒号:也可以使用点号.
  chown -R nginx.nginx /srv/
  ```

- chgrp修改所属组

  ```shell
  chown [参数] <组名> <文件/目录>  #冒号:也可以使用点号.
  chown -cR nginx /srv/
  ```

## ACL权限管理

ACL（Access Control Lists，访问控制列表）为文件系统提供更为灵活的附加权限机制。弥补chmod/chown/chgrp的不足。

ACL 通过以下对象来控制权限：

- user  用户 对应ACL_USER_OBJ和ACL_USER

- group  群组  对应ACL_GROUP_OBJ和ACL_GROUP

- mask  掩码--最大有效权限（Effective permission, 或者说权限范围）   对应ACL_MASK

  *和默认权限`umask`类似，是一个权限掩码, 表示所能赋予的权限最大值。*

  设置了mask权限后，**使用者或群组所设置的权限必须要存在于 mask 的权限设置范围内才会生效**（未设置mask权限时不存在该种限制）。

  例如：使用chmod设置某文件mask为r，则无法设置该文件的user或group权限为rw或rwx。

  可使用setfacl设置大于mask范围的权限，设置后mask最大权限值被变更为新设置的权限值。

- other  其他用户  对应ACL_OTHER


> ACL_USER_OBJ：相当于Linux里file_owner的permission
> ACL_USER：定义了额外的用户可以对此文件拥有的permission
>
> ACL_GROUP_OBJ：相当于Linux里group的permission
> ACL_GROUP：定义了额外的组可以对此文件拥有的permission
>
> ACL_MASK：定义了ACL_USER, ACL_GROUP_OBJ和ACL_GROUP的最大权限
>
> ACL_OTHER：相当于Linux里other的permission



```shell
getfacl <file>  #获取文件的权限信息

#setfacl [-bkndRLP] { -m|-M|-x|-X ... } <acl规则>
#设置文件权限示例： set -m <u|g|o|m]:[name]:[rwx-] <file>
```

setfacl使用：

- 参数

  - 设置规则的参数
    - `-m`  设置后面的acl规则
    - `-M`  从文件或标准输入读取acl规则
    - `-R`  递归设置后面的acl规则，包括子目录
    - `-d`  设置默认acl规则 （子文件将继承目录ACL权限规则）

  - 删除规则的参数

    - `-x`  删除后面的acl规则
    - `-X`  从文件或标准输入读取acl规则
    - `-b`  删除全部的acl规则
    - `-k`  删除默认的acl规则  （子文件将继承目录ACL权限规则）

    注意：最基本的ugo三个规则不能删除。

- 规则写法：`default:用户类型:名称:权限` （default也可简写为d）

  用户类型即上文所述的u g m o （user/group/mask/others）；

  名称即user的用户名和和group的组名**，mask和others无对应名字，该项留空**；

  权限即`rwx-`。

  ```shell
  #示例
  set -m u:http:r-- /srv/index.html
  set -R u:admin:rwx /srv
  set -m m::r-x /home
  ```

# 附

## linux文件类型

在`ls -l`中第1位字符表示文件类型，各种类型如下： 

- `-`  普通文件(common file)
  - 文本文件（如`/etc/hosts`）
  - 二进制文件（如`/usr/bin/ls`）
  - 数据格式文件（如`/var/logwtmp`）
- `d`  目录(directory)
- `l`  连接(link)
- 设备与装置
  - `b`  块（block）设备（如`/dev/sda`）
  - `c`  字符（character）设备 （如鼠标键盘等串行端口设备）
- `s`  数据接口(sockets)文件
- `p`  数据传输(pipe)文件（ FIFO——first-in-first-out，解决多个程序同时存取一个文件所造成的错误问题）

## 修改文件属性chattr

遇到对不能对某个文件/目录进行某种操作（如删除），但却是对该文件有权限时，应该查看该文件/目录是否设置了某种属性。

- 属性模式：
  - a：让文件或目录仅供附加用途。
  - b：不更新文件或目录的最后存取时间。
  - c：将文件或目录压缩后存放。
  - d：将文件或目录排除在倾倒操作之外。
  - i：不得任意更动文件或目录。
  - s：保密性删除文件或目录。
  - S：即时更新文件或目录。
  - u：预防意外删除。

- 查看属性`lsattr <文件|目录>`

- 设置属性`chattr 选项 <文件|目录>`

  - `-R`：递归处理，将指令目录下的所有文件及子目录一并处理；
  - `+<属性>`：开启文件或目录的该项属性；
  - `-<属性>`：关闭文件或目录的该项属性；
  - `=<属性>`：指定文件或目录的该项属性。

>[root@cent7 ~]# ls -l test
>-rw-r--r--. 1 root root 0 Sep  9 08:13 test
>[root@cent7 ~]# rm test -f
>rm: cannot remove ‘test’: Operation not permitted
>[root@cent7 ~]# lsattr test
>----i----------- test
>[root@cent7 ~]# chattr -i test
>[root@cent7 ~]# rm test -f

