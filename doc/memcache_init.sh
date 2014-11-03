#!/bin/sh
        #
        # memcached    Startup script for memcached processes
        #
        # chkconfig: - 90 10
        # description: Memcache provides fast memory based storage.
        # processname: memcached

        [ -f memcached ] || exit 0

        prog="memcached"

        start() {
            echo -n $"Starting $prog "
            # Starting memcached with 64MB memory on port 11211 as deamon and user nobody
            memcached -m 64 -p 11211 -d -u nobody

            RETVAL=$?
            echo
            return $RETVAL
        }

        stop() {
            if test "x`pidof memcached`" != x; then
                echo -n $"Stopping $prog "
                killall memcached
                echo
            fi
            RETVAL=$?
            return $RETVAL
        }

        case "$1" in
                start)
                    start
                    ;;

                stop)
                    stop
                    ;;

                restart)
                    stop
                    start
                    ;;
                condrestart)
                    if test "x`pidof memcached`" != x; then
                        stop
                        start
                    fi
                    ;;

                *)
                    echo $"Usage: $0 {start|stop|restart|condrestart}"
                    exit 1

        esac

        exit $RETVAL
                    
