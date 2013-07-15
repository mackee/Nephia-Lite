package Nephia::Plugin::Lite::Xslate;
use 5.008005;
use strict;
use warnings;
use utf8;

use Carp;
use Nephia::DSLModifier;
use Text::Xslate;
use Encode qw/decode_utf8/;

around 'build_template' => sub {
    if (my $data = shift) {
        my $tx = Text::Xslate->new();

        my $f = sub {
            my $res = shift;
            $tx->render_string($data, $res);
        };

        return $f;
    }

    croak "could not find template content in __DATA__ section";
};

1;

