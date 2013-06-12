use Nephia::Lite;

to_app {
    return {
        title => 'fugu\'s room',
    };
};

__DATA__

<html>
<head><title><?= $title ?></title></head>
<body>
<h1>Welcome to <?= $title ?></h1>
</body>
</html>

