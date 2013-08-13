use strict;
use warnings;
use utf8;
use Nephia plugins => [qw/Lite/];

run {
    my $req = req;

    my $q = $req->param('q');

    return $q ?
        { message => 'hello', q => $q }
        : { message => 'hello' };
};
