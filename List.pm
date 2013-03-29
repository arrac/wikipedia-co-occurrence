
#This file is part of Wikipedia to Co-occurrence Graph (WCG).

#WCG is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#WCG is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with WCG.  If not, see <http://www.gnu.org/licenses/>.

#For any details please contact: Aditya Rachakonda (aditya.rachakonda@gmail.com)



package List;


use strict;

sub new
{
	my $class = shift;
	my $self = {};
	$self->{N} = shift;
	$self->{ORDER} = shift;
	$self->{SIZE} = 0;
	$self->{QUEUE} = [];
	bless $self, $class;
	return $self;
}

sub push
{
	my $self = shift;

	my ($element, $value) = @_;
	if ($self->{SIZE} == 0)
	{
		$self->{BEST} = $value;
		$self->{WORST} = $value;
	}
	elsif ($self->{SIZE} < $self->{N})
	{
	}
	elsif ($self->better ($value, $self->{WORST}) == 1)
	{
		$self->pop ();
	}
	else
	{
		return;
	}
	$self->insert ($element, $value);
	$self->fill_stats ();
}

sub pop
{
	my $self = shift;	
	pop @{$self->{QUEUE}};
	$self->fill_stats ();	
}

sub get_queue
{
	my $self = shift;
	return @{$self->{QUEUE}};
}

sub fill_stats
{
	my $self = shift;
	my $queue = $self->{QUEUE};
	$self->{SIZE} = scalar (@{$self->{QUEUE}});
	$self->{BEST} = $$queue[0][1];
	$self->{WORST} = $$queue[$#$queue][1];
}

sub insert
{
	my $self = shift;
	my $queue = $self->{QUEUE};
	my ($key, $value) = @_;
	
	if ($self->{SIZE} == 0 or $self->better ($value, $$queue[$#$queue][1]) < 1)
	{
		push @{$queue}, [$key, $value];
		return;
	}

	for (my $i = 0; $i < scalar (@$queue); $i++)
	{
		if ($self->better ($value, $$queue[$i][1]) == 1)
		{
			splice @$queue, $i, 0, [$key, $value];
			return;
		}
	}	
}

sub better
{
	my $self = shift;
	my ($a, $b) = @_;

	return 1 if (($self->{ORDER} eq "asc" and $a < $b) or ($self->{ORDER} eq "desc" and $a > $b));
	return -1 if (($self->{ORDER} eq "asc" and $a > $b) or ($self->{ORDER} eq "desc" and $a < $b));
	return 0;
}

1;
