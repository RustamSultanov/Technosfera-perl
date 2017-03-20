package DeepClone;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

sub clone {
	my $box = shift;
	return clone2($box);
}

sub clone2 {
	my ($orig, $refs) = @_;
	my $cloned;
	if (my $ref = ref $orig) {
		if ($ref eq 'HASH') {
			if (exists $refs->{$orig}) {
				$cloned = $refs->{$orig}
			}
			else {
				my %h;
				$refs->{$orig} = \%h;
				while (my ($r,$x) = each %$orig) {
					$h{$r} = clone2($x, $refs);
					return undef if exists $refs->{"Bad data"};
				}
				$cloned = \%h;
				$refs->{$orig} = $cloned;
			}
		}
		elsif ($ref eq 'ARRAY') {
			if (exists $refs->{$orig}) {
				$cloned = $refs->{$orig}
			}
			else {
				my @arr;
				$refs->{$orig} = \@arr;
				push @arr, clone2($_, $refs) for @$orig;
				return undef if exists $refs->{"Bad data"};
				$cloned = \@arr;
				$refs->{$orig} = $cloned;
			}
		}
		else {
			$refs->{"Bad data"} = "No validate";
			return undef;
		}
	}
	else {
		$cloned = $orig;
	}
	return $cloned;
}


1;
