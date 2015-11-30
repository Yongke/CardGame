#!/usr/bin/perl
use strict;
use warnings;
use Math::Combinatorics;
use List::Util qw(sum);
use constant CARDS_CNT => 5;

my $file = 'LJ-poker.txt';
open my $info, $file or die "Could not open $file: $!";

my $error_count = 0;
my $win_count = 0;
my $total_line = 0;
my %score_map = (
    'A'=>1, '2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9,
    '10'=>10, 'J'=>10, 'Q'=>10, 'K'=>10);
my %order_map_1 = ('S'=>4, 'H'=>3, 'C'=>2, 'D'=>1);
my %order_map_2 = (
    'A'=>1, '2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7, '8'=>8, '9'=>9,
    '10'=>10, 'J'=>11, 'Q'=>12, 'K'=>13);

sub user_score {
    my (@player_cards) = @_;
    my @scores = map { $score_map{$_} } @player_cards;
    my $total = sum @scores;
    my @c53 = map { sum @{$_} } combine(3, @scores);
    foreach (@c53) {
        if ($_ % 10 == 0) {
            my $c52 = $total - $_;
            if ( $c52 <= 10) {
                return $c52;
            }
            return $c52 - 10;
        }
    }
    return 0;
}

sub sort_aux {
    my @aa = $a =~ /([DHSC])([2-9AJQK]|10)/g;
    my @bb = $b =~ /([DHSC])([2-9AJQK]|10)/g;
    my $m = $order_map_1{$aa[0]};
    my $n = $order_map_1{$bb[0]};
    my $x = $order_map_2{$aa[1]};
    my $y = $order_map_2{$bb[1]};
    if($x < $y) {
        return 1;
    }
    elsif($x > $y) {
        return -1;
    }
    if($m < $n) {
        return 1;
    }
    elsif($m > $y) {
        return -1;
    }
    return 0;
}

sub max_card {
    my (@cards) = @_;
    my @sorted_cards = sort sort_aux @cards;
    return shift @sorted_cards;
}

sub compare {
    my (@player_cards) = @_;
    my %player_0 = %{$player_cards[0]};
    my %player_1 = %{$player_cards[1]};
    my $score_0 = user_score (values %player_0);
    my $score_1 = user_score (values %player_1);
    my $max_0 = max_card (keys %player_0);
    my $max_1 = max_card (keys %player_1);
    if ($score_0 > $score_1) { return 1; }
    if ($score_0 == $score_1) {
        my $new_max = max_card ($max_0, $max_1);
        if ($new_max eq $max_0) { return 1; }
    }
    return 0;
}

while( my $line = <$info>)  {
    $line =~ tr/\n//d;
    $total_line += 1;
    if ($line !~ /^(([DHSC]{1}([2-9AJQK]|10){1}){5};([DHSC]{1}([2-9AJQK]|10){1}){5}){1}$/g) {
        $error_count += 1;
    } else {
        my %all_cards = ();
        my @words = split /;/, $line;
        my @player_cards = ();
        my $user_idx = 0;
        foreach (@words) {
            my %cards = ();
            while ( $_ =~ /([DHSC]{1}([2-9AJQK]|10){1})/g ) {
                $cards{$1} = $2;
                $all_cards{$1} = $2;
            }
            $player_cards[$user_idx++] = \%cards;
        }
        if ((my $all_size = keys %all_cards) != 2 * CARDS_CNT) {
            $error_count += 1;
        } else {
            $win_count += compare @player_cards;
        }
    }
}
my $player1_win_count = $total_line - $win_count - $error_count;
print "Leon win: $win_count\n";
print "Judy win: $player1_win_count\n";
print "Error records count: $error_count\n";
close $info;
