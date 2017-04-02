=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub prior{
    my $ops = shift;
	return
		$ops eq '+' || $ops eq '-' ? 1 :
		$ops eq '*' || $ops eq '/' ? 2 :
		$ops eq 'U+' || $ops eq 'U-' ? 3 :
		$ops eq '^' ? 3 :
		-1;
}


sub rpn {
	my $expr = shift;
	my $stack = tokenize($expr);
	my @rpn;
	my @ops;
	my $k;
	my $size;

	for my $elem (@$stack) {
		given ($elem) {
			when ('(') {
				push @ops, $elem;
			}
			when (')') {
				$k = pop @ops;
				while ($k ne '(') {
					push @rpn, $k;
					$k = pop @ops;
				}
			}
			when ([ '+', '-', '*', '/' ]){
				if ($size = @ops > 0) {
					while (prior($elem) <= prior(@ops[$size = @ops - 1])) {
						$k = pop @ops;
						push @rpn, $k;
						last if ( $size = @ops == 0);
					}
				}
				push @ops, $elem;
			}
			when ([ 'U+', 'U-', '^']){
				if ($size = @ops > 0) {
					while (prior($elem) < prior(@ops[$size = @ops - 1])) {
						$k = pop @ops;
						push @rpn, $k;
						last if ($size = @ops == 0);
					}
				}
				push @ops, $elem;
			}
			when (/\d/) {
				push @rpn, $elem;
			}
			default {
				die "Bad expr '$_'";
			}
		}
	}

	while ( $size = @ops > 0) {
		$k = pop @ops;
		push @rpn, $k;
	}

	return \@rpn;
}


1;
