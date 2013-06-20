use strict;
use warnings;
use utf8;
use Nephia::Lite;

run {
    my $req = req;

    my $q = $req->param('q');

    return $q ?
        { title => '河豚の部屋', q => $q }
        : { title => '河豚の部屋' };
};

__DATA__
<!DOCTYPE html>
<html>
<head>
<title><?= $title ?></title>
</head>
<body>
<h1><?= $title ?></h1>
? if ($q) {
<p>query: <?= $q ?></p>
? }
</body>
</html>
