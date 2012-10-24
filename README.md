Help
====

I'll just leave this here in case it helps somebody else some day.

Workaround for lack of SFTP support in Sea Monkey Composer:
-----------------------------------------------------------

If your web server host allows only SFTP (a good idea for security), you'll find that Composer
doesn't support SFTP.  For reasons of tool familiarity and process, I did not want to impose a
change of HTML editor on the maintainer of a certain web site, so I came up with the following
workaround for users who prefer to use the Composer HTML editor and didn't want to learn a new one:

1. Start a local FTP server on the user's machine.  In this case it was Mac OS X 10.5; setting up
an FTP server was as simple as turning on File Sharing in the Sharing section of System
Preferences, checking the firewall settings to make sure the FTP server was visible only to the
local machine, and editing `/etc/ftpchroot` to contain a single asterisk character for
security.

2. Create a directory in the user's home directory called `~/proxy_for_website/`

3. Inside that directory, mimic the directory structure that exists already at the web hosting
company, e.g., `~/public_html` and `~/secure_html` and all subdirectories that might exist
below them.

4. Inside Sea Monkey Composer, change the *Publish As...* settings as follows:

 - Publishing address: `ftp//name_of_user's_machine.local/proxy_for_website/public_html/`

 - User name: the user's username on the local machine.

 - Password: the user's password on the local machine.

5. Now set up an SSH public key pair on the user's local machine and on the web hosting company's
server in the usual way so that SSH can be done without a password (hint: use `ssh-agent` to do
it securely).  This will ensure that `rsync` can run automatically.

6. Set up a cron job on the user's machine to run the following script once every minute:

	#!/bin/sh

	#
	# This script watches for any change in the $target directory, and if it
	# sees a change, copies whatever changed to the user's public_html directory
	# at Hurricane Electric.  Run this script once a minute from crontab.

	start_time=`date +%s`

	old_detectfile=/Users/username/detect_mozilla_upload_content.new

	new_detectfile=/Users/username/detect_mozilla_upload_content.old

	reportfile=/Users/username/detect_mozilla_upload_report

	target=/Users/username/proxy_for_website/public_html/

	rm -f $reportfile; touch $reportfile

	cd $target
	find . -type f -ls > $new_detectfile
	diff -q $new_detectfile $old_detectfile

	RC=$?
	if [ $RC -eq 0 ]; then
			echo "nothing to do at `date`" >> $reportfile
	else
			echo "\nchange in the proxy directory detected (diff rc was $RC) ; running rsync now\n" \
				>> $reportfile

			rsync -avz . username@he.net:public_html >> $reportfile
			RC=$?
			echo "\nRC from rsync was $RC" >> $reportfile

			mv $new_detectfile $old_detectfile

			end_time=`date +%s`
			elapsed_time=$(($end_time - $start_time))

			echo "\nElapsed time $elapsed_time seconds." >> $reportfile
	fi

As a bonus, your user will be pleased to discover that publishing in Composer is much faster now.

Always specify encoding!
------------------------

Always specify the encoding!  When writing HTML (especially auto-generated HTML) you should
always include the Unicode encoding informating in your header, like this:

	<html>
	   <head>
		  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		  <title>
			 ...
		  <title>
	   </head>
	</html>

The `<meta>` tag containing `"Content-Type"` information must be the very first element
in the `<head>` block, because that's where HTML-aware applications go looking for it.

If you don't do this in your HTML, someday it will come back and bite you.


