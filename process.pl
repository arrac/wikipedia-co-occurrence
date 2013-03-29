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


my $input_dir = $ARGV[0];
my $output_dir = $ARGV[1];

opendir (DIR, $input_dir) or die "could not open dir: $!";
foreach (readdir(DIR)) 
{
    my $file = $input_dir . "/$_";
    next unless -f $file;
    print "Processing $file...";
    `cat \"$file\" | perl -CS keywords.pl | perl -CS cooccurrence.pl > \"$output_dir/$_\"\n`;
    print "\tdone.\n";
}
