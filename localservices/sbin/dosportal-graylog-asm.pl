#!/usr/bin/perl

#
# (c) Security Guy 2015.04.17
#

# flush buffers after every write
$| = 1;

use strict;
use warnings;

#CREATE database dosportal;

#CREATE TABLE `our_networks` (
#  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
#  `sourceip` varchar(15) NOT NULL DEFAULT '-',
#  `cidr` smallint(2) NOT NULL DEFAULT '32',
#  `country` varchar(3) NOT NULL DEFAULT 'UNK',
#  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
#  `hits` int(8) unsigned NOT NULL DEFAULT '0',
#  `comment` varchar(250) NOT NULL DEFAULT '-',
#  `insertby` varchar(250) NOT NULL DEFAULT '-',
#  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
#) ENGINE=InnoDB;

#CREATE TABLE `DYNAMIC_HTTP_IN` (
#  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
#  `sourceip` varchar(15) NOT NULL DEFAULT '-',
#  `cidr` smallint(2) NOT NULL DEFAULT '32',
#  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
#  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
#  `hits` int(8) unsigned NOT NULL DEFAULT '0',
#  `country` varchar(3) NOT NULL DEFAULT 'UNK',
#  `comment` varchar(250) NOT NULL DEFAULT '-',
#  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
#  `insertby` varchar(250) NOT NULL DEFAULT '-',
#  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
#) ENGINE=InnoDB;

#CREATE TABLE `DYNAMIC_HTTP_IN_temp_whitelist` (
#  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
#  `sourceip` varchar(15) NOT NULL DEFAULT '-',
#  `cidr` smallint(2) NOT NULL DEFAULT '32',
#  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
#  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
#  `hits` int(8) unsigned NOT NULL DEFAULT '0',
#  `country` varchar(3) NOT NULL DEFAULT 'UNK',
#  `comment` varchar(250) NOT NULL DEFAULT '-',
#  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
#  `insertby` varchar(250) NOT NULL DEFAULT '-',
#  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
#) ENGINE=InnoDB;

#CREATE TABLE `graylog_settings_connections` (
#  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
#  `connections` smallint(6) unsigned NOT NULL DEFAULT '200',
#  `block_for` int(10) unsigned NOT NULL DEFAULT '200',
#  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  `comment` varchar(250) NOT NULL DEFAULT '-',
#  `insertby` varchar(250) NOT NULL DEFAULT '-',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `myindex` (`connections`)
#) ENGINE=InnoDB;

#DYNAMIC_HTTP_IN_history_thresholdhits | CREATE TABLE `DYNAMIC_HTTP_IN_history_thresholdhits` (
#  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
#  `hits` smallint(6) unsigned NOT NULL DEFAULT '200',
#  `block_for` int(10) unsigned NOT NULL DEFAULT '200',
#  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  `comment` varchar(250) NOT NULL DEFAULT '-',
#  `insertby` varchar(250) NOT NULL DEFAULT '-',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `myindex` (`hits`)
#) ENGINE=InnoDB;



use POSIX qw(strftime);      # time options
use DBI;                     # sql
use Socket qw( inet_aton );  # ip methods
use Term::ANSIColor;         # colored output
use Geo::IP;                 # GeoIP location
use IO::Socket;              # socket to communicate w remote server

use WWW::Curl;               # for curl install perl-WWW-Curl: yum install perl-WWW-Curl
use WWW::Curl::Easy;         # for curl install perl-WWW-Curl: yum install perl-WWW-Curl

use File::Basename;          # for basename

BEGIN {
    use constant VERSION    => "0.2.18";
    use constant RELDATE    => "2015.04.16";
    use constant BY         => "Security Team";
}


sub ip2long($);
sub in_subnet($$);
sub get_graylog_list;
sub graylog1_log_bad_ip;
sub get_graylog_strings_from_db;
sub nearest_hits;
sub get_history_thresholds;
sub return_country;


# http://www.perlmonks.org/?node_id=884064
sub nearest{
    my ( $dist, $href ) = @_;
    my ( $answer ) = ( sort { abs( $a - $dist ) <=> abs( $b - $dist ) } keys %$href );
    return $href -> { $answer };
}

# http://www.perlmonks.org/?node_id=129566
sub ipsort {
  my @a = split /\./, $a;
  my @b = split /\./, $b;

  return $a[0] <=> $b[0]
      || $a[1] <=> $b[1]
      || $a[2] <=> $b[2]
      || $a[3] <=> $b[3];
}

