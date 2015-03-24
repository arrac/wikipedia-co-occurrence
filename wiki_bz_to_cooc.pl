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

# $ARGV[0] absolute path to gz file
# $ARGV[1] process directory

`mkdir -p \"$ARGV[1]/dump\"`; 
`mkdir -p \"$ARGV[1]/splits\"`; 
`mkdir -p \"$ARGV[1]/coocs\"`; 
`mkdir -p \"$ARGV[1]/sorted\"`;

`bzcat \"$ARGV[0]\" | perl -CS clean.pl > \"$ARGV[1]/dump/wiki_articles_as_lines\"`;
`cat \"$ARGV[1]/dump/wiki_articles_as_lines\" | perl -CS splitter.pl \"$ARGV[1]/splits\" 10000`;
`perl -CS process.pl \"$ARGV[1]/splits\" \"$ARGV[1]/coocs\"`;
`perl -CS sort.pl \"$ARGV[1]/coocs\" \"$ARGV[1]/sorted\" 5000000`;
`perl -CS merge.pl \"$ARGV[1]/sorted/sorted_splits\" \"$ARGV[1]/sorted\";

#Clean up these lines
`cat \"$ARGV[1]/sorted/10/sort0\" | perl -CS uniq.pl > \"$ARGV[1]/cc\"`;
`cat \"$ARGV[1]/cc\" | perl -CS node_metrics.pl > \"$ARGV[1]/nodes\"`;
`cat \"$ARGV[1]/cc\" | awk -F \"\\t\" '\$1!=\$2' > \"$ARGV[1]/edges\"`;
