package SubApp;
use strict;
use warnings;
use utf8;
use Nephia::Lite;

#run {
#    my $q = req->param('q');
#    return { message => 'サブページのJSON', q => $q };
#};
path '/' => sub { +{ aaa => 'aaaaa' } };