# http://code.activestate.com/recipes/577450-perl-url-encode-and-decode/
sub urlencode {
    my $s = shift;
    $s =~ s/ /+/g;
    $s =~ s/([^A-Za-z0-9\+-])/sprintf("%%%02X", ord($1))/seg;
    return $s;
}

# http://code.activestate.com/recipes/577450-perl-url-encode-and-decode/
sub urldecode {
    my $s = shift;
    $s =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    $s =~ s/\+/ /g;
    return $s;
}

sub delayme {
    my $minimum = 3;
    my $range = 10;
    my $sleeptime = int(rand($range)) + $minimum;
    print color("yellow"),"[*] $0: Sleeping rand time: $sleeptime seconds\n",color("reset");
    sleep($sleeptime);
}

# http://stackoverflow.com/questions/2014862/how-can-i-access-ini-files-from-perl
sub iniRead
{
        my $ini = $_[0];
        my $conf;
        my $section;
        open (INI, "$ini") || die "Can't open $ini: $!\n";
        while (<INI>) {
                chomp;
                if (/^\s*\[\s*(.+?)\s*\]\s*$/) {
                        $section = $1;
                }

                if ( /^\s*([^=]+?)\s*=\s*(.*?)\s*$/ ) {
                        $conf->{$section}->{$1} = $2;

                        if (not defined $section) {
                                warn "Line outside of section '$_'\n";
                                next;
                        }

                }
        }
        close (INI);
        return $conf;
}


(my $configfile   = "/etc/" . basename($0)) =~ s/^(.*?)(?:\..*)?$/$1.conf/;
my $inifile    = iniRead($configfile);

my %mysql = (
        'DB'     => $inifile->{'dosportal'}->{'DB'},
        'TABLE'  => $inifile->{'dosportal'}->{'TABLE'},
        'USER'   => $inifile->{'dosportal'}->{'USER'},
        'PWD'    => $inifile->{'dosportal'}->{'PWD'},
        'HOST'   => $inifile->{'dosportal'}->{'HOST'}
);

my %msettings = (
        'graylog_cidr'         => '32',
        'graylog_min_hits'     => $inifile->{'graylog'}->{'min_hits'},
        'graylog_time'         => $inifile->{'graylog'}->{'time'},
        'graylog_user_dosp'    => $inifile->{'graylog'}->{'user_dosp'},
        'graylog_log_to'       => $inifile->{'graylog'}->{'log_to'},
        'graylog_sec_port'     => $inifile->{'graylog'}->{'sec_port'},
        'graylog_sec_service'  => $inifile->{'graylog'}->{'sec_service'},
        'graylog_sec_bl_w'     => $inifile->{'graylog'}->{'sec_bl_w'},
        'graylog_web'          => $inifile->{'graylog'}->{'web'},
        'graylog_url'          => $inifile->{'graylog'}->{'url'},
        'graylog_port'         => $inifile->{'graylog'}->{'port'},
        'msg_from'             => $inifile->{'graylog'}->{'msg_from'},
        'graylog_comment'      => $inifile->{'graylog'}->{'comment'},
        'graylog_insert_by'    => $inifile->{'graylog'}->{'insert_by'}
);



# inserted delay so we don't hammer database server
&delayme;

#Verbose errors for MySQL
my %attr = ( PrintError => 1, RaiseError => 1, PrintWarn => 0 );

# get an list of whitelisted networks and store them in an array
my @whitelist = &whitelist();
my @tempwhitelist = &tempwhitelist();


my %dist = &auth_thresholds();           # get a list of settings stored in mysql
my %history_thresholds = &get_history_thresholds ();      # get a list of settings stored in mysql

# get list of numbers & IPs
my $list = &getGraylogBadGuys($msettings{'graylog_min_hits'}, $msettings{'graylog_time'} );
#my @asm_list = split (/\n/,$list);
my @asm_list = split (/[\r\n]+/,$list);


