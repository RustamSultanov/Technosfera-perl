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

sub prior($){
    my $ops=shift;
    given ($ops){
        when (['U+','U-']) {return 4;}
        when (['^']){return 3;}
        when (['*','/']){return 2;}
        when (['+','-']){return 1;}
        default{return 0;}
    }
}


sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;
	my @ops = ();

	for my $r (@{$source}){
      given ($r){
          when (['U+','U-','+','-','*','/','^']){
              if ($r=~/U[\+\-]|\^/){
                  while (prior($r)<prior($ops[-1])){
                      push(@rpn,pop(@ops));
                  }
              }
              else{
                  while (prior($r)<=prior($ops[-1])){
                      push(@rpn,pop(@ops));
                  }
              }
              push(@ops,$r);
          }
          when('('){
              push(@ops,$r); 
          }
          when(')'){
              while($ops[-1] ne '('){
                  if (@ops){push(@rpn,pop(@ops));}
                  else {die "Something wrong brackets ";}
              }
              pop(@ops);
          }
          default{
              $r = 0+$r;
              push(@rpn,"$r");
          }
      }
  }
  while (@ops and $ops[-1] ne '('){
      push(@rpn,pop(@ops));
  }
  if (@ops) {die "Bad expression @{$source}";}
	return \@rpn;
}


1;
