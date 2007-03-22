#!/data/bin/perl

use POSIX;

register_monitor('BETAUTO', sub {
  my $arg = shift;
  my $os = fresh_status($arg);
  return $os if $os;
  my $file1 = '/data/logs/subscription/insert_bets.log';

  my $thistime = time()-int(86400*(16.5/24));
  my $error;
  my $datematcher = POSIX::strftime("%b %d", localtime($thistime));
  $datematcher =~ s/ 0/  /g;
  $datematcher .= ' \d\d:\d\d:\d\d ';
  $datematcher .= POSIX::strftime("%Y", localtime($thistime));

  open(TF, "tail -5 $file1|");
  my $state = 0;
  while(<TF>) {
    chomp;
    unless(/$datematcher/) {
      $error = $_;
    }
    ($state==0) && /Start insert bets/ && ($state = 1);
    ($state==1) && /sublotto/ && ($state = 2);
    ($state==2) && /fwlotto/ && ($state = 3);
    ($state==3) && /flezwin/ && ($state = 4);
    ($state==4) && /Finish insert bets/ && ($state = 5);
  }
  close(TF);
  if($state != 5 || $error) {
    return set_status($arg, "BAD($error)");
  }
  return set_status($arg, "OK(log line expected)");
});

1;