# do we have at least one element ?
if ( scalar (@asm_list) > 0 ) {

        printf("%-15s %-20s %-10s %9s\n", "IP", "HITS", "HISTORY", "COUNTRY");
        # sort the hash by IP
        foreach my $line (@asm_list)
        {

                chomp($line);

                # skip comments (unix type), blank lines, and skip 10.50
                next if ( $line =~ /^http/ || $line =~ /^#/ || $line =~ /^\s+$/ || $line =~ /^$/ );
                #next if $line =~ /^#/;
                #next if $line =~ /^\s+$/;
                #next if $line =~ /^$/;

                # skip 0.0.0.0 to prevent blocking ourselves
                next if $line =~ /0\.0\.0\.0/;

                # skip lines if IP is not found on line
                next if $line !~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/;

                # match page w "number IP"
                my ($no_hits, $badip) = ($line =~ m{(?:\s*)(\d+)(?:\s+)(\d+\.\d+\.\d+\.\d+)(?:.*)});

                my $found ='0';
                my $db_string = "ASM";

                if ( scalar (@whitelist) > 0)
                {
                        # check if IP is in our whitelist
                        foreach my $subnet (@whitelist) {
                                if(in_subnet($badip, $subnet )){
                                        $found = '1';
                                        last; # replaced next with last
                                }
                        }
                }

                # check if the IP is whitelisted
                if (scalar(@tempwhitelist) > 0)
                {
                         if ( grep { $_ eq $badip} @tempwhitelist ) {
                                 $found = '1';
                         }
                }

                 if ($found == '0') {
                         my $n = 0;

                         next if ($no_hits < $msettings{"graylog_min_hits"});

                         $n = &get_history_count($badip);

                         # set to a random number, this get overwritten below
                         my $block_seconds = '3600';

                         my $geoip_country = &return_country ($badip);


                         if ($n > 0 ) {
                             # is IP repeated offender ?
                             $block_seconds = nearest( $no_hits, \%history_thresholds );
                         } else {
                             # is IP temp offender ?
                             $block_seconds = nearest( $no_hits, \%dist );
                         }

                         #print color("yellow"),"IP:$badip\tHITS:$no_hits\tHISTORY:$n\tCOUNTRY:$geoip_country\n",color("reset");
                         #printf "IP:$badip\tHITS:$no_hits\tHISTORY:$n\tCOUNTRY:$geoip_country\n",color("reset");
                         printf("%-15s %-20s %-10s %9s\n", $badip, $no_hits, $n, $geoip_country);

                         ## first we need to insert the IP into the DB
                         &mysql_insert($badip,$no_hits,$block_seconds,$n,$geoip_country);

                         ## next we log the block into separate graylog server
                         &log_bad_ip ($badip,$db_string,$no_hits,$block_seconds,$n,$geoip_country);

                 } # end if found


        } # end foreach


} # end while


#################################################################
#########################   FUNCTIONS   #########################
#################################################################
sub whitelist {
        print color("yellow"),"[*] $0: mysql => getting settings from whitelist (our_networks) [*]\n",color("reset");
        my (@temp) = ();
        my ($wh_entry)='';

        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))
        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("SELECT CONCAT(sourceip,'/',cidr) AS network from our_networks");
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       #print "[$0]: INFO: whitelist =>";
       while (my $ref = $sth->fetchrow_hashref()) {
              my $wh_entry = $ref->{'network'};
              # check if this is really an ip
              if ($wh_entry =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/) {
       #            print "\t\t$wh_entry";
                   push(@temp,$wh_entry);
              }
       #       print "\n";
       }

       $sth->finish();
       $dbh->disconnect;
       return (@temp);
}

sub tempwhitelist {
        print color("yellow"),"[*] $0: mysql => getting settings from tempwhitelist (DYNAMIC_HTTP_IN_temp_whitelist) [*]\n",color("reset");
        my (@temp) = ();
        my ($wh_entry)='';

        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))

        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("SELECT sourceip from DYNAMIC_HTTP_IN_temp_whitelist");
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       #print "[$0]: INFO: whitelist =>";
       while (my $ref = $sth->fetchrow_hashref()) {
              my $wh_entry = $ref->{'sourceip'};
              # check if this is really an ip
              if ($wh_entry =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/) {
       #            print "\t\t$wh_entry";
                   push(@temp,$wh_entry);
              }
       #       print "\n";
       }

       $sth->finish();
       $dbh->disconnect;
       return (@temp);
}

