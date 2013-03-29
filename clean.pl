#!/usr/bin/perl 


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


sub process
{
  my $content = shift;
  if ($content =~ m/<title>(.*?)<\/title>.*?<id>(.*?)<\/id>.*?<text xml:space="preserve">(.*?)<\/text>/imgs)
  {
    return ($1, $2, $3);
  }
}

my $in_page = 0;
my $content = "";
my $i = 1;

while (<>)
{
  my $line = $_;
  my $orig_line = $_;
  chomp $line;
  $line =~ s/^\s*//imgs;
  $line =~ s/\s*$//imgs;
  if ($line eq "<page>")
  {
    $in_page = 1;
  }
  elsif ($line eq "</page>")
  {
    $in_page = 0;
    my ($title, $id, $text) = process ($content);
    $text =~ s/\n/\\n/ismg;
    print "$id\t$title\t$text\n";
    $content = "";
  }
  elsif ($in_page == 1)
  {
    $content.= $orig_line."\n";
  }
}

