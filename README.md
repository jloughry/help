Help
====

I'll just leave this here in case it might help somebody else some day.  Some of these items
are copied from my old development blog I started on the **Radiant Mercury** program at
Lockheed Martin.

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

That's it.

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

As a bonus, your user will be pleased to discover that publishing in Composer is almost
instantaneous now.

Always specify the encoding!
----------------------------

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

Piping and redirecting `stderr` in `csh`
----------------------------------------

To pipe `stderr` along with `stdout`, do:

	% cmd1 |& cmd2

To redirect `stderr` by itself to file `f1` and `stdout` to file `f2`, do:

	% (cmd > f1) >& f2,

Source: Daniel Gilley. *UNIX in a Nutshell* second edition.  Sebastopol, California:
O'Reilly & Associates, 1994.

Concatenating PDF files
-----------------------

If you have Ghostscript installed, do this:

	% set path=d:\work_in_progress\tools\gs\gs7.04\lib;d:\work_in_\
	progress\tools\gs\gs7.04\bin;%PATH%
	% gswin32.exe -sPAPERSIZE=letter -dNOPAUSE -dBATCH \
	-sDEVICE=pdfwrite -sOutputFile=result.pdf file1.pdf [file2.pdf...]

Useful UNIX commands
--------------------

`pfiles` *pid* will give a list of file descriptors currently open by process ID *pid*.

Choose the file descriptor you want and look for the `ino:` *nnnnn* field.  That is the
inode of the file.  To get the name of the file, do `% find . -inum` *nnnnn*, or
`% ls -i | grep` *nnnnn* `/usr/proc/bin/pfiles`

GitHub error `Commit failed: Failed to create a new commit.`
------------------------------------------------------------

This error from GitHub for Windows is caused by low disk space on the local volume containing the
repository.  Less than 4.9 gigabytes free: the error occurs.  Freeing up some space makes the
problem go away.