sub log_bad_ip ()
{

    my ($sourceip,$string_for_logging,$myhits,$secexpire,$repeated_offender,$country) = @_;

    # skip sending offender to Graylog if we seen this IP already
    #if ($repeated_offender == '0') { 

        my $etime = strftime "%F %T", (localtime(time() + $secexpire));
        my $now   = strftime "%F %T", (localtime(time()) );


        my $client = new IO::Socket::INET(
            PeerAddr => $msettings{"graylog_log_to"},
            PeerPort => $msettings{"graylog_sec_port"},
            Timeout => 5,
            Proto => 'udp',
        );

        $client->send("{ \"version\": \"1.1\", \"host\": \"$msettings{'msg_from'}\", \"short_message\": \"Blocked IP Log \", \"hservice\": \"$msettings{'graylog_sec_service'}\", \"URI\": \"$string_for_logging\", \"Severity\": \"Error\", \"AttackType\": \"Abuse of Functionality\", \"Violations\": \"Brute Force\", \"SourceIP\": \"$sourceip\", \"Cidr\": \"$msettings{'graylog_cidr'}\", \"InsertTime\": \"$now\", \"ExpireTime\": \"$etime\", \"Blocked_With\": \"$msettings{'graylog_sec_bl_w'}\", \"Hits\": \"$myhits\", \"RepeatedOffender\": \"$repeated_offender\", \"Country\": \"$country\" }"); # or die "Send: $!\n";

        # and terminate the connection when we're done
        close($client);
    #}

}
# insert row into DB
sub mysql_insert($$)
{
        #print "[*] mysql => getting settings from (DYNAMIC_HTTP_IN_history_thresholdhits) [*]\n";
        my ($badip,$num,$sec,$repeted_offender,$country)= @_;

        my $expiretime=strftime "%F %T", (localtime(time() + $sec));
        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30;",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))
        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("INSERT INTO DYNAMIC_HTTP_IN (`sourceip`,`cidr`,`expiretime`,`insertby`,`hits`,`comment`,`country`) VALUES ('%s','%s','%s','%s','%s','%s','%s') ON DUPLICATE KEY UPDATE inserttime=VALUES(inserttime),expiretime=VALUES(expiretime),hits=VALUES(hits),country=VALUES(country)",
                   $badip,$msettings{'graylog_cidr'},$expiretime,$msettings{'graylog_insert_by'},$num,$msettings{'graylog_comment'}, $country );
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       $sth->finish();
       $dbh->disconnect;

}
sub auth_thresholds ()
{
        print color("yellow"), "[*] $0: mysql => getting settings from (graylog_settings_connections) [*]\n", color("reset");
        my %my_entries = ();
        my ($wh_entry)='';

        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))
        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("SELECT connections,block_for from graylog_settings_connections");
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       while (my $ref  = $sth->fetchrow_hashref()) {
              my $connections  = $ref->{'connections'};
              my $block_for    = $ref->{'block_for'};
              $my_entries{$connections} = $block_for;
       }

       $sth->finish();
       $dbh->disconnect;
       return (%my_entries);
}
sub get_history_thresholds ()
{
        print color("yellow"), "[*] $0: mysql => getting settings from (DYNAMIC_HTTP_IN_history_thresholdhits) [*]\n", color("reset");
        my %my_entries = ();
        my ($wh_entry)='';

        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))
        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("SELECT hits,block_for from DYNAMIC_HTTP_IN_history_thresholdhits");
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       while (my $ref  = $sth->fetchrow_hashref()) {
              my $hits       = $ref->{'hits'};
              my $block_for  = $ref->{'block_for'};
              $my_entries{$hits} = $block_for;
       }

       $sth->finish();
       $dbh->disconnect;
       return (%my_entries);
}
sub get_history_count ()
{
        #print "[*] mysql => getting settings from DYNAMIC_HTTP_IN_history\n";
        my $ip    = $_[0];
        my $entry = 0;

        my $dsn = sprintf("DBI:mysql:database=%s;host=%s;mysql_connect_timeout=30",$mysql{'DB'},$mysql{'HOST'});
        my $dbh;

        if (!($dbh = DBI->connect($dsn, $mysql{'USER'}, $mysql{'PWD'}, \%attr)))
        {
             print ("$0: [ERROR] Couldn't connect to DB\n\n");
             exit;
        }

       my $query = sprintf("select count(1) AS TOTAL from DYNAMIC_HTTP_IN_history where sourceip='%s'",$ip);
       my $sth = $dbh->prepare($query);
       my $count = $sth->execute();

       my $ref   = $sth->fetchrow_hashref();
       $entry = $ref->{'TOTAL'};

       $sth->finish();
       $dbh->disconnect;
       return ($entry);
}

sub return_country {

        my ($myip) = shift;

        #my $gi = Geo::IP->open('/usr/share/GeoIP/GeoLiteCity.dat', GEOIP_STANDARD);
        my $gi = Geo::IP->open('/usr/share/GeoIP/GeoLiteCity.dat', GEOIP_MEMORY_CACHE);

        my $r = $gi->record_by_name($myip);
        my $country = '';

        if ($r) {
            $country = $r->country_code;
        } else {
            $country = "UNK";
        }

        return ($country);

}

