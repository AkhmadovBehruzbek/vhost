#!/bin/bash
### Set Language
TEXTDOMAIN=vhost

### Set default parameters
action=$1
domain=$2
rootDir=$3
owner=$(who am i | awk '{print $1}')
apacheUser=$(ps -ef | egrep '(httpd|apache2|apache)' | grep -v root | head -n1 | awk '{print $1}')
email='webmaster@localhost'
sitesEnabled='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
userDir='/home/www/'
sitesAvailabledomain=$sitesAvailable$domain.conf

### don't modify from here unless you know what you are doing ####

if [ "$(whoami)" != 'root' ]; then
	echo $"Sizda $0 ni  as non-root foydalanuvchi sifatida ishga tushirish uchun huquq mavjud emas. sudo dan foydalaning."
		exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]
	then
		echo $"vhost amal tanlang(create or delete) -- ~~kichkina harflar bilan yozing~~"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Iltimos domen nomi kiriting. e.g.dev,staging"
	read domain
done

if [ "$rootDir" == "" ]; then
	rootDir=${domain//./}
fi

### if root dir starts with '/', don't use /home/www as default starting point
if [[ "$rootDir" =~ ^/ ]]; then
	userDir=''
fi

rootDir=$userDir$rootDir

if [ "$action" == 'create' ]
	then
		### check if domain already exists
		if [ -e $sitesAvailabledomain ]; then
			echo -e $"Bu domen mavjud.\nIltimos boshqa kiriting. "
			exit;
		fi

		### check if directory exists or not
		if ! [ -d $rootDir ]; then
			### create the directory
			mkdir $rootDir
			### give permission to root dir
			chmod 755 $rootDir
			### write test file in the new domain dir
			if ! echo "<?php echo phpinfo(); ?>" > $rootDir/phpinfo.php
			then
				echo $"Xatolik: $rootDir/phpinfo.php ga yozolmayapman. Menga huquq bering."
				exit;
			else
				echo $"$rootDir/phpinfo.php ga test kodi yozildi."
			fi
		fi

		### create virtual host rules file
		if ! echo "
		<VirtualHost *:80>
			ServerAdmin $email
			ServerName $domain
			ServerAlias $domain
			DocumentRoot $rootDir
			<Directory />
				AllowOverride All
			</Directory>
			<Directory $rootDir>
				Options Indexes FollowSymLinks MultiViews
				AllowOverride all
				Require all granted
			</Directory>
			ErrorLog /var/log/apache2/$domain-error.log
			LogLevel error
			CustomLog /var/log/apache2/$domain-access.log combined
		</VirtualHost>" > $sitesAvailabledomain
		then
			echo -e $"$domain faylini yaratish xatolik yuz berdi."
			exit;
		else
			echo -e $"\nYangi Virtualhost domen yaratildi.\n"
		fi

		### Add domain in /etc/hosts
		if ! echo "127.0.0.1	$domain" >> /etc/hosts
		then
			echo $"Xatolik: /etc/hosts ga yozolmayapman."
			exit;
		else
			echo -e $"Host nomi /etc/hosts fayliga yozildi. \n"
		fi

		### Add domain in /mnt/c/Windows/System32/drivers/etc/hosts (Windows Subsytem for Linux)
		if [ -e /mnt/c/Windows/System32/drivers/etc/hosts ]
		then
			if ! echo -e "\r127.0.0.1       $domain" >> /mnt/c/Windows/System32/drivers/etc/hosts
			then
				echo $"Xatolik: /mnt/c/Windows/System32/drivers/etc/hosts fayliga yozolmayapman. (Yechim: administrator Bash|CMD ni administrator huuqi bilan ishlatib ko'ring)"
			else
				echo -e $"Host added to /mnt/c/Windows/System32/drivers/etc/hosts ga yangi host qo'shildi. \n"
			fi
		fi

		if [ "$owner" == "" ]; then
			iam=$(whoami)
			if [ "$iam" == "root" ]; then
				chown -R $apacheUser:$apacheUser $rootDir
			else
				chown -R $iam:$iam $rootDir
			fi
		else
			chown -R $owner:$owner $rootDir
		fi

		### enable website
		a2ensite $domain

		### restart Apache
		/etc/init.d/apache2 reload

		### show the finished message
		echo -e $"Tugatildi! \n Yangi Virtual Host yaratdingiz. \nYangi host manzili: http://$domain \n va u $rootDir  manzilda."
		exit;
	else
		### check whether domain already exists
		if ! [ -e $sitesAvailabledomain ]; then
			echo -e $"Bu domen mavjud emas.\nIltimos boshqasini urinib ko'ring."
			exit;
		else
			### Delete domain in /etc/hosts
			newhost=${domain//./\\.}
			sed -i "/$newhost/d" /etc/hosts

			### Delete domain in /mnt/c/Windows/System32/drivers/etc/hosts (Windows Subsytem for Linux)
			if [ -e /mnt/c/Windows/System32/drivers/etc/hosts ]
			then
				newhost=${domain//./\\.}
				sed -i "/$newhost/d" /mnt/c/Windows/System32/drivers/etc/hosts
			fi

			### disable website
			a2dissite $domain

			### restart Apache
			/etc/init.d/apache2 reload

			### Delete virtual host rules files
			rm $sitesAvailabledomain
		fi

		### check if directory exists or not
		if [ -d $rootDir ]; then
			echo -e $"Delete host root directory ? (y/n)"
			read deldir

			if [ "$deldir" == 'y' -o "$deldir" == 'Y' ]; then
				### Delete the directory
				rm -rf $rootDir
				echo -e $"Papka o'chirildi."
			else
				echo -e $"Host papkasi himoyalandi."
			fi
		else
			echo -e $"Host papkasi topilmadi. Otkazibi yuborildi."
		fi

		### show the finished message
		echo -e $"Tugatildi!\nSiz $domain ni o'chirdingiz!"
		exit 0;
fi
