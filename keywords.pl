#!/usr/bin/env perl -CS


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


use WikiParser;

my $END_DELIM     = "\n"; #Set the delimeter to be returned at the end of each string
my $GET_KEYWORDS  = 1;    #Set to 1 to output keywords
my $GET_ALIASES   = 0;    #Set to 1 to output aliases
my $GET_ABSTRACT  = 0;    #Set to 1 to output abstract

#The list of page types to be ignored
my @black_list = ("File:", "Wikipedia:", "Portal:", "P:", "Category:", "Template:", "Editing User:", "Help:", "MediaWiki:", "C:", "CAT:");
my $process_counter = 0;

sub get_keywords
{
  my $id = shift;
  my $title = shift;
  my $wikitext = shift;
  
  return if lc substr ($wikitext, 0, 9) eq "#redirect";
  foreach (@black_list)
  {
    my $blen = length $_;
    return if substr ($title, 0, $blen) eq $_;
  }
  my $abstract = WikiParser::get_abstract ($title, $wikitext);
  my $result = WikiParser::get_keywords ($title, $wikitext);


  my @outputs = ();
  foreach (@$result)
  {
    my $output =  "$id\t$title";    
    foreach $term_pair (@$_)
    {
      $term = $$term_pair[0];
      $term =~ s/\t/ /g;
      $output .= "\t$term";
    }
    $output .= $END_DELIM;
    push @outputs, $output;
  }	
  return \@outputs;
}

sub get_abstract
{
  my $id = shift;
  my $title = shift;
  my $wikitext = shift;
  
  return if lc substr ($wikitext, 0, 9) eq "#redirect";
  foreach (@black_list)
  {
    my $blen = length $_;
    return if substr ($title, 0, $blen) eq $_;
  }
  my $abstract_wikitext = WikiParser::get_abstract ($title, $wikitext);
  my $keywords = WikiParser::get_keywords($title, $abstract_wikitext);
  my $abstract = WikiParser::to_plain_text ($abstract_wikitext);
  $abstract =~ s/\n/\\n/gsm;
  my $ret_str =  "$id\t$title\t$abstract";
  foreach (@$keywords)
  {
    foreach $term_pair (@$_)
    {
      $term = $$term_pair[0];
      $term =~ s/\t/ /g;
      $ret_str .= "\t$term";
    }
  }
  $ret_str .= $END_DELIM;
  return $ret_str;
}

sub get_redirects
{
  my $id = shift;
  my $title = shift;
  my $wikitext = shift;
  
  return unless lc substr ($wikitext, 0, 9) eq "#redirect";
  if ($wikitext =~ m/#redirect.*?\[\[(.*?)\]\].*/sig)
  {
    $keyword = $1;
    $keyword =~ s/\t/ /g;
    return "$id\t$title\t$keyword$END_DELIM";
  }
}


# Usage 
# perl keywords.pl <input from stdin> <output to stdout>

while (<>)
{
  chomp;
  my ($id, $title, $wikitext) = split "\t", $_;
  $wikitext =~ s/\\n/\n/g;
  print get_abstract($id, $title, $wikitext) if ($GET_ABSTRACT);
  print get_redirects($id, $title, $wikitext) if ($GET_ALIASES);       
  if ($GET_KEYWORDS)
  {
    my $o = get_keywords($id, $title, $wikitext);
    foreach (@$o) { print $_;}
  }
}
  
