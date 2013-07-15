use strict;
use warnings;
use utf8;
use Nephia::Lite::Xslate;

run {
    my $req = req;

    my $q = $req->param('q');

    return { title => 'ここはトップページです' };
};

__DATA__
<!DOCTYPE html>
<html>
<head>
<title><: $title :></title>
<meta charset='utf-8'> 
</head>
<body>
<h1><: $title :></h1>
<ul>
: for [1..10] -> $i {
<li><: $i :></li>
: }
</ul>
</body>
</html>
