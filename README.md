# NAME

Nephia::Lite - mini and lite WAF. one file, once write, quickly render!

# SYNOPSIS

    use Nephia::Lite;

    to_app {
        return {
            title => 'sample'
        }
    };
    __DATA__

    <html>
    <head>
    <title><?= $title ?></title>
    <body>
    <h1>Hello, <?= $title ?></h1>
    </body>
    </html>

# DESCRIPTION

Nephia::Lite is minimum set of Nephia.
However, usable Nephia's feature and useful plugins.

# SEE ALSO

[Nephia](http://search.cpan.org/perldoc?Nephia)

[Text::MicroTemplate](http://search.cpan.org/perldoc?Text::MicroTemplate)

# LICENSE

Copyright (C) macopy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

macopy <macopy\[attttttt\]cpan.com>
