#!/bin/bash
set -e
echo "[ ****************** ] Starting Endpoint of Application"
if ! [ -d "/var/www/salic-br" ] || ! [ -d "/var/www/salic-br/application" ]; then
    echo "Application not found in /var/www/salic-br - cloning now..."
    if [ "$(ls -A /var/www/salic-br)" ]; then
        echo "WARNING: /var/www/salic-br is not empty - press Ctrl+C now if this is an error!"
        ( set -x; ls -A; sleep 5 )
    fi
    echo "[ ****************** ] Cloning Project repository to tmp folder"
    #rm -Rf /tmp/salic-br
    git clone -b "$GIT_BRANCH" $GIT_REPOSITORY /tmp/salic-br
    ls -la /tmp/salic-br

    echo "[ ****************** ] Copying Project from temporary folder to workdir"
 #    cp /tmp/salic-br -rT /var/www/salic-br
    cp /tmp/salic-br -R /var/www/


    echo "[ ****************** ] Changing owner and group from the Project to 'www-data' "
    chown www-data:www-data -R /var/www/salic-br

    ls -la /var/www/salic-br

    echo "[ ****************** ] Complete! The application has been successfully copied to /var/www/salic-br"

    cd /var/www/salic-br

    echo [ ****************** ]" Installing composer dependencies."
    composer install --prefer-source --no-interaction
fi


if  ! [ -e "/var/www/salic-br/application/configs/application.ini" ] ; then
    echo "[ ****************** ] Copying sample application configuration to real one"
    cp /var/www/salic-br/application/configs/exemplo-application.ini /var/www/salic-br/application/configs/application.ini
fi


# X-Debug

if ! [ -v $XDEBUG_INSTALL ] ; then
    echo "[ ****************** ] Starting install of XDebug and dependencies."
	pecl shell-test xdebug && echo "Package xdebug Installed" || (
		yes | pecl install xdebug 
		echo "zend_extension="`find /usr/local/lib/php/extensions/ -iname 'xdebug.so'` > $XDEBUGINI_PATH
    	echo "xdebug.remote_enable=$XDEBUG_REMOTE_ENABLE" >> $XDEBUGINI_PATH

    	if ! [ -d "$XDEBUG_PROFILER_OUTPUT_DIR" ] ; then
    		mkdir -p $XDEBUG_PROFILER_OUTPUT_DIR
    	fi
    	if ! [ -v $XDEBUG_REMOTE_AUTOSTART ] ; then
        	echo "xdebug.remote_autostart=$XDEBUG_REMOTE_AUTOSTART" >> $XDEBUGINI_PATH
    	fi
    	if ! [ -v $XDEBUG_REMOTE_CONNECT_BACK ] ; then
        	echo "xdebug.remote_connect_back=$XDEBUG_REMOTE_CONNECT_BACK" >> $XDEBUGINI_PATH
    	fi
		if ! [ -v $XDEBUG_REMOTE_HANDLER ] ; then
        	echo "xdebug.remote_handler=$XDEBUG_REMOTE_HANDLER" >> $XDEBUGINI_PATH
    	fi
		if ! [ -v $XDEBUG_PROFILER_ENABLE ] ; then
        	echo "xdebug.profiler_enable=$XDEBUG_PROFILER_ENABLE" >> $XDEBUGINI_PATH
    	fi
    	if ! [ -v $XDEBUG_PROFILER_OUTPUT_DIR ] ; then
    		echo "xdebug.profiler_output_dir=$XDEBUG_PROFILER_OUTPUT_DIR" >> $XDEBUGINI_PATH
    	fi
    	if ! [ -v $XDEBUG_REMOTE_PORT ] ; then
    		echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> $XDEBUGINI_PATH
    	fi
    	if ! [ -v $XDEBUG_REMOTE_HOST ] ; then
    		echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> $XDEBUGINI_PATH
    	fi

    	if ! [ -v $XDEBUG_DEFAULT_ENABLE ] ; then
            echo "xdebug.default_enable=$XDEBUG_DEFAULT_ENABLE" >> $XDEBUGINI_PATH
        fi
        if ! [ -v $XDEBUG_IDEKEY ] ; then
            echo "xdebug.idekey=$XDEBUG_IDEKEY" >> $XDEBUGINI_PATH
        fi

    	echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> $XDEBUGINI_PATH
    	#echo "xdebug.remote_host="`hostname -I` >> $XDEBUGINI_PATH
    	#echo "xdebug.remote_host=localhost" >> $XDEBUGINI_PATH

		echo "[ ****************** ] Ending install of XDebug and dependencies."
	)
fi

echo "[ ****************** ] Ending Endpoint of Application"
exec "$@"
