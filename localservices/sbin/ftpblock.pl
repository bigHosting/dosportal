#!/usr/bin/perl

# (c) Security Guy  2015.04.17

$| = 1;

use strict;
use warnings;

use POSIX qw(strftime);      # time options
use DBI;                     # sql part
use Socket qw( inet_aton );  # ip methods
use IO::Socket;              # socket to communicate w remote server
use Term::ANSIColor;         # colored output
use Sys::Hostname;
use File::Basename;          # for basename


BEGIN {
    use constant VERSION    => "0.2.14";
    use constant RELDATE    => "2015.03.27";
    use constant BY         => "Security Team";
}


sub ip2long($);
sub in_subnet($$);

sub iniRead;

sub find_recent_log_files;
sub whitelist;
sub tempwhitelist;
sub mysql_insert;
sub auth_thresholds;
sub get_history_thresholds;
sub get_history_count;
sub return_country;
sub log_bad_ip;

# sort hash by IP http://www.perlmonks.org/?node_id=129566
sub ipsort {
  my @a = split /\./, $a;
  my @b = split /\./, $b;

  return $a[0] <=> $b[0]
      || $a[1] <=> $b[1]
      || $a[2] <=> $b[2]
      || $a[3] <=> $b[3];
}

# calculate closest number # http://www.perlmonks.org/?node_id=884064
sub nearest{
    my ( $dist, $href ) = @_;
    my ( $answer ) = ( sort { abs( $a - $dist ) <=> abs( $b - $dist ) } keys %$href );
    return $href -> { $answer };
}

# sleep a bit so multiple server don't run in the same time
sub delayme {
    my $minimum = 5;
    my $range = 20;
    my $sleeptime = int(rand($range)) + $minimum;
    print color("yellow"), "[*] $0: delayme => sleeping rand time: $sleeptime seconds\n", color("reset");
    sleep($sleeptime);
}


# mysql settings
my %attr = (
        PrintError                  => 1,
        RaiseError                  => 1,
        PrintWarn                   => 0
);

# thresholds for last 2 hours
my %thresholds = (
        failed_per_ip               =>  '150',
        success_max_domains_per_ip  =>  '14'
);

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
        'graylog_sec_port'     => $inifile->{'graylog'}->{'sec_port'},
        'graylog_sec_service'  => $inifile->{'graylog'}->{'sec_service'},
        'graylog_log_to'       => $inifile->{'graylog'}->{'log_to'},
        'graylog_sec_bl_w'     => $inifile->{'graylog'}->{'sec_bl_w'},
        'graylog_comment'      => $inifile->{'graylog'}->{'comment'},
        'graylog_insert_by'    => $inifile->{'graylog'}->{'insert_by'}
);

$msettings{'msg_from'} = hostname;


# don't hammer mysql database from multiple servers, add random sleep time
&delayme;

my (%failed,%success) = ();
# path to ProFTPD log files
#my @files = </common/storage/web*>;

# c28 ftp server names start w ftp. Rest of the clusters using web
my @files = find_recent_log_files ("1","/common/storage/","web");


# get an list of whitelisted networks and store them in an array
my @whitelist = &whitelist();
my @tempwhitelist = &tempwhitelist();

my %dist = &auth_thresholds();                            # get a list of settings stored in mysql
my %history_thresholds = &get_history_thresholds ();      # get a list of settings stored in mysql


# time stuff
my @t1 = localtime(time);              # current time
my @t2 = localtime(time - (3600 * 1)); # go back in time 1 hour
my $time_now  = strftime "%j:%H",@t1;  # dayOfYear:hour
my $time_back = strftime "%j:%H",@t2;  # yesterday_dayOfYear:hour

my $time_hr   = strftime "%H",@t1;     # current hour of the day
my $time_hr2  = strftime "%H",@t2;     # previous hour
my $time_day  = strftime "%j",@t1;     # day of the year

my $db_string = "FTP";

