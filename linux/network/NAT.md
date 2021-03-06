# 简介

> **网络地址转换**（Network Address Translation，缩写为NAT），也叫做**网络掩蔽**或者**IP掩蔽**（IP masquerading），是一种在IP数据包通过[路由器](https://zh.wikipedia.org/wiki/%E8%B7%AF%E7%94%B1%E5%99%A8)或[防火墙](https://zh.wikipedia.org/wiki/%E9%98%B2%E7%81%AB%E5%A2%99)时重写来源IP地址或目的[IP地址](https://zh.wikipedia.org/wiki/IP%E5%9C%B0%E5%9D%80)的技术。

NAT实现了内部网络中的主机访问外部资源，以及外部网络中主机访问内部网络主机；通过NAT可以隐藏内部私有网络主机，提高内网网络主机的安全性。

> NAT广泛用于在有多台主机但只通过一个公有IP地址访问因特网的**私有网络**中。因为IPV4地址数量的不足，NAT作为解决[IPv4地址短缺](https://zh.wikipedia.org/wiki/IPv4%E4%BD%8D%E5%9D%80%E6%9E%AF%E7%AB%AD)以避免保留IP地址困难的方案而流行起来。

附：IPv4的3组私有IP地址

- A  10.0.0.0~10.255.255.255.255
- B  172.16.0.0.0~172.31.255.255
- C  192.168.0.0~192.168.255.255

## NAT转换类型

- 静态转换

  私有IP地址转换为固定的共有IP地址——一对一固定映射。

- 动态转换

  私有IP地址转换为随机的公有IP地址——一对一动态映射到可用地址池中的一个。

- 端口转换（PNAT，端口多路复用）

  修改数据包的源端口并进行**端口转换**，私有网络中多台主机**共用一个公有IP地址**——多对一。

# 配置

NAT架构示意图

```bash
  ---------                        -----------
   外部资源  ===外部网络===——[网口1]——  NAT服务器（NAT网关）
  ---------                        -----|-----
                     -------          [网口2]
====|==========|===== 交换机 ============|=====内部网络
    |          |     -------      
 ---|---   ----|----
 内部主机     内部主机
--------   ---------
```

## NAT服务器配置

下文所述为使用端口多路复用方式配置内部网络主机访问外部网络资源的示例。

按上图所示，假如该NAT中外部网络网口（网口1）为`ens1`，内网网络网口（网口2）为`ens2`。NAT服务器负责将内部网络的流量（来自ens2）转换到外部网络（通过ens1）。

1. 开启ip转发

   ```shell
   #查看开启状态
   sysctl net.ipv4.ip_forward
   #或 sysctl -a |grep ip_forward
   #或 cat /proc/sys/net/ipv4/ip_forward
   
   #临时开启（暂时开启，重启后失效）
   echo 1 > /proc/sys/net/ipv4/ip_forward
   sysctl -w net.ipv4.ip_forward=1
   
   #永久生效
   echo net.ipv4.ip_forward=1 > /etc/sysctl.d/ip_forward.conf
   ```

2. 使用firewall进行转发

   将外部网络网口ens1（网口1）接入到往外部网络区域（external）中，将内部网络网口ens2（网口2）接入到往内部网络区域（internal）中。

   ```shell
   #查看网口的网络区域
   firewall-cmd --get-zone-of-interface=enp175s0f0
   firewall-cmd --get-zone-of-interface=enp175s0f1
   
   #将外部网络网口ens1（网口1）的网络区域设置为external
   firewall-cmd --permanent --zone=external --change-interface=ens1
   
   #将内部网络网口ens2（网口2）的网络区域设置为internal
   firewall-cmd --permanent --zone=internal --change-interface=ens2
   
   #查看所有外部网络区域配置
   firewall-cmd --zone=external --list-all
   #如果上面查看配置的结果中masquerade（伪装）为no则使用下面命令将其打开
   firewall-cmd --permanent  --zone=external --add-masquerade
   
   #重启服务
   firewall-cmd --reload
   ```

## 内部网络主机配置

修改内部网络中主机的网络连接参数：

- 网关：为NAT服务器的内部网络网口（网口2，ens2）的IP地址
- DNS：同NAT服务器