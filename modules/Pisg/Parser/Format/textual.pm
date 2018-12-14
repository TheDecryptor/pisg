package Pisg::Parser::Format::textual;

# Documentation for the Pisg::Parser::Format modules is found in Template.pm

# Based off the xchat parser

use strict;
$^W = 1;

sub new
{
    my ($type, %args) = @_;
    my $self = {
        cfg => $args{cfg},
        normalline => '\[\d{4}-\d{2}-\d{2}T(\d{2}):\d{2}:\d{2}\+\d{4}\] <[@%+~&]?([^|>]+)[\S|]*>\s+(.*)',
        actionline => '\[\d{4}-\d{2}-\d{2}T(\d{2}):\d{2}:\d{2}\+\d{4}\] • ([^|>]+)[\S|]*: (.*)',
        thirdline  => '\[\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):\d{2}\+\d{4}\] (\S+) (\S+) (\S+) ((\S+)\s*(\S+)?\s*(.*)?)',
    };

    bless($self, $type);
    return $self;
}

sub normalline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{normalline}/o) {

        $hash{hour} = $1;
        $hash{nick} = lc $2;
        $hash{saying} = $3;

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

        $hash{hour} = $1;
        $hash{nick} = lc $2;
        $hash{saying} = $3;

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
        $hash{min} = $2;
        $hash{nick} = lc $3;

        if (($4) eq 'kicked') {
            $hash{kicker} = $3;
            $hash{nick} = lc $5;

        } elsif (($4.$5) eq 'changedthe') {
            $hash{newtopic} = $9;

        } elsif (($4.$5) eq 'setsmode') {
            $hash{newmode} = $7;
            $hash{nick} = lc $8;

        } elsif (($5.$7) eq 'joinedthe') {
            $hash{newjoin} = $3;

        } elsif (($5.$7) eq 'nowknown') {
            $hash{newnick} = lc $9;

        } elsif (($3.$4) eq 'Topicisblah') {
            $self->{topictemp} = $5.' '.$6;
            $hash{newtopic} = $5.' '.$6;

        } elsif (($3.$4) eq 'Setbyblah') {
            $hash{nick} = lc $5;
            $hash{newtopic} =  $self->{topictemp};

        }

        return \%hash;

    } else {
        return;
    }
}

1;
