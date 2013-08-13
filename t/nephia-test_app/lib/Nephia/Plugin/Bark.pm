package Nephia::Plugin::Bark;
use strict;
use warnings;

our @EXPORT = qw/bark barkbark/;

sub bark () {
    return [200, [], ['Bark!']];
}

sub barkbark (@) {
    return [200, [], [join(' ', 'Bark', @_)]];
}

1;

