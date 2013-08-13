use strict;
use warnings;
use utf8;

use Test::More;
use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use JSON;
use Encode qw/encode_utf8/;
my $app = Plack::Util::load_psgi('t/nephia-test_app/xslate.psgi');

BEGIN {
    unless (eval 'use Text::Xslate; 1;') {
        plan skip_all => 'Text::Xslate are required to run this test';
    }
};

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $title = encode_utf8 'ここはトップページです';

        subtest 'basic GET' => sub {
            my $res = $cb->(GET '/');
            is $res->code, 200;
            is $res->content_type, 'text/html';
            my $content = $res->content;
            like $content, qr!<title>$title</title>!;
            like $content, qr!<li>5</li>!;
        };
    };

done_testing;

