# dosportal tools and utilities
Database container for brute-force countermeasures in LARGE environments.

We will build a database for blocking 'bad' IPs from multiple sources:

1. proftpd authentication logs to common storage
2. F5 ASM logs sent remotely to graylog2 and elasticsearch
3. several hundred Apache logs sent to a separate graylog2 farm


Requirements:
* Linux servers with Apache and PHP. PHP to be used for API access to graylog
* proftpd authentincation logs
* F5 ASM configured and sending logs to graylog using GELF format
* mail authentication logs, patched sendmail/pop3/imap/pop3s/imaps daemons to send GELF formatted logs
* graylog2 + mongodb + elasticsearch cluster backend


More information

FTP:
* each FTP server will write to a common location
* every 5 minutes the management node runs a cron job every 5 mintes that will:
  - grab last 2 hours from logs
  - create a list of:
       IPs -> domains -> number of faile_logins
       IPs -> domains -> number of successful_logins
  - if number of successful auth from 1 IP exceeds threshold for max number of domains, add IP to DB
  - if number of failed auth from 1 IP exceeds threshold for max number of failed logins, add IP to DB

* on each ftp server symlink: ln -s /common/storage/`hostname -s` /var/log/proftpd.auth
* run ftpblock to read contents of /common/storage and inject 'bad' IPs into dosportal database  
      # FAILED Log sample:
      # 117.227.234.1 admin@ABC.com PASS 530 037:13

      # SUCCESS Log sample:
      # 69.112.171.200 netcam.XYZ.com PASS 230 042:23



ASM:
* confire Enterprise Manager to deploy the following ASM logging profile:

    Profile Name: ASM_REMOTE_PROFILE
    Application Security: Enabled
    Local Storage: Enabled
    Remote Storage: Enabled
    Remote Storage Type: Remote
    Protocol: UDP
    Server Address: 1.1.1.1:12201
    Storage Format: User-Defined

    F5_ASM|%attack_type%|%dest_ip%|%dest_port%|%geo_location%|%ip_address_intelligence%|%ip_client%|%method%|%protocol%|%response_code%|%severity%|%src_port%|%violations%|%sub_violations%|%policy_name%|%support_id%|%uri%|<<%headers%>>


How to Block:
* use iptables or ipset
* use some kind of RBL but all daemons must have support for it
* use BGP to adversize 'bad' routes

