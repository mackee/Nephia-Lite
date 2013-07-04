requires 'perl', '5.008001';
requires 'Nephia', '>= 0.23';
requires 'Text::MicroTemplate', '>= 0.19';
requires 'Encode';
requires 'Carp';
requires 'Nephia::DSLModifier';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

