use strict;
use warnings;
use utf8;

use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use JSON;
use Encode qw/encode_utf8/;
my $app = Plack::Util::load_psgi('t/nephia-test_app/mainapp.psgi');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $title = encode_utf8 'トップページ';

        subtest 'basic GET' => sub {
            my $res = $cb->(GET '/');
            is $res->code, 200;
            is $res->content_type, 'text/html';
            my $content = $res->content;
            like $content, qr!<title>$title</title>!;
        };

        subtest 'json GET' => sub {
            my $query = 'おれおれ';
            my $res = $cb->(GET "/json?q=". encode_utf8($query) );
            is $res->code, 200;
            is $res->content_type, 'application/json';
            my $json = JSON->new->utf8->decode( $res->content );
            is $json->{message}, 'サブページのJSON';
            is $json->{q}, $query;
        };
    };

done_testing;

