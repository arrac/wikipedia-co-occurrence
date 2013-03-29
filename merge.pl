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


# Does a 2-way merge sort
sub merge
{
  my $f1  = shift;
  my $f2  = shift;
  my $l   = shift;
  my $c   = shift;
  my $dir = shift;

  open F1, $f1;
  open F2, $f2;
  mkdir "$dir/$l", 0777 unless -d "$dir/$l";
  open OUT, ">", "$dir/$l/sort$c";
  #print "Merging: $f1\t$f2\t$l\t$c\n";
  my $to_read_f1 = 1;
  my $to_read_f2 = 1;
  my $f1l = "";
  my $f2l = "";
  
  while (!eof(F1) or !eof(F2))
  {
    if ($to_read_f1 and !eof(F1))
    {
      $f1l = <F1>;
      chomp $f1l;
      $to_read_f1 = 0;
    }
    if ($to_read_f2 and !eof(F2))
    {
      $f2l = <F2>;
      chomp $f2l;
      $to_read_f2 = 0;
    }
    if ($to_read_f1)
    {
      print OUT $f2l, "\n";
      #print "1: ", $f2l, "\n";
      $to_read_f2 = 1;      
    }
    elsif ($to_read_f2)
    {
      print OUT $f1l, "\n";
      #print "2: ", $f1l, "\n";
      $to_read_f1 = 1;      
    }
    elsif ($f1l le $f2l)
    {
      print OUT $f1l, "\n";
      #print "3: ", $f1l, "\n";
      $to_read_f1 = 1;
    }
    else
    {
      print OUT $f2l, "\n";
      #print "4: ", $f2l, "\n";
      $to_read_f2 = 1;
    }
    #print "EOF F1\n" if (eof(F1));
    #print "EOF F2\n" if (eof(F2));
  }
  print OUT $f1l, "\n" unless ($to_read_f1);
  #print "5: ", $f1l, "\n" unless ($to_read_f1);
  print OUT $f2l, "\n" unless ($to_read_f2);
  #print "6: ", $f2l, "\n" unless ($to_read_f2);
  
  

  close F1;
  close F2;
  close OUT;
  
}



sub process_level
{
  #my $input_dir = "/home/aditya/Data/Wikipedia/tmp/0";
  
  my $input_dir = shift;
  my $temp_dir  = shift;
  my $level     = shift;
  my $count     = 0;
  my $dirh;  
  #print "InputDIR: ", $input_dir, "\n";
  opendir $dirh, $input_dir;
  open TMP, ">/tmp/mergex";
  close TMP;
  my $f1;
  my $f2;
  my $i = 0;
  foreach my $file (readdir($dirh))
  {
    #print "Picked File: ", $level, ":", $file, "\n";
    next if ($file eq "." || $file eq "..");
    if ($i % 2 == 0)
    {
      $f1 = "$input_dir/$file";
      #print "F1: $f1\n";
    }
    else
    {
      $f2 = "$input_dir/$file";
      #print "F2: $f2\n";
      merge ($f1, $f2, $level, $count, $temp_dir);
      $count++;
    }
    $i++;
  }
  if ($i % 2 == 1)
  {
    merge ($f1, "/tmp/mergex", $level, $count, $temp_dir);
    $count++;
  }
  closedir($dirh);
  return $count;
}

sub main
{
  my $level = 0;
  my $input_dir = $ARGV[0];
  my $temp_dir  = $ARGV[1];
  while (process_level($input_dir, $temp_dir, $level) > 1)
  {
    $input_dir = "$temp_dir/$level";
    $level++;
    #print "---------------------\n";
  }
  #open F, "$temp_dir/$level/sort0";
  #while (<F>)
  #{
  #  print $_;
  #}
  #close F;
}

main;

__END__
=pod
  my @f1lines = <F1>;
  my @f2lines = <F2>;
  while (scalar(@f1lines) > 0 and scalar(@f2lines) > 0)
  {
    chomp($f1lines[0]);
    chomp($f2lines[0]);
    if ($f1lines[0] le $f2lines[0])
    {
      print OUT $f1lines[0], "\n";
      shift @f1lines;
    }
    else
    {
      print OUT $f2lines[0], "\n";
      shift @f2lines;      
    }
  }
  foreach my $ln (@f1lines)
  {
    chomp($ln);
    print OUT $ln, "\n";
  }
  foreach my $ln (@f2lines)
  {
    chomp($ln);
    print OUT $ln, "\n";
  }
  close F1;
  close F2;
  close OUT;

=cut  

