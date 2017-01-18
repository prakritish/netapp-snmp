#!/usr/bin/perl
use Net::SNMP;
my $host = $ARGV[0];
my $aggergate;
my ($session, $error) = Net::SNMP->session(-hostname => $host, -community => "public", -version => "snmpv2c");
$session->max_msg_size(65535);
###Table "aggrTable" -> ".1.3.6.1.4.1.789.1.5.11"
my $aggrTableOID = ".1.3.6.1.4.1.789.1.5.11";
my $result = $session->get_table(-baseoid => $aggrTableOID);
my $aggrIndex = ".1.3.6.1.4.1.789.1.5.11.1.1";
my $aggrName = ".1.3.6.1.4.1.789.1.5.11.1.2";
my $aggrFlexvollist = ".1.3.6.1.4.1.789.1.5.11.1.9";
my $aggrCount = 1;
while ($result->{$aggrIndex . '.' . eval($aggrCount + 1)}) {$aggrCount++;};
print "+--------------------+--------------------------------------------------------------------------------+\n";
printf "|%-20s|%-80s|\n", "Aggregate Name", "Volume(s)";

for (my $i = 1; $i <= $aggrCount; $i++) {
    print "+--------------------+--------------------------------------------------------------------------------+\n";
	my $list = $result->{$aggrFlexvollist . '.' . $i};
	$list =~ s/^\s+//;
	my @volList = split(" ", $list);
	my $aggr = $result->{$aggrName . '.' . $i};
	$aggregate->{$aggr}->{'volumes'} = \@volList;
    if (length($result->{$aggrFlexvollist . '.' . $i}) > 80) {
        my $lineLength = 0;
        my $line = "";
        foreach my $vol (@volList) {
            my $volLength = length($vol);
            if (($lineLength + $volLength) > 80) {
                printf "|%-20s|%-80s|\n", $aggr, $line;
                $aggr = " ";
                $line = $vol;
                $lineLength = $volLength;
            } else {
                $line = $line . " " . $vol;
                $lineLength += $volLength + 1;
            }
        }
        printf "|%-20s|%-80s|\n", $aggr, $line;
    } else {
        printf "|%-20s|%-80s|\n", $aggr, $list;
    }
}
print "+--------------------+--------------------------------------------------------------------------------+\n";

print "\n\n\n";

###Table "dfTable" -> ".1.3.6.1.4.1.789.1.5.4"
my $dfTableOID = ".1.3.6.1.4.1.789.1.5.4";
$result = $session->get_table(-baseoid => $dfTableOID);
my $iCount = 0;
my $dfIndex = ".1.3.6.1.4.1.789.1.5.4.1.1";
my $dfFileSys = ".1.3.6.1.4.1.789.1.5.4.1.2";
my $dfHighTotalKBytes = ".1.3.6.1.4.1.789.1.5.4.1.14";
my $dfLowTotalKBytes = ".1.3.6.1.4.1.789.1.5.4.1.15";
my $dfHighUsedKBytes = ".1.3.6.1.4.1.789.1.5.4.1.16";
my $dfLowUsedKBytes = ".1.3.6.1.4.1.789.1.5.4.1.17";
my $dfHighAvailKBytes = ".1.3.6.1.4.1.789.1.5.4.1.18";
my $dfLowAvailKBytes = ".1.3.6.1.4.1.789.1.5.4.1.19";
while ($result->{$dfIndex . '.' . eval($iCount + 1)}) {$iCount++;};
print "+--------------------------------------------------+---------------+---------------+---------------+\n";
printf "|%-50s|%15s|%15s|%15s|\n","Aggregate/Volume", "Total Space", "Used Space", "Available Space";
for (my $i = 1; $i <= $iCount; $i++) {
    print "+--------------------------------------------------+---------------+---------------+---------------+\n";
    my $total = convert($result->{$dfHighTotalKBytes . '.' . $i}, $result->{$dfLowTotalKBytes . '.' . $i}, $result->{$dfFileSys . '.' . $i}, $aggregate);
    my $used = convert($result->{$dfHighUsedKBytes . '.' . $i}, $result->{$dfLowUsedKBytes . '.' . $i}, $result->{$dfFileSys . '.' . $i}, $aggregate);
    my $available = convert($result->{$dfHighAvailKBytes . '.' . $i}, $result->{$dfLowAvailKBytes . '.' . $i}, $result->{$dfFileSys . '.' . $i}, $aggregate);
    printf "|%-50s|%15s|%15s|%15s|\n", $result->{$dfFileSys . '.' . $i}, $total, $used, $available;
}
print "+--------------------------------------------------+---------------+---------------+---------------+\n";
exit;

sub convert {
    my $high = shift;
    my $low = shift;
    my $name = shift;
    my $aggregate = shift;
    my $value;
    my $conv = 4294967296;
    if ($low < 0) {
        $low = $conv + $low;
    }
    my $kb = $low + $high * $conv;
    my $mb = $kb / 1024;
    my $gb = $mb / 1024;
    my $tb = $gb / 1024;
    if ($mb < 1) {
        $value = sprintf("%.2f KB", $kb);
    } elsif ($gb < 1) {
        $value = sprintf("%.2f MB", $mb);
    } elsif ($tb < 1) {
        $value = sprintf("%.2f GB", $gb);
    } else {
        $value = sprintf("%.2f TB", $tb);
    }
    return $value;
}
