package FormValidation::Simple;
use strict;
use warnings FATAL => 'all';
use 5.008;
our $VERSION = 1.0;
use Exporter 'import';
our @EXPORT_OK = qw|validate|;

# Example $validation_spec, the features it should support at minimum.
# my $validation_spec = [
#     required => 'is required',

#     length => [5, 'at least 5 characters', 100, 'less than 100'],
#     # or
#     # length => [5, 100, 'must be between 5 and 100 characters'],

#     count => [
#         qr/[0-9]/,    '>= 2',  'at least 2 digits',
#           and exactly 1 letter
#         qr/[A-Za-z]/, '== 1' , 'exactly 1',
#     ],

#     equals => ['<another-field-name>', "passwords don't match"],

#     regexp => [qr/^\d+$/, 'not an integer'],

#     set => [['jan feb mar'], 'invalid <something: month for example>'],

#     custom => sub {
#         my ($input_value, $errors) = @_;
#         # ...
#         return 'error-message-for-this-custom-constraint';
#         # If the error message is undef, i.e there is no error message
#         # it means the $input_value passes the custom constraint.
#         return;
#     },
# ];

# my $errors = input_validation({
#     username => [$username, $username_validation_spec],
#     password => [$password, $password_validation_spec],
#     repeat_password => [$repeat_password, $repeat_password_validation_spec],
# });

# An idea for an error message:
# croak "'password' field, referenced by 'repeat_password', doesn't exist

# input_validation should return a hash-ref
# (ref($errors) eq 'HASH') == 1;


sub validate { my ($inputs) = @_;
    my $errors = {};

    INPUT:
    for my $input_name (keys %$inputs) {
        my ($input_value, $input_spec) = @{ $inputs->{$input_name} };

        my $spec_length = @$input_spec;
        # If the first constraint is not the 'required' constraint
        # and if the $input_value is not defined, then the other
        # constraints would blow up with uninitialized error.
        if ($spec_length
        && $input_spec->[0] ne 'required'
        && !defined $input_value) {
            $input_value = '';
        }

        CONSTRAINT:
        for (my $constraint_index = 0;
             $constraint_index < $spec_length;
             $constraint_index += 2) {

            my $constraint = $input_spec->[$constraint_index];
            my $constraint_value = $input_spec->[$constraint_index + 1];

            if ($constraint eq 'required') {
                if (!defined $input_value || $input_value eq '') {
                    # The $constraint_value for the 'required' constraint
                    # is the error message.
                    $errors->{$input_name} = $constraint_value;
                    next INPUT; # last CONSTRAINT;
                }
            }
            elsif ($constraint eq 'length') {
                if (@$constraint_value == 3) {
                    my ($min, $max, $error_msg) = @$constraint_value;

                    my $length = length $input_value;
                    if (! ($min <= $length && $length <= $max ) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT; # last CONSTRAINT;
                    }
                }
                elsif (@$constraint_value == 4) {
                    my ($min, $min_error_msg, $max, $max_error_msg)
                        = @$constraint_value;

                    my $length = length $input_value;
                    if ($length < $min) {
                        $errors->{$input_name} = $min_error_msg;
                        next INPUT; # last CONSTRAINT;
                    }
                    elsif ($length > $max) {
                        $errors->{$input_name} = $max_error_msg;
                        next INPUT; # last CONSTRAINT;
                    }
                }
            }
            elsif ($constraint eq 'equals') {
                my ($other_input_name, $error_msg) = @$constraint_value;
                if ($input_value ne $inputs->{$other_input_name}[0]) {
                    $errors->{$input_name} = $error_msg;
                    next INPUT;
                }
            }
            elsif ($constraint eq 'set') {
                my ($set, $error_msg) = @$constraint_value;

                my $in_set = 0;
                ITEM:
                for my $item (@$set) {
                    if ($input_value eq $item) {
                        $in_set = 1;
                        last ITEM;
                    }
                }
                if (!$in_set) {
                    $errors->{$input_name} = $error_msg;
                    next INPUT;
                }
            }
            elsif ($constraint eq 'regexp') {
                my ($regexp, $error_msg) = @$constraint_value;
                if ($input_value !~ /$regexp/) {
                    $errors->{$input_name} = $error_msg;
                    next INPUT;
                }
            }
            elsif ($constraint eq 'count') {
                my $count_length = @$constraint_value;
                for (my $count_index = 0;
                    $count_index < $count_length;
                    $count_index += 3) {

                    my $regexp    = $constraint_value->[$count_index];
                    my $op_val    = $constraint_value->[$count_index + 1];
                    my $error_msg = $constraint_value->[$count_index + 2];

                    my ($op, $val) = split ' ', $op_val;

                    # https://metacpan.org/pod/perlsecret#Goatse
                    my $count_val =()= $input_value =~ /($regexp)/g;

                    if ( $op eq '>=' && (!($count_val >= $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                    elsif ( $op eq '>' && (!($count_val > $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                    elsif ( $op eq '==' && (!($count_val == $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                    elsif ( $op eq '<=' && (!($count_val <= $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                    elsif ( $op eq '<' && (!($count_val < $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                    elsif ( $op eq '!=' && (!($count_val != $val)) ) {
                        $errors->{$input_name} = $error_msg;
                        next INPUT;
                    }
                }
            }
            elsif ($constraint eq 'custom') {
                my $error_msg = $constraint_value->($input_value, $errors);
                # The custom constraint failed.
                if (defined $error_msg) {
                    $errors->{$input_name} = $error_msg;
                    next INPUT;
                }
            }
        }
    }

    return $errors;
}


1;