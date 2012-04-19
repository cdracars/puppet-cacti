class cacti {

    package {[ "libsnmp-base",
    "libsnmp15",
    "snmp",
    "snmpd" ]:
    ensure => present,
    } # package

    package {
        "cacti":
            require => [Package["libsnmp-base", "libsnmp15", "snmp", snmpd]],
    } # package

    # allow the cacti user to run cron jobs
    # pam::accesslogin { "cacti": }

    file {
        "/etc/cacti/db.php":
            source  => "/tmp/vagrant-puppet/modules-0/cacti/files/db.php",
            require => [ Package["cacti"], Package["apache2"] ],
            owner   => "cacti",
            group   => "www-data",
            mode    => 640;
        "/etc/cron.d/cacti":
            content => "*/5 * * * *  root /usr/bin/php /usr/share/cacti/site/poller.php > /dev/null 2>&1",
            require => Package["cacti"];
    } # file

    cron { cacti:
    command => "/usr/bin/php /usr/share/cacti/site/poller.php > /dev/null 2>&1",
    user => root,
    minute => '*/5'
    }

    exec { "cacti_db_setup":
        # unless => "/usr/bin/mysql -uroot cacti",
        command => "/usr/bin/mysql -uroot -hlocalhost -P3306 cacti < /tmp/vagrant-puppet/modules-0/cacti/files/cacti.sql",
        require => Class["mysql"],
    } # exec

    file { "/etc/apache2/conf.d/cacti.conf": 
    ensure => symlink, 
    target => "/etc/cacti/apache.conf", 
    require => Package["apache2", "cacti"], 
    } 

} # class cacti
