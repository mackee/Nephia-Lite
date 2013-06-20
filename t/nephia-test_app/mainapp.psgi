use strict;
use warnings;
use utf8;
use Nephia::Lite;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

path '/json' => 'SubApp';

run {
    return  { title => 'トップページ' };
};

__DATA__
<!DOCTYPE html>
<html>
<head>
<title><?= $title ?></title>
</head>
<body>
<h1><?= $title ?></h1>
</body>
</html>