sub getGraylogBadGuys () {

        my ($myhits,$mytime) = @_;

        #$myhits = $msettings{'graylog_min_hits'};
        #$mytime = $msettings{'graylog_time'};

        my $curl = WWW::Curl::Easy->new();
        if( $curl ){

                my $remote_page = sprintf ("https://%s/%s?time=%s&hits=%s",$msettings{'graylog_web'},$msettings{'graylog_url'},$mytime,$myhits);
                
                $curl->setopt(CURLOPT_URL, $remote_page);           # Set URL

                my $response_body;                                  # This is used to print on screen
                open(my $fh, '>', \$response_body);                 # This is used to print on screen
                $curl->setopt(CURLOPT_WRITEDATA, $fh);
                $curl->setopt(CURLOPT_VERBOSE, 0);                  # Disable verbosity
                $curl->setopt(CURLOPT_HEADER, 0);                   # Don't include header in body
                $curl->setopt(CURLOPT_NOPROGRESS, 1);               # Disable internal progress meter
                $curl->setopt(CURLOPT_FOLLOWLOCATION, 0);           # Disable automatic location redirects
                $curl->setopt(CURLOPT_FAILONERROR, 0);              # Setting this to true fails on HTTP error
                $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);           # Ignore bad SSL
                $curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);           # Ignore bad SSL
                $curl->setopt(CURLOPT_NOSIGNAL, 1);                 # To make thread safe, disable signals
                $curl->setopt(CURLOPT_ENCODING, '');                # Allow all ecodings
                $curl->setopt(CURLOPT_USERAGENT, 'Mozilla');        # User Agent
                $curl->setopt(CURLOPT_CUSTOMREQUEST,'GET');         # Method: GET
                $curl->setopt(CURLOPT_CONNECTTIMEOUT,'30');         # Timeout for url request
                #$curl->setopt(CURLOPT_HTTPAUTH,CURLAUTH_ANY);      # Auth type
                #$curl->setopt(CURLOPT_USERPWD,"logplayback:hvSbKwCseuFTkL");

                my $retcode = $curl->perform();                     # Connect to URL

                if ($retcode != 0) {
                        #warn "An error happened: ", $curl->strerror($retcode), " ( +$retcode)\n";
                        #warn "errbuf: ", $curl->errbuf;
                        die ("www::curl::Easy returned error\n");
                }

                $curl->curl_easy_cleanup;                           # Clean up after curl
                return ("$response_body");                          # Return page

        } else {
                die (" WWW::Curl::Easy->new() Unable to create curl object");
        }

}


# http://www.mikealeonetti.com/wiki/index.php?title=Check_if_an_IP_is_in_a_subnet_in_Perl
sub ip2long($)
{
        return( unpack( 'N', inet_aton(shift) ) );
}

# http://www.mikealeonetti.com/wiki/index.php?title=Check_if_an_IP_is_in_a_subnet_in_Perl
sub in_subnet($$)
{
        my $ip = shift;
        my $subnet = shift;

        my $ip_long = ip2long( $ip );

        if( $subnet=~m|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$| )
        {
                my $subnet = ip2long( $1 );
                my $mask = ip2long( $2 );

                if( ($ip_long & $mask)==$subnet )
                {
                        return( 1 );
                }
        }
        elsif( $subnet=~m|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d{1,2})$| )
        {
                my $subnet = ip2long( $1 );
                my $bits = $2;
                my $mask = -1<<(32-$bits);

                $subnet&= $mask;

                if( ($ip_long & $mask)==$subnet )
                {
                        return( 1 );
                }
        }
        elsif( $subnet=~m|(^\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})-(\d{1,3})$| )
        {
                my $start_ip = ip2long( $1.$2 );
                my $end_ip = ip2long( $1.$3 );

                if( $start_ip<=$ip_long and $end_ip>=$ip_long )
                {
                        return( 1 );
                }
        }
        elsif( $subnet=~m|^[\d\*]{1,3}\.[\d\*]{1,3}\.[\d\*]{1,3}\.[\d\*]{1,3}$| )
        {
                my $search_string = $subnet;

                $search_string=~s/\./\\\./g;
                $search_string=~s/\*/\.\*/g;

                if( $ip=~/^$search_string$/ )
                {
                        return( 1 );
                }
        }

        return( 0 );
}

#################################################################
####################### End   FUNCTIONS   #######################
#################################################################
