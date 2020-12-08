package Pisg::Parser::Format::thelounge;

use strict;
$^W = 1;

sub new
{
    my ($type, %args) = @_;
    my $self = {
        cfg => $args{cfg},
        normalline => '^\[\d+-\d+-\d+T(\d+):\d+:\d+\.\d+Z\] <([^>\s]+)> (.*)',
        actionline => '^\[\d+-\d+-\d+T(\d+):\d+:\d+\.\d+Z\] \* (\S+) (.+)',
        thirdline  => '^\[\d+-\d+-\d+T(\d+):(\d+):\d+\.\d+Z\] \*{3} (.+)',
    };

    bless($self, $type);
    return $self;
}

sub normalline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{normalline}/o) {

        $hash{hour}   = $1;
        $hash{nick}   = $2;
        $hash{saying} = $3;

        $hash{nick} =~ s/[%@+~]//;

        return \%hash;
    } else {
        return;
    }
}

sub actionline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{actionline}/o) {

        $hash{hour}   = $1;
        $hash{nick}   = $2;
        $hash{saying} = $3;

        $hash{nick} =~ s/[%@+~]//;

        return \%hash;
    } else {
        return;
    }
}

sub thirdline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{thirdline}/o) {

        $hash{hour} = $1;
        $hash{min}  = $2;
        $hash{nick} = $3;

        # Format-specific stuff goes here.

        if ($3 =~ /^(\S+) was kicked by (\S+) \((.+)\)/) {
            $hash{nick} = $1;
            $hash{kicker} = $2;
            $hash{kicktext} = $3;

        } elsif ($3 =~ /^(\S+) changed topic to '(.+)'/) {
             $hash{nick} = $1;
             $hash{newtopic} = $2;

        } elsif ($3 =~ /^(\S+) sets channel \S+ mode (\S+) (.+)/) {
             $hash{nick} = $1;
             $hash{newmode} = $2;
             $hash{modechanges} = $3;

        } elsif ($3 =~ /^(\S+) \S+ joined/) {
            $hash{nick} = $1;
            $hash{newjoin} = $1;

        } elsif ($3 =~ /^(\S+) changed nick to (\S+)/) {
            $hash{nick} = $1;
            $hash{newnick} = $2;
        }

        return \%hash;

    } else {
        return;
    }
}

1;
