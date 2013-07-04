use strict;
use warnings;
use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use utf8;

use lib qw( ./t/nephia-test_app/lib );

my $app = Plack::Util::load_psgi('t/nephia-test_app/plugin.psgi');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        subtest "bark" => sub {
            my $res = $cb->(GET "/");
            is $res->code, 200;
            is $res->content, 'Bark!';
        };

        subtest "barkbark" => sub {
            my $res = $cb->(GET "/?barkbark=1");
            is $res->code, 200;
            is $res->content, 'Bark foo bar';
        };
    }
;

done_testing;