# parse all files
foreach my $files(@files){
        if (open(FILE,$files)){

                print color("yellow"), "[*] $0: parsing log file => $files\n", color("reset");
                # Logs for Brute Force countermeasures
                # $ ln -s /common/storage/`hostname -s` /var/log/proftpd.auth
                # $ vim /etc/proftpd.conf
                #      ---> # Logs for Brute Force countermeasures
                #      ---> LogFormat securityftp "%a %U %m %s %{%j:%H}t"
                #      ---> ExtendedLog /var/log/proftpd.auth auth securityftp

                # FAILED Log sample:
                # 117.227.234.1 admin@ABC.com PASS 530 037:13

                # SUCCESS Log sample:
                # 69.112.171.200 netcam.XYZ.com PASS 230 042:23


                while(my $line=<FILE>)
                {
                        chomp($line);

                        # skip line if there is no IPv4
                        next if ($line !~ m/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/o);

                        # split line by spaces and assign to vars
                        my ( $ip,$user,$command,$code,$log_date ) = split(/\s+/,$line);

                        # split log_date by ':' into day:hour
                        my ($log_day,$log_hour) = split(/:/,$log_date);

                        # IPv4 only, take a look at current day:hour && day:back1hour. Max we can do is current hour + 1 hour back
                        if ( ($ip =~ m/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/o) && ( ($log_date =~ $time_now) || ($log_date =~ $time_back ) ) )
                        {
                                # don't block ourselves
                                next if $ip =~ /0\.0\.0\.0/;

                                $failed{$ip}{$user}++  if ($code =~ /530/o);
                                $success{$ip}{$user}++ if ($code =~ /230/o);
                        }
            }
            close(FILE);
        } else { print "Notice: can't open `$files`.\n"; }
}



###########################
# proccess FAILED entries #
###########################
if (scalar(keys(%failed)) > 0) {

        foreach my $ip (sort ipsort keys %failed) {

                 my ($found,$counter_failed) = '0';

                 # check if IP is in our whitelist
                 if (scalar(@whitelist) > 0)
                 {
                         foreach my $subnet (@whitelist) {
                                if(in_subnet($ip, $subnet )){
                                        $found = '1';
                                        last; # replaced next with last
                                }
                         }
                 }

                 # check if the IP is whitelisted
                 if (scalar(@tempwhitelist) > 0)
                 {
                         if ( grep { $_ eq $ip} @tempwhitelist ) {
                                 $found = '1';
                         }
                 }

                 if ($found == '0') {

                        # FAILED AUTH. Need to go through all domains.
                        foreach my $dom (sort keys %{$failed{$ip}}) {
                                #print "$ip, $dom: $failed{$ip}{$dom}\n"; #if ($failed{$ip}{$dom} > 5);
                                $counter_failed += $failed{$ip}{$dom};
                        }

                        # if number of  failed logins > threshold then take action
                        if ( $counter_failed > $thresholds{'failed_per_ip'} )
                        {


                                 my $n = &get_history_count($ip);

                                 # set to a random number, this get overwritten below
                                 my $block_seconds = '3600';

                                 my $geoip_country = &return_country ($ip);

                                 if ($n > 0 ) {
                                         # is IP repeated offender ?
                                         $block_seconds = nearest( $counter_failed, \%history_thresholds );
                                 } else {
                                         # is IP temp offender ?
                                         $block_seconds = nearest( $counter_failed, \%dist );
                                 }

                                 print "IP:$ip,FAILED_HITS:$counter_failed,HISTORY:$n,Country:$geoip_country\n";

                                 # first we need to insert the IP into the DB
                                 &mysql_insert($ip,$counter_failed,$block_seconds,$n,$geoip_country);

                                 # next we log the block into separate graylog server
                                 &log_bad_ip ($ip,$db_string,$counter_failed,$block_seconds,$n,$geoip_country);

                        }

                 }
        }
}

