use strict;
use warnings FATAL => 'all';
use feature 'say';
use lib '../lib';
use FormValidation::Simple;

# my $username = 'john';
# my $password = 'foo1bar2';
# my $password_again = 'foo1bar2';
# my $month    = 'Feb';
# my $integer  = 1024;

my $username = 'joh';
my $password = 'foo1bar';
my $password_again = 'foo1bar3';
my $month    = 'Dec';
my $integer  = 3.14;

my @required = (required => 'is required');

my $username_spec = [
    @required,
    length   => [4, 'at least 4 chars', 6, 'at most 6 chars'],
    # length => [4, 6, 'between 4 and 6 chars'],
];

my $password_spec = [
    @required,
    count => [
        qr/[0-9]/, '>= 2', 'at least 2 digits',
    ],
];

my $password_again_spec = [
    @required,
    equals => ['password', "passwords don't match"],
];

my $errors = FormValidation::Simple::validate({
    username => [$username, $username_spec],
    password => [$password, $password_spec],
    password_again => [$password_again, $password_again_spec],
    month    => [$month, [set => [ [qw|Jan Feb Mar|], 'invalid month' ] ]],
    integer  => [$integer, [regexp => [qr/^[0-9]+$/, 'not a valid integer'] ] ],
});

use Data::Dump;
dd $errors;
# output
# {
#   integer        => "not a valid integer",
#   month          => "invalid month",
#   password       => "at least 2 digits",
#   password_again => "passwords don't match",
#   username       => "at least 4 chars",
# }


if (keys %$errors) {
    say 'there were errors with the input, i.e rerender the form';
}
else {
    say 'doing stuff with data';
}