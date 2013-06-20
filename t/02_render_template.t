use strict;
use warnings;
use utf8;

use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use JSON;
use Encode qw/encode_utf8/;
my $app = Plack::Util::load_psgi('t/nephia-test_app/page.psgi');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $title = encode_utf8 '河豚の部屋';

        subtest 'basic GET' => sub {
            my $res = $cb->(GET '/');
            is $res->code, 200;
            is $res->content_type, 'text/html';
            my $content = $res->content;
            like $content, qr!<title>$title</title>!;
        };

        subtest 'request GET' => sub {
            my $query = encode_utf8 'おれおれ';
            my $res = $cb->(GET "/?q=". $query );
            is $res->code, 200;
            is $res->content_type, 'text/html';
            my $content = $res->content;
            like $content, qr!<title>$title</title>!;
            like $content, qr!<p>query: $query</p>!;
        };
    };

done_testing;

