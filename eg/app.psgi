use Nephia::Lite;

run {
    return {
        title => 'fugu\'s room',
    };
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
