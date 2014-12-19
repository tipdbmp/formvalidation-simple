use strict;
use warnings FATAL => 'all';
use feature 'say';
use lib '../lib';
use FormValidation::Simple;


# 1 <= $month <=  12
my $days_for_month = [ undef,
    31, 28, 31, 30,
    31, 30, 31, 31,
    30, 31, 30, 31,
];

sub is_leap_year { my ($year) = @_;
    return 0 if $year % 4 != 0;
    return 0 if $year % 100 == 0 && $year % 400 != 0;
    return 1;
}

sub number_of_days_for_month_in_year { my ($year, $month) = @_;
    return 29 if is_leap_year($year) && $month == 2;
    return $days_for_month->[$month];
}

# format for date: yyyy-mm-dd
sub is_valid_date { my ($date) = @_;
    my $error_msg = 'not a valid date';

    return $error_msg if !defined $date;
    return $error_msg
        if $date !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/;

    my ($year, $month, $day) = split '-', $date;
    # dd $year, $month, $day;
    # return $error_msg
    #     if 0 < grep { !defined($_) || $_ eq '' } $year, $month, $day;

    return $error_msg
        if ! ( 1900 <= $year && $year <= 2014 );

    return $error_msg if ! (1 <= $month && $month <= 12);

    my $days_for_month = number_of_days_for_month_in_year($year, $month);
    return $error_msg
        if ! (1 <= $day && $day <= $days_for_month);

    return; # date is valid
}

# my $date;
# my $date = '2014-02-29';
my $date = '2012-02-29';

my $date_spec = [
    required => 'is required',
    custom => \&is_valid_date,
];

my $errors = FormValidation::Simple::validate({
    date => [$date, $date_spec],
});

use Data::Dump;
dd $errors;

