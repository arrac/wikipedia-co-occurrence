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


package WikiParser;

use List;

use strict;

my @links = ();
my @sections = ();
my @result = ();
my %keywords;
my $TITLE_WEIGHT = 30;  #Set this to zero to bypass insignificant page title correction
my $KEYWORDS_PER_SECTION = 50;

sub get_keywords
{
	@links = ();
	@sections = ();
	@result = ();
	%keywords = {};

	my $title = shift;
	my $text = shift;
	
	my $text_orig;
	$text = "qam34e2start".$text."qam34e2end";

	
	#Remove infoboxes

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\{\{[^\{\{]*?\}\}//gs; #remove all boxes
	}


	#Remove html comments

	my $text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;\!--.*?--&gt;//gs; #remove all comments
	}
	
	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;ref.*?\/ref&gt;//gs; #remove all references
	}

	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;ref.*?\/&gt;//gs; #remove all references
	}


	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/<ref.*?ref>//gs; #remove all references
	}

	#Remove other language links

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\[\[..:.*?\]\]//gs; #remove all other language links
	}

	#Remove Images but leave the text
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/(\[\[(Image|File)\:.*?\|(.*?)\]\]$)/RippedImg:$3]]/gsm; #remove all images but add scrap text
	}


	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/(\[\[(Image|File)\:(.*?)\]\]$)//gsm; #remove any leftover images
	}

	#Remove Categories 

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/(\[\[Category\:(.*?)\]\]$)//gsm; #remove all categories
	}

	#Remove popular culture references 

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\sin\spopular\sculture==.*/==qam34e2end/gs; #remove pop culture
	}

	#Remove Footer 

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/==(See also|External Links|References)==.*/qam34e2end/gs; #remove everything after and including "See also"
	}

	#Remove tables and similar stuff

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\{[^\{\{]*?\}//gs; #remove all tables
	}

	#Remove html comments

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/<\!--.*?-->//gs; #remove all comments
	}

	#Convert &quot; to "
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&quot;/"/gsm; #remove &quot;
		$text =~ s/&amp;/&/gsm; #remove &amp;
		$text =~ s/&ndash;/-/gsm; #remove &ndash;
		$text =~ s/&mdash;/-/gsm; #remove &mdash;
	}
	
	#Recognise links
	$text =~ s/\[\[(.*?)(\]\]|\|.*?\]\])(?{push @links, $1;})/$1/gs; #recognise links


        ## TODO Improve parsing to remove all hacks. Hacks should be placed at the very end

	#Convert links to keywords
	my %keywords_case_sensitive = ();
	%keywords = ();
	foreach (@links)
	{
		my $str = $_;
		$str =~ s/(\d),(\d)/$1__$2/ismg;
		my @words = split (/[,\#]/ , $str);
		foreach (@words)
		{
			$_ =~ s/^\s*//;
			$_ =~ s/\s*$//;
			$_ =~ s/\_\_/,/;
			$_ =~ s/\_/ /;
			$_ =~ s/\((.*?)\)$//;

			$_ =~ s/\)*//;
			$_ =~ s/\(*//;
			$_ =~ s/\]*//;
			$_ =~ s/\[*//;
			$_ =~ s/^!*//;
			$keywords_case_sensitive{$_} = 0;
			$keywords_case_sensitive{$1} = 0;			
		}
	}

	#Handle title string seperately
	$title =~ s/(\d),(\d)/$1__$2/ismg;
	my @words = split (/[,\#]/ , $title);
	foreach (@words)
	{
		$_ =~ s/^\s*//;
		$_ =~ s/\s*$//;
		$_ =~ s/\_\_/,/;
		$_ =~ s/\_/ /;
		$_ =~ s/\((.*?)\)$//;

		$_ =~ s/\)*//;
		$_ =~ s/\(*//;
		$_ =~ s/\]*//;
		$_ =~ s/\[*//;
		$_ =~ s/^!*//;
		
		$keywords_case_sensitive{$_} = $TITLE_WEIGHT;
		$keywords_case_sensitive{$1} = $TITLE_WEIGHT;
	}

	#Name detection
	foreach (keys %keywords_case_sensitive)
	{
		next if (length ($_) <= 4 and $_ < 9999 and $_ > 0);
		next if (length($_) == 0);
		my $weight = $keywords_case_sensitive{$_};
		$_ =~ s/^\s*//;
		$_ =~ s/\s*$//;
		$keywords{lc $_} = $weight if (length ($_) > 2 and (!defined $keywords{lc $_} or $keywords{lc $_} < $weight));
		my @words = split (/ / , $_);
		next if (scalar (@words) != 2);
		my $regex = qr/^(the|is|was|a|an|in|of|to|for|at)$/i;
=pod
		if ($words[0] !~ /$regex/ and $words[0] =~ /^[A-Z]/ and $words[1] =~ /^[A-Z]/ and length ($words[1]) > 2)
		{
			$words[1] =~ s/^[^0-9a-zA-Z]*//;
			$words[1] =~ s/[^0-9a-zA-Z]*$//;
			$keywords{lc $words[1]} = $weight;
		}
=cut
	}

	%keywords_case_sensitive = (); #Delete the case sensitive keywords
	
	#Remove hyperlinks 

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\[http.*?\s(.*?)\]/$1/gs; #remove hyperlinks
	}

	#Normalize subsub headings
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/===(.*?)===/$1/gs; #normalize sub-headings
	}


	#Convert every section to something sensible 
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/==(.*?)==/qam34e2end $1 qam34e2start/; 
	}

	#Perform per section link extraction
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/qam34e2start(.*?)qam34e2end(?{push @sections, $1;})//gs; #normalize sub-headings
	}

	foreach (@sections)
	{
		get_section_links ($_);
	}

	@links = ();
	@sections = ();
	return \@result;
}

