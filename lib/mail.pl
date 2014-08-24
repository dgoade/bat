#!/usr/bin/perl

# To load the required modules from a portable, local libarary 
BEGIN 
{
    use FindBin;
    use lib "$FindBin::Bin/Mail-Sendmail-0.79/blib/lib";
    use lib "$FindBin::Bin/MIME-Lite-3.029/blib/lib";
    use lib "$FindBin::Bin/Email-Date-Format-1.002/lib";
}

use strict;

use Mail::Sendmail;
use MIME::Lite;
use Getopt::Long;

our $Result;
our $From;
our $To;
our $Cc;
our $Subject;
our $Body;
our $Footer;
our @Attach;
our $LogPriority="debug";
our $LogFile="-";
our $Validated="true";

$Result = GetOptions
(
    "from=s" => \$From,
    "to=s" => \$To,
    "cc=s" => \$Cc,
    "subject=s" => \$Subject,
    "Body=s" => \$Body,
    "Footer=s" => \$Footer,
    "Attachments=s" => \@Attach,
    "verbose=s" => \$LogPriority
);


logit("debug", "\$From=$From");
logit("debug", "\$To=$To");
logit("debug", "\$Cc=$Cc");
logit("debug", "\$Subject=$Subject");
logit("debug", "\$Body=$Body");
logit("debug", "\$Footer=$Footer");
logit("debug", "\@Attach=@Attach");

if( ! $From )
{
    logit("error", "From is required.");
    $Validated="";
}

if( ! ($To || $Cc) )
{
    logit("error", "Either To  or CC is required.");
    $Validated="";
}

if( ! $Subject )
{
    logit("error", "Subject is required.");
    $Validated="";
}

if( ! $Body )
{
    logit("error", "Body is required.");
    $Validated="";
}

if( ! $Footer )
{
#    logit("error", "Body is required.");
#    $Validated="";
}

@Attach = split(/ /,join(' ',@Attach));

if( $Validated )
{
    &sendEmailWithAttachments;
}

sub sendEmailWithAttachments
{ 

    my $thisAttachment;
    my $basename;
    my $messageFH;
    my $logMsg;
    my @BodyArray;

    my $msg = MIME::Lite->new( 
        From => "$From", 
        To => "$To", 
        Cc => "$Cc", 
        Subject => "$Subject", 
        Type => "multipart/mixed", 
    ); 

    if ( -f $Body )
    {
        logit("debug", "message file exists: $Body"); 

        if( $Footer )
        {
            if ( open($messageFH, ">>", $Body) )
            {
                print $messageFH "\n\n$Footer"; 
                close $messageFH;
            }
            else
            {
                logit("error", "Failed to open $Body due to $!"); 
            }
        }

        $msg->attach(
            Type => 'TEXT', Path => "$Body",
        ); 

    }
    else
    {
        $logMsg="No message file exists.";
        $logMsg=$logMsg . " Using Body parameter as body text";
        logit("debug", "$logMsg"); 

        $msg->attach(
            Type => 'TEXT', Data => "$Body\n\n$Footer",
        ); 
    }

    for $thisAttachment ( @Attach ) 
    { 
        if ( -f $thisAttachment )
        {
            if( $thisAttachment =~ m|([^/]*)$| )
            {
              $basename=$1;
            }
            else
            {
              $basename=$thisAttachment;
            }
            logit("debug", "file exists: $thisAttachment"); 
            logit("debug", "basename: $basename"); 
            $msg->attach(
                Type     => 'TEXT',
                Path     => "$thisAttachment",
                Filename => "$basename",
            );
        }
        else
        {
            logit("error", "file does not exist: $thisAttachment"); 
        }
    } 

    $msg->send;

}

sub sendEmail()
{

    sendmail( 
        From => "admin@localhost.com", 
        To => "recipient@localhost.com", 
        Subject => "some subject", 
        Message => "body of the message", 
    );
}

sub logit
{

	my $prioritySetting=$LogPriority;
	my $filename="$LogFile";
	my $msgPriority;
	my $logMsg;
	my $printTheLogMsg=0;
	my $mode='>>';
	my $pipe;
	my $fh;
	my $subLogger;

	if ( @_ < 5 )
	{
	    $subLogger=(caller(1))[3];
	    $subLogger =~ s/::/\./;
	}

	SWITCH:
	{
	    @_ == 5 && do
		{
		    $subLogger=$_[0];
		    $msgPriority=$_[1];
		    $logMsg=$_[2];
		    $prioritySetting=$_[3];
		    $filename=$_[5];
		    last SWITCH;
		};
	    @_ == 4 && do
		{
		    $subLogger=$_[0];
		    $msgPriority=$_[1];
		    $logMsg=$_[2];
		    $prioritySetting=$_[3];
		    last SWITCH;
		};
	    @_ == 3 && do
		{
		    $subLogger=$_[0];
		    $msgPriority=$_[1];
		    $logMsg=$_[2];
		    last SWITCH;
		};
	    @_ == 2 && do
		{
		    $msgPriority=$_[0];
		    $logMsg=$_[1];
		    last SWITCH;
		};
	    @_ == 1 && do

		{
		    $msgPriority="debug";
		    $logMsg=$_[0];
		    last SWITCH;
		};

	    DEFAULT:
		    $msgPriority="debug";
		    $logMsg="no log message passed";
		    last SWITCH;
	};

	if ( $subLogger =~ /^$/ )
	{
		$subLogger = "main";
	}


	$printTheLogMsg = &miniLogitOrNot($prioritySetting, $msgPriority);

	if ( $printTheLogMsg )
	{
	    no strict 'refs';

		if ( $filename )
	    {
			$fh = $filename;
			open($filename,$mode.$filename.$pipe); #unless $Opened{$name}++;
			if ( $fh )
			{
				print $fh uc ($msgPriority) . ' - ' . $subLogger . ' - ' . $logMsg . "\n";
				close $fh;
			}
	    }
	    else
	    {
	    }
	    use strict 'refs';
	}

}

sub miniLogitOrNot
{

	my $prioritySetting;
	my $msgPriority;
	my $rval=0;

	if ( @_ == 2 )
	{
		$prioritySetting=$_[0];
		$msgPriority=$_[1];

		if ($prioritySetting =~ /debug/i )
		{
			$rval = 1;
		}
		elsif ($msgPriority =~ /info/i )
		{
			if ($prioritySetting =~ /debug|info/i )
			{
				$rval = 1;
			}
		}
		elsif ($msgPriority =~ /warn/i )
		{
			if ($prioritySetting eq /debug|info|warn/i )
			{
				$rval = 1;
			}
		}
		elsif ($msgPriority =~ /error/i)
		{
		if ($prioritySetting =~ /debug|info|warn|error/i )
			{
				$rval = 1;
			}
		}
		elsif ($msgPriority =~ /fatal/i )
		{
            if ($prioritySetting =~ /debug|info|warn|error|fatal/i )
            {
                $rval = 1;
            }
		}
		elsif ($msgPriority =~ /critical/i )
		{
			$rval = 1;
        } 
	}

	return $rval;

}
