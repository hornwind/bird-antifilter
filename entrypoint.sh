#!/bin/sh
echo "----------------------"
echo "Create bird.conf"
echo "----------------------"

cat > /etc/bird/bird.conf <<EOF
log syslog all;
router id $ROUTER_ID;

protocol kernel {
    ipv4 {
        import none;
        export none;
    };
    scan time $SCAN_TIME;
}

protocol device {
        scan time $SCAN_TIME;
}

protocol static static_bgp {
    ipv4;
    include "subnet.txt";
    include "ipsum.txt";
}

protocol bgp OurRouter {
    description "Our Router";
    neighbor $NEIGHBOR_IP as $NEIGHBOR_AS;
    local as $LOCAL_AS;
    source address $SOURCE_ADDRESS;
    passive off;
    ipv4 {
        import none;
        export where proto = "static_bgp";
        next hop self;
    };
}
EOF

cat /etc/bird/bird.conf

echo "Download and create network lists"
echo "----------------------"

cd /blacklist/list
wget -N https://antifilter.download/list/ipsum.lst https://antifilter.download/list/subnet.lst
old=$(cat /tmp/md5.txt);
new=$(cat /blacklist/list/*.lst | md5sum | head -c 32);
if [ "$old" != "$new" ]
then
cat /blacklist/list/ipsum.lst | sed 's_.*_route & reject;_' > /etc/bird/ipsum.txt
cat /blacklist/list/subnet.lst | sed 's_.*_route & reject;_' > /etc/bird/subnet.txt
logger "RKN list reconfigured at $(date)";
echo $new > /tmp/md5.txt;
fi

echo "----------------------"
echo "add chklist cron"
echo "----------------------"

cat > /etc/crontabs/root <<EOF
SHELL=/bin/sh
MAILTO=''
$CRON_MIN * * * * /blacklist/chklist
EOF

cat /etc/crontabs/root

echo "----------------------"
chmod +x /blacklist/chklist

exec "$@"