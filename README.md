bat
===

Bash Automation Tools

Automation tools written almost entirely in bash.

utils.sh
--------
The lib/utils.sh is the lowest-level library with full
documentation written in Perl POD. For convenience, I 
have included a copy of the html that can be generated
from this library with the pod2html command. You should
be able to preview the document here:

http://htmlpreview.github.io/?https://github.com/dgoade/bat/blob/master/doc/utils.html 

logger.sh
---------
A wrapper for Philip Patterson's log4bash utility. That adds
log file rotation and a very crude log message queueing 
functionality that I intend to convert to using Bash 4's
associatove arrays someday.


log4bash.sh
-----------
I've included a copy of log4bash unchanged. It is
Copyright (c) 2009, Philip Patterson

mail.pl
-------
A Perl script that uses the following dependencies to make
the task of sending an email with attachments easier:

test/
----
Yes, there are some tests, mostly for utils.sh. You will need
Kate Ward's shunit to run them: https://code.google.com/p/shunit2/

Mail-Sendmail-0.79
MIME-Lite-3.029
Email-Date-Format-1.002
