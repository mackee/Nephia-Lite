# NAME

Nephia::Lite - mini and lite WAF. one file, once write, quickly render!

# SYNOPSIS

in app.psgi :

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

and plackup

    plackup app.psgi

Open "http://localhost:5000" with your favorite browser.

Rendered Dynamic Pages in your display!

# DESCRIPTION

Nephia::Lite is minimum set of Nephia.

However, usable Nephia's feature and useful plugins.

## Rendering page with template

Nephia::Lite used [Text::MicroTemplate](http://search.cpan.org/perldoc?Text::MicroTemplate).

Write after \_\_DATA\_\_ in app.psgi.

## JSON Output

Don't write \_\_DATA\_\_ and templates.

Nephia::Lite automatically recognize to you want to JSON.

    use Nephia::Lite;

    to_app {
        return {
            message => 'Hello! This is a My JSON!!!'
        };
    };

Output

    {
        'message' : 'Hello! This is a My JSON!!!'
    }

## Other features

Use can Nephia's features and plugins.

Ex. redirect, header, validate([Nephia::Plugin::Data::Validater](http://search.cpan.org/perldoc?Nephia::Plugin::Data::Validater)) and other DSLs.

But cannot use Nephia Views yet.

# SEE ALSO

[Nephia](http://search.cpan.org/perldoc?Nephia)

[Text::MicroTemplate](http://search.cpan.org/perldoc?Text::MicroTemplate)

# LICENSE

Copyright (C) macopy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

macopy <macopy\[attttttt\]cpan.com>
