package Nephia::Plugin::Bark;
use strict;
use warnings;

sub import {
    $Nephia::BARK = 'FOO';
}

sub bark () {
    return [200, [], ['Bark!']];
}

sub barkbark (@) {
    return [200, [], [join(' ', 'Bark', @_)]];
}
  
1;

