use strict;
use LWP::Simple;
use Getopt::Long;

my $opt_link;
my $opt_projId;
GetOptions(
	"link=s"  => \$opt_link,
	"id=s"    => \$opt_projId
);
#$opt_projId = 4;
#$opt_link = '\\\\10.38.38.166\\autobuild\\android\\dkbtd\\2010-03-04_dkbtd-eclair';

open BUILDLOG, ">>", "tcms_build.log";
my $ts = scalar(localtime(time));

if ( !$opt_link ) {
	print BUILDLOG "TimeStamp: $ts, submit info link is empty!\n";
	close BUILDLOG;
	exit;
}

my $httpBase = 'http://tcms:8080/TestManager/opBuildInfo.do?method=save';

for (my $i=0; $i<2; $i++) {
	my $id = $i + 3;
	my $url = $httpBase."&testProjectId=$id&link=$opt_link\\droid-gcc";
	my $content = get($url);
	die "Couldn't get $url" unless defined $content;
	
	#print $content;
	if($content =~ m/build info is inserted\/updated successfully/i) {
		print "Submit Build info of project $id to TCMS successfully!\n";
	} else {
		print "Submit Build info to TCMS with Error!\n";
		print BUILDLOG "TimeStamp: $ts, submit info 'link=$opt_link' with error!\n";
		print BUILDLOG $content."\n";
	}	
}

close BUILDLOG;