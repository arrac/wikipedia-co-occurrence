#!/usr/bin/perl -CS


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


sub hsort
{
	my $file_path  = shift;
	my $file_name  = shift;
	my $output_dir = shift;
	my $split_size = shift;
	
	my %h;
	my $count = 0;
	open FILE, $file_path;
	while(<FILE>)
	{
		chomp;
		$h{$_} = 0 unless defined $h{$_};
		$h{$_}++;
		if (scalar(%h) >= $split_size)
		{
			open SFILE, ">", "$output_dir/$file_name" . "_$count";
			foreach $key (sort (keys(%h)))
			{
				for (my $i = 0; $i < $h{$key}; $i++)
				{
					print SFILE $key, "\n";
				}
			}
			close SFILE;
			$count++;
			%h = ();
		}
	}
	if (scalar(%h) > 0)
	{
		open SFILE, ">", "$output_dir/$file_name" . "_$count";
		foreach $key (sort (keys(%h)))
		{
			for (my $i = 0; $i < $h{$key}; $i++)
			{
				print SFILE $key, "\n";
			}
		}
		close SFILE;
	}
	close FILE;
}


sub main
{
	my $input_dir   = $ARGV[0];
	my $output_dir  = $ARGV[1] . "/sorted_splits";
	my $split_size  = $ARGV[2];
	
	mkdir "$output_dir", 0777 unless -d "$output_dir";
	
	opendir DIR, $input_dir;
	foreach (readdir(DIR))
	{
		my $file = $input_dir . "/$_";
		next unless -f $file;

		hsort($file, $_, $output_dir, $split_size);
	}
	closedir DIR;
}

main;
