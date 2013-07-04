use strict;
use warnings;
use utf8;
use Nephia::Lite plugins => [qw/Bark/];

run {
    if (req->param('barkbark')) {
        barkbark qw/foo bar/;
    }
    else {
        bark;
    }
};

