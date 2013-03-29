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


my $output_dir = $ARGV[0];
my $split_size = $ARGV[1];

my $ln = 0;

open F, ">$output_dir/0.split";

while (<STDIN>)
{
  $ln++;
  print F $_;
  if($ln % $split_size == 0)
  {
    close F;
    open F, ">$output_dir/$ln.split";
  }
}

close F;
