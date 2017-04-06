=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;

	 my @data;
  for my $r (@{$rpn}){
      given ($r) {
          when (['U+','U-']){
              if($r eq 'U-'){  my $arg1 = pop(@data);push(@data, -$arg1)}
          }
		  when (['+','-','*','/','^','U+','U-']){
              my $arg1 = pop(@data);
              my $arg2 = pop(@data);
              given ($r){
                  when ("*") { push( @data, $arg2 * $arg1) }
                  when ("+") { push( @data, $arg2 + $arg1) }
                  when ("/") { push( @data, $arg2 / $arg1 ) }
                  when ("-") { push( @data, $arg2 - $arg1 ) }
                  when ("^") { push( @data, $arg2 ** $arg1 )}
              }
          }
          default{
              push(@data, $r);
          }
      }
  }
	return pop(@data);
}


1;
