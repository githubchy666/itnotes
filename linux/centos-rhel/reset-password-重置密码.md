1. 修改引导
   1. 在grub引导界面，按下`e`修改选项。
   2. 移动光标到启动项目一行（该行内容以类似`linux 16`开始）的最后，添加空格，再添加`rd.break`。
   3. <kbd>ctrl</kbd> <kbd>x</kbd>完成修改，开始系统引导。
2. 修改密码
   1. `mount -o remount,rw /sysroot` 重新挂载`/sysroot`；
   2. `chroot /sysroot` 更改根目录；
   3. `passwd root`修改密码；
   4. `touch /.autorelabel`  开启了SELinux的情况下必须执行该步骤；
   5. `exit`或<kbd>ctrl</kbd> <kbd>d</kbd>退出`chroot`；
   6. `exit`或<kbd>ctrl</kbd> <kbd>d</kbd>或`reboot`重启系统。