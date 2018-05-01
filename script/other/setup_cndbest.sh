#/bin/sh
CB_UID=0
PREFIX=/vhs/kangle
KANGLE_VERSION="3.5.8.2"
CDNBEST_VERSION="3.3.7"
INSTALL_TMP_DIR="/tmp/cdnbest_install_tmp"
ARCH="-6-x64.tar.gz"
if test `ldd --version|head -1|awk '{print $NF;}'` = "2.5" ; then
	echo "this system (centos5) not suppor,please use centos-6-x86-64 install..."
	exit 0
fi
if test `arch` != "x86_64"; then
	echo "this system (centos6-x86) not suppor,please use centos-6-x86-64 install..."
	exit 0
fi
DOWNLOAD_PREFIX="http://download.cdnbest.com/cdnbest"
if ! test $1 ; then
     echo "Error: Please input cdnbest uid for $0 after"
     exit 0;
fi
CB_UID=$1
param2=$2
param3=$3
UPDATE_MODEL=0
prepare_kangle()
{
	mkdir -p $PREFIX
	cat > $PREFIX/license.txt << END
2
H4sIAAAAAAAAA5Pv5mAAA2bGdoaK//Jw
Lu+hg1yHDHgYLlTbuc1alnutmV304sXT
Jfe6r4W4L3wl0/x376d5VzyPfbeoYd1T
GuZq4nFGinMhz1fGFZVL/wmITGireLB4
dsnsMtVt859fOlutf/eR/1/vm0rGM3KO
ckbtTN504maK75GUSTt31uQK/FrltCPn
cOXlNfU+V5nf1gFtX1iQa9IOpAGFLYQh
ngAAAA==
END
}
setup_kangle()
{
		if test $param3 ; then
			return
		fi
		prepare_kangle	
        echo "start install kangle..."
        if [ -f  $PREFIX/bin/kangle ] ; then
                UPDATE_MODEL=1
                K_LOCAL_VER=`$PREFIX/bin/kangle -v|grep -E "[0-9][.][0-9][.][0-9]" -o`
        fi
        KANGLE_URL="$DOWNLOAD_PREFIX/kangle-cdnbest-$KANGLE_VERSION$ARCH"
        wget $KANGLE_URL -O kangle.tar.gz
        tar xzf kangle.tar.gz
        cd kangle
        if test $UPDATE_MODEL = 0 ; then
                sh install.sh /vhs/kangle
                if [ ! -d $PREFIX/ext ] ; then
                        mkdir -p $PREFIX/ext
                fi
                cat > $PREFIX/ext/vh_db.xml << END
<!--#start 500 -->
<config>
        <vhs>
                <vh_database driver='bin/vhs_sqlite.so' dbname='etc/vhs.db'/>
        </vhs>
		<request >
		<table name='BEGIN'>
				<chain  action='continue' >
						<acl_path  path='/KANGLE_CCIMG.php'></acl_path>
						<mark_anti_session  ></mark_anti_session>
						<mark_host   host='127.0.0.1' port='3319' proxy='1' rewrite='0' life_time='0'></mark_host>
				</chain>
		</table>
		</request>
</config>
END
        service kangle stop 2> /dev/null
        else
                service kangle stop
                \cp bin/kangle $PREFIX/bin/kangle
                \cp bin/autoupdate $PREFIX/bin/autoupdate
                \cp bin/vhs_sqlite.so $PREFIX/bin/vhs_sqlite.go
                \cp bin/webdav.go $PREFIX/bin/webdav.go
                \cp bin/extworker $PREFIX/bin/extworker

        fi
        echo "product=cdnbest" > $PREFIX/.autoupdate.param
}

setup_cdnbest()
{
		if [ ! -f $PREFIX/bin/kangle ] ; then
			echo "install kangle failed ,please retry---"
			exit 0;
		fi
        UPDATE_MODEL=0
        if [ -f $PREFIX/bin/cdnbest ] ;then
                UPDATE_MODEL=1
        fi
        cd $INSTALL_TMP_DIR
        CDNBEST="cdnbest-$CDNBEST_VERSION.`arch`.tar.gz"
        CDNBEST_URL="$DOWNLOAD_PREFIX/$CDNBEST"
        if test $param2 = "--debug" ; then
        	 CDNBEST_URL="$DOWNLOAD_PREFIX/$CDNBEST?uid=$CB_UID$param3"
        fi
        wget $CDNBEST_URL -O cdnbest.tar.gz
        tar xzf cdnbest.tar.gz
        if test $? != 0 ; then
        	exit 1
        fi
        cd cdnbest
        if test $UPDATE_MODEL = 0 ; then
                \cp bin/* $PREFIX/bin/
                mkdir $PREFIX/cdn_home
                mkdir $PREFIX/conf
                \cp conf/* $PREFIX/conf/
                \cp etc/* $PREFIX/etc/
                \cp init/* /etc/init.d/
                chmod 700 /etc/init.d/cdnbest
                chmod 700 /etc/init.d/kangle
                if test $CB_UID != 0 ;then
                        echo $CB_UID > $PREFIX/etc/uid
                fi
                if [ ! -f /etc/rc3.d/S96kangle ] ; then
                        ln -s /etc//init.d/kangle /etc/rc3.d/S96kangle
                fi
                if [ ! -f /etc/rc3.d/S97cdnbest ] ;then
                        ln -s /etc//init.d/cdnbest /etc/rc3.d/S97cdnbest
                fi
                if [ ! -f /etc/rc5.d/S96kangle ] ; then
                        ln -s /etc//init.d/kangle /etc/rc5.d/S96kangle
                fi
                if [ ! -f /etc/rc5.d/S97cdnbest ] ;then
                        ln -s /etc/init.d/cdnbest /etc/rc5.d/S97cdnbest
                fi
        else
                service cdnbest stop 2&> /dev/null
                \cp init/* /etc/init.d/
                chmod 700 /etc/init.d/cdnbest
                chmod 700 /etc/init.d/kangle
                \cp bin/* $PREFIX/bin/
                \cp etc/* $PREFIX/etc/
                \cp conf/* $PREFIX/conf/
        fi

}

rm -rf $INSTALL_TMP_DIR 2> /dev/null
mkdir -p $INSTALL_TMP_DIR 2> /dev/null
cd $INSTALL_TMP_DIR
setup_kangle
setup_cdnbest
/etc/init.d/iptables stop 2&> /dev/null
chkconfig iptables off 2&> /dev/null
service httpd stop 2&> /dev/null
chkconfig httpd off 2&> /dev/null
service kangle stop 2&> /dev/null
service kangle start 
KANGLE_PROCESS_COUNT=`ps aux|grep bin/kangle|wc -l`
if [ 2 \> $KANGLE_PROCESS_COUNT ] ; then
	/vhs/kangle/bin/kangle
fi
service cdnbest stop 2&> /dev/null
service cdnbest start
echo "complate...."
