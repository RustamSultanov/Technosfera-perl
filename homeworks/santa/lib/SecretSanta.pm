package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;
use List::Util qw(first);

sub calculate {
	my @members = @_;
	my @res;

	# get all names members
	my @names = map {
		ref() ? @$_ : $_
	} @members;

	die "There won't be any surprise to @names" if ($#names <= 2);
	
	my %cantToGive;

	@cantToGive{@names} = map { {$_ => '1'} } @names; # cause smb can't give present for himself 
	
	foreach my $arrRef (@members) {		#cause husband can't give present his wife and vice versa
		if (ref $arrRef) {				#checking arrays
			if (ref $arrRef eq 'ARRAY' && scalar(@$arrRef) == 2) {
			
				my ($husband, $wife) = @$arrRef; # or $wife, $husband -- no matter

				$cantToGive{$husband}{$wife} = 1;
				$cantToGive{$wife}{$husband} = 1;				

			} else {
				die "No validate data in $arrRef"
			}
		}
	}
	
	# we making random pairs, and adding each of them to has %cantToGive

	my ($from, $to, $toInd);

	
	my %withGift;

	for my $index (0..$#names) {
		# say $index;
		# say sort keys %withGift;

		$from = $names[$index];

		$toInd = int(rand(scalar(@names)));	#get random '$to'
		$to = $names[$toInd];

		
		if (exists $withGift{$to} || isForbiddenToGive($from, $to, \%cantToGive)) { 
			
			#say grep { ! exists $withGift{$_} &&  $cantToGive{$from}{$_} } @names;

			if ($index == $#names) {
				
				if (!(exists $withGift{$from}) 				# 	if last member without present nobody can't give present for him
												||			
					(first 	{!exists $withGift{$_} 			#	if in @names found member without present
												&& 			 
							$cantToGive{$from}{$_} 			#	last  $from can't give present for him
							}			@names[0..$#names-1])) { #  recalculation
				
					# tail goto
					goto &calculate;				#if bad distribution, do it again!

				} else { 
					$to = first { !exists $withGift{$_} } @names;
					push @res, [$from, $to];
					return @res;
				 }

			}
			
			redo;

		} else {

			$withGift{$to} = '1';
			$cantToGive{$to}{$from} = '1';

			push @res, [$from, $to];
	
		}
	}
	
	#p @res;
	return @res;
}

sub isForbiddenToGive {		# returns true if prohibited
	my ($from, $to, $href) = @_;

	return exists $href->{$from}->{$to};

}


1;