sub get_section_links
{
	my $text = shift;

	my $top_n = new List ($KEYWORDS_PER_SECTION, "desc");

	my $necessary_section = 0;
	#Count keywords occurrence in the text
	foreach (keys %keywords)
	{
		my $count = 0;
		if ($keywords{$_} > 10) #Handle the title string seperately
		{
			$count = $keywords{$_};
		}
		else
		{
			my $regex = qr/[^0-9A-Za-z]\Q$_\E[^0-9A-Za-z]/i;
			$count++ while $text =~ /$regex/g; 
			$necessary_section++;
		}
		$top_n->push ($_, $count) if ($count != 0);
		$count = 0;
	}
	return if ($necessary_section < 3);
	my @queue = $top_n->get_queue ();
	push (@result, \@queue);
	return;
}

sub get_abstract
{
	my $title = shift;
	my $text = shift;
	$text =~ m/^(.*?'''.*?)\n\n/sm;
	return $1;
}

sub to_plain_text
{
	my $text = shift;

	#print "\n--------\n$text\n--------";		
	#Remove html comments

	my $text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/<\!--.*?-->//gs; #remove all comments
	}
	
	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/<ref.*?\/ref>//gs; #remove all references
	}

	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/<ref.*?\/>//gs; #remove all references
	}

	#Remove html comments

	my $text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;\!--.*?--&gt;//gs; #remove all comments
	}
	
	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;ref.*?\/ref&gt;//gs; #remove all references
	}

	#Remove references

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&lt;ref.*?\/&gt;//gs; #remove all references
	}

	#Remove infoboxes

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\{\{[^\{\{]*?\}\}//gs; #remove all boxes
	}


	
	#Remove tables and similar stuff

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\{[^\{\{]*?\}//gs; #remove all tables
	}

	#Remove other language links

	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\[\[..:.*?\]\]//gs; #remove all other language links
	}

	#Remove Images but leave the text
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/(\[\[(Image|File)\:.*?\|(.*?)\]\]$)//gsm; #remove all images but add scrap text
	}


	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/(\[\[(Image|File)\:(.*?)\]\]$)//gsm; #remove any leftover images
	}

	#print "\n==============\n$text\n==============";

	#Convert '''text''' to text
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/'''(.*?)'''/$1/gsm; #remove '''
	}
	
	#Convert ''text'' to text
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/''(.*?)''/$1/gsm; #remove ''
	}

	#Convert &quot; to "
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/&quot;/"/gsm; #remove &quot;
		$text =~ s/&amp;/&/gsm; #remove &amp;
		$text =~ s/&ndash;/-/gsm; #remove &ndash;
		$text =~ s/&mdash;/-/gsm; #remove &ndash;
	}
	
	#Remove wikilinks without disambiguation 
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\[\[([^\|]*?)\]\]/$1/gsm; #remove [[]]
	}
		
	#Remove wikilinks with disambiguation 
	$text_orig = "";
	while ($text_orig ne $text)
	{
		$text_orig = $text;
		$text =~ s/\[\[[^\]]*?\|(.*?)\]\]/$1/gsm; #remove [[Page Title| ]]
	}
	
	$text =~ s/^\n*//gsm;
	$text =~ s/\t//gsm;
	return $text;
}

1;
