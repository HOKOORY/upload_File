#!/bin/bash
openssldir=/usr/local/src/openssl-1.1.1k

opensshdir=/usr/local/src/openssh-9.0p1

PS3="选择安装的内容，输入数字即可"
select install in openssl  openssh quit ;do

	case $install in 
	openssl)
	cd $openssldir 
	./config --prefix=/usr/local/openssl1.1.1k no-async
	if [ $? -eq 0 ];then
		echo "initialization success"
		mv /usr/bin/openssl /usr/bin/openssl.bak && mv /usr/lib64/openssl /usr/lib64/openssl.bak && mv /usr/lib64/libssl.so /usr/lib64/libssl.bak
	else
		echo "ERROR initialization "
	break
	fi
	
	echo "do...make install"
	make
	if [ $? -eq 0 ];then
		echo "make success"
	else
		echo "make false"
		break
	fi
	make install
	if [ $? -eq 0 ];then
		echo "make install success"
	else
		echo "make install false"
		break
	fi
	ln -s /usr/local/openssl1.1.1k/bin/openssl /usr/bin/openssl
	ln -s /usr/local/openssl1.1.1k/include/openssl /usr/include/openssl
	ln -s /usr/local/openssl1.1.1k/lib/libssl.so /usr/lib64/libssl.so
	echo "/usr/local/openssl1.1.1k/lib" >> /etc/ld.so.conf
	ldconfig -v 
	openssl version
	;;	

	openssh)
	cd  $opensshdir
	./configure --prefix=/usr --sysconfdir=/etc/ssh  --with-ssl-dir=/usr/local/openssl1.1.1k --with-zlib --with-md5-passwords
	if [ $? -eq 0 ];then
		echo "initialization success" 
		mv /etc/ssh /etc/ssh.bak
		mkdir /etc/ssh 
	else
		echo "initialization false"
		break
	fi
	make 
	if [ $? -eq 0 ];then
		echo "make install success"
	else
		echo "make false"
		break	
	fi
	make install
	if [ $? -eq 0 ];then
		echo "make install success"
		echo  "do conf "
		cp $opensshdir/contrib/redhat/sshd.init /etc/init.d/sshd
		echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
		echo 'PubkeyAuthentication yes' >>/etc/ssh/sshd_config
		echo 'PasswordAuthentication yes' >>/etc/ssh/sshd_config
		chmod 600 /etc/ssh/ssh_host_rsa_key
		chmod 600 /etc/ssh/ssh_host_ecdsa_key
		chmod 600 /etc/ssh/ssh_host_ed25519_key
		service sshd restart
		
		break
	else
		echo "make install false"
		break
	fi

	;;
	quit)
	echo "ing quit"
	break 
	;;
	esac
done

