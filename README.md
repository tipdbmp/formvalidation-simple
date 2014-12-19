## NAME
FormValidation::Simple - simple form input data validation

## SYNOPSIS

```perl
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
# Output:
# {
#   integer        => "not a valid integer",
#   month          => "invalid month",
#   password       => "at least 2 digits",
#   password_again => "passwords don't match",
#   username       => "at least 4 chars",
# }
```

## DESCRIPTION

Because you can not trust the data users send via the web forms, you need to validate
it and report error messages back to the users. This usually results in repetitive/boilerplate
code with big if-elsif-else blocks that can get messy.
This module tries to make the validation process somewhat simpler.

## HOW IT WORKS

Every input needs to pass certain list of rules/constraints/spec. The constraints that
FormValidation::Simple exposes are:
required, length, equals, set, regexp, count and custom.
The order in which the constraints are listed in the spec is the order in which they are checked.
So if an input has both a regexp and a length constraint and the regexp
comes before and it fails the error for the input is set to that of the regexp constraint.


#### require
The error message is set when the value is ```undef``` or ```''``` (the empty string).
```perl
require => 'error-message'
```

#### length

###### length with 3 arguments
The error message is set when the value is outside of the [min, max] range.

```perl
length => [Int $min, Int $max, 'error-message'],
```

###### length with 4 arguments
If the value is < $min the error message is set to 'min-error-message',
if instead it's > $max the error message is set to 'max-error-message'.
```perl
length => [Int $min, 'min-error-message', Int $max, 'max-error-message'],
```

#### equals
```perl
equals => ['<another-input's-name>', 'error-message']],
```

#### set
The error message is set when the value is not in the set specified by $array-ref.

```perl
set => [$array-ref, 'error-message'],
```

#### regexp
regexp => [qr/^...$/, 'error-message'],

#### count
```perl
count => [
    qr/[0-9]/,    '>= 2',  'at least 2 digits',
    # and
    qr/[A-Za-z]/, '== 1' , 'exactly 1 letter',
],
```

Valid comparison operators: '>=', '>', '==', '<', '<=' and '!='.


#### custom
Return the error message if the custom constraint fails, otherwise return undef (i.e return;)
```perl
custom => sub {
    my ($input_value, $errors) = @_;
    ...
},
```

## SEE ALSO

[Input::Validator](https://metacpan.org/pod/Input::Validator)
[Validate::Tiny](https://metacpan.org/pod/Validate::Tiny)