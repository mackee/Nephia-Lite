use Nephia::Lite;

to_app {
    my $req = req;

    return {
        template => 'DATA',
        title => 'fugu',
    };
};

__DATA__

<html>
<head><title>aaaa</title></head>
<body>
<h1>Welcome to <?= $title ?></h1>
</body>
</html>