###############################
# proccess SUCCESSFUL entries #
###############################
if (scalar(keys(%success)) > 0) {
        foreach my $ip (sort ipsort keys %success) {

                 my ($found,$counter_success) = '0';

                 # check if IP is in our whitelist
                 if (scalar(@whitelist) > 0)
                 {
                         foreach my $subnet (@whitelist) {
                                if(in_subnet($ip, $subnet )){
                                        $found = '1';
                                        last; # replaced next with last
                                }
                         }
                 }

                 # check if the IP is whitelisted
                 if (scalar(@tempwhitelist) > 0)
                 {
                         if ( grep { $_ eq $ip} @tempwhitelist ) {
                                 $found = '1';
                         }
                 }

                 if ($found == '0') {

                        # SUCCESSFUL AUTH
                        $counter_success = grep {defined} keys %{$success{$ip}};
                        # my $counter_success = scalar(keys $success{$ip});

                        # if number of  failed logins > threshold then take action
                        if ( $counter_success > $thresholds{'success_max_domains_per_ip'} )
                        {

                                 my $n = &get_history_count($ip);

                                 # set to a random number, this get overwritten below
                                 my $block_seconds = '3600';

                                 my $geoip_country = &return_country ($ip);

                                 if ($n > 0 ) {
                                         # is IP repeated offender ?
                                         $block_seconds = nearest( $counter_success, \%history_thresholds );
                                 } else {
                                         # is IP temp offender ?
                                         $block_seconds = nearest( $counter_success, \%dist );
                                 }

                                 print "IP:$ip,FAILED_HITS:$counter_success,HISTORY:$n,Country:$geoip_country\n";

                                 # first we need to insert the IP into the DB
                                 &mysql_insert($ip,$counter_success,$block_seconds,$n,$geoip_country);

                                 # next we log the block into separate graylog server
                                 &log_bad_ip ($ip,$db_string,$counter_success,$block_seconds,$n,$geoip_country);


                        }


                 }
        }

}


##############################################################
##############################################################
##############################################################
#####  YOU SHOULD NOT BE CONCERNED PASSED THIS POINT !!  #####
##############################################################
##############################################################
##############################################################

# find files matching pattern non-recursively
sub find_recent_log_files() {
        my ($maxdays,$folder,$match) = @_;

        # temp array to hold file names
        my (@temp) = ();

        if (! -d $folder) {
                die ("[$0]: folder $folder does not exist: $!");
        }

        opendir (DIR, $folder);
        my @dir = grep { /^$match/ } readdir(DIR);
        closedir(DIR);

        # sort by modification time
        @dir = sort { -M "$folder/$a" <=> -M "$folder/$b" } (@dir);

        # do we have at least one item in array ?
        if (scalar(@dir) >0 ) {
                foreach my $file (@dir) {
                        my $full_path = "$folder/$file";
                        # we only care about regular files ignoring folders
                        next if (!(-f "$full_path"));

                        # ignore files ending in tmp
                        next if ($file =~ /tmp$/ );

                        # return time diff
                        #my $diff = -M "$full_path";

                        my $age = int( -M "$full_path" ) < int( -C "$full_path") ? int( -M "$full_path") : int( -C "$full_path");
                        #if ( $diff <= $maxdays ) {
                        if ( $age <= $maxdays ) {

                                # add to temp array
                                push (@temp,$full_path);

                        }
                }
        }
        return (@temp);
}

sub whitelist {
        print color("yellow"), "[*] $0: mysql => getting settings from whitelist (our_networks) [*]\n", color("reset");
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
        print color("yellow"), "[*] $0: mysql => getting settings from tempwhitelist (DYNAMIC_HTTP_IN_temp_whitelist) [*]\n", color("reset");
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
                   $badip,$msettings{"graylog_cidr"},$expiretime,$msettings{"graylog_insert_by"},$num,$msettings{"graylog_comment"}, $country );
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

        # not all servers have Geo::IP module loaded, return unknown
        #my $gi = Geo::IP->open('/usr/share/GeoIP/GeoLiteCity.dat', GEOIP_STANDARD);
        #my $gi = Geo::IP->open('/usr/share/GeoIP/GeoLiteCity.dat', GEOIP_MEMORY_CACHE);

        #my $r = $gi->record_by_name($myip);
        my $country = '';

        #if ($r) {
        #    $country = $r->country_code;
        #} else {
            $country = "UNK";
        #}

        return ($country);

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



