=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	my @res;
	my @chunks = split m{((?<!e)[-+]|[*()/^]|\s+)}, $expr;
	my $lastToken = 0;
	my $count = 0;
	my $prev = '';
	for my $arg (@chunks) {
		given ($arg) {
			when (/^\s*$/) {} 
			when (/\d/) { 
				if (/^\d*\.?\d+([e][+-]?\d+)?$/) {
					$arg = 0 + $arg;
					push @res, "$arg";
					$prev = $arg;
					$lastToken = 1;
				} else {
					die "Bad: '$_'";
				}
			}
			when ([ '+','-' ]){ 
				if (($prev eq ')') || ($prev =~ /\d/)) {
					push @res, $arg;
					$prev = $arg;
				} else {
					$prev = 'U'.$arg;
					push @res, $prev;
				}
				$lastToken = 0;
			}
			when ([ '*','/' ]){
				if (($prev eq ')') || ($prev =~ /\d/)) {
					push @res, $arg;
					$prev = $arg;
					$lastToken = 0;
				} else {
					die "Error!";
				}
			}
			when ('^') {
				if (($prev eq ')') || ($prev =~ /\d/)) {
					push @res, $arg;
					$prev = $arg;
					$lastToken = 0;
				} else {
					die "Error!";
				}
			}
			when ([ '(',')' ]) {
					if ($arg eq '(') {
						$count++;
					} else {
						$count--;
					}
					if ($prev =~ /\d/) {
						$lastToken = 1;
					} else {
						$lastToken = 0;
					}
					push @res, $arg;
					$prev = $arg;
			}
			default {
				die "Bad: '$_'";
			}
		}
	}
	if ($count != 0) {
		die "Error: wrong sequence of brackets!";
	}
	if ($lastToken != 1) {
		die "Bad: tokenize failed, last chunk is not number";
	}
	return \@res;
}

1;
