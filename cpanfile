requires 'perl', '5.008001';
requires 'Nephia', '>= 0.25';
requires 'Text::MicroTemplate', '>= 0.19';
requires 'Encode';
requires 'Carp';
requires 'Exporter';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

