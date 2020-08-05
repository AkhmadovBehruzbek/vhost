Virtualhost Managing Bash Script
===========

Bu Bash Script sizga apache/nginx yangi local domen(virtual hosts) yaratish va o'chirish amallarini bir qator buyruq bilan bajarishga yordam beradi.
Ubuntu uchun.

## O'rnatish ##

1. Scriptni yuklab oling.
2. Kerakli buyruqlarni bajarishi uchun unga huquq bering:

```
$ chmod +x /path/to/vhost.sh
```

3. Tanlovli: Agar siz scriptni global muhitda ishlatmoqchi bo'lsangiz, unda bu faylni /usr/local/bin papkaga ko'chiring, is better
Agar .sh formatsiz nusxalasangiz qulay bo'ladi:

```bash
$ sudo cp /path/to/vhost.sh /usr/local/bin/vhost
```


## Foydalanish ##

Asosiy buyruq sintaksis:

```bash
$ sudo sh /path/to/vhost.sh [create | delete] [domain] [optional host_dir]
```

/usr/local/bin ga o'rnatilganda

```bash
$ sudo vhost [create | delete] [domain] [optional host_dir]
```

### Misol uchun ###

Yangi virtual host yaratish uchun:

```bash
$ sudo vhost create mysite.dev
```
Yangi virtual hostni o'zingiz xohlagan papka yo'naltirmoqchi bo'lsangiz:

```bash
$ sudo vhost create anothersite.dev my_dir
```
Virtual host ni o'chirish uchun

```bash
$ sudo vhost delete mysite.dev
```

Maxsus papkaga o'rnatilgan virtual host o'chirmoqchi bo'lsangiz:

```
$ sudo vhost delete anothersite.dev my_dir
```

#Happy coding!
