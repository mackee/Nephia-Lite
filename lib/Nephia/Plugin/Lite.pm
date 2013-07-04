package Nephia::Plugin::Lite;
use strict;
use warnings;
use utf8;

use Nephia::DSLModifier;
use Carp qw/croak/;

around 'run' => sub {
    my $coderef = shift;
    my $origin = pop;
    my $caller = caller;
    
    my $renderer;
    {
        no strict 'refs';
        $renderer = ${$caller.'RENDERER'};
        if ( !$renderer ) {
             my $content = _read_section_data($caller);
            $renderer = ${$caller.'::RENDERER'} ||= _build($content) if $content;
        }
    }

    origin('path')->('/', sub {
        my $res = $coderef->(@_);

        if ($renderer) {
            my $charset = $res->{charset} || $Nephia::Core::CHARSET;
            $res = origin('res')->(sub {
                content_type( "text/html; charset=$charset" );
                my $body = encode( $charset, $renderer->($res) );
                body( $body );
            });
        }

        return $res;
    });

    my $app = $origin->($caller);

    return $app;
};

sub _read_section_data {
    my $pkg = shift;
    my $content;
    {
        no strict 'refs';
        my $d = \*{$pkg.'::DATA'};
        {
            no warnings 'unopened';
            $content = join '', <$d>;
        }
        $content =~ s/^.*\n__DATA__\n/\n/s;
        $content =~ s/__END__\n.*$/\n/s;
    }
    return $content;
}

sub _build {
    if (my $data = shift) {
        my @splited_data = split /\$/, $data;

        shift @splited_data;
        my @already_vars;
        for my $segment (@splited_data) {
            next if $segment =~ /_/;
            my @words = split /(?![a-zA-Z0-9_])/, $segment;
            my $var_name = shift @words;
            next if grep { $var_name eq $_ } @already_vars;
            push @already_vars, $var_name;
            $data = "? my \$$var_name = \$_[0]->{$var_name};\n".$data;
        }

        my $f = Text::MicroTemplate::build_mt(decode_utf8 $data);;

        return $f;
    }

    croak "could not find template content in __DATA__ section";
}


1;

