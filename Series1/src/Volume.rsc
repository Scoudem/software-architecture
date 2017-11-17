module Volume

import IO;
import List;
import String;
import Util;
import util::Resources;
import lang::java::jdt::m3::Core;

int rankVolume(loc prj)
{
	str lng = "java";
	map[str,list[int]] kloc = ("java"  : [66,246,665,1310]);
	int n = nCodeLines(prj) / 1000;
	int r = (0
			| n > x ? it + 1 : it
			| x <- kloc[lng]);
	return r;
}

// All source code lines that are not blank 
// (only contain whitespace) or comment lines
int nCodeLines(loc prj)
{
	lines   = allLines(srcFiles(prj));
	total   = size(lines);
	empty   = nEmptyLines(lines);
	comment = nCommentLines(prj);
	code    = total - empty - comment;
	return code;
}

// All source code lines from string that are not blank 
// (only contain whitespace) or comment lines
int nCodeLinesFromString(loc prj, str contents)
{
	lines   = split("\n", contents);
	total   = size(lines);
	empty   = nEmptyLines(lines);
	comment = nCommentLinesFromString(prj, contents);
	code    = total - empty - comment;
	return code;
}

// Lines that are not just whitespace
list[str] nonEmptyLines(list[str] lines)
{
	return [x | x <- lines, /^\s*$/ !:= x];
}

int nEmptyLines(list[str] lines)
{	
	int total    = size(lines);
	int nonEmpty = size(nonEmptyLines(lines));
	return (total - nonEmpty);
}

int nCommentLines(loc prj) = (0
	| it + nCommentLinesFromString(f, readFile(f))
	| f <- srcFiles(prj));

int nCommentLinesFromString(loc file, str contents)
{
	rel[loc,loc] m3Doc = createM3FromString(file, contents).documentation;
	list[loc] doc = sort([x | <_, x> <- m3Doc], offsetMoreThan);
	int result = (0
		| it + 1 + x.end.line - x.begin.line
		| x <- doc);
	list[str] lines = readFileLines(file);
	lines = removeFirstLastLineComments(doc, lines);
	result -= nLinesWithMoreThanJustComments(doc, lines);
	return result;
}

int nLinesWithMoreThanJustComments(list[loc] doc, list[str] lines)
{
	result = 0;
	for(i <- [0..size(doc)])
	{
		x = doc[i];
		b = x.begin.line - 1;
		e = x.end.line - 1;
		s = lines[b];
		if(/\S/ := lines[b]) 
			result += 1;
		if(e != b && /\S/ := lines[e]) 
			result += 1;
	}
	return result;
}

list[str] removeFirstLastLineComments(list[loc] doc, list[str] lines)
{
	for(i <- [0..size(doc)])
	{
		x = doc[i];
		b = x.begin.line - 1;
		e = x.end.line - 1;
		bc = x.begin.column;
		ec = x.end.column;
		if(b == e) 
			lines[b] = lines[b][0..bc] + lines[b][ec..];
		else
		{
			lines[e] = lines[e][ec..];
			lines[b] = lines[b][0..bc];
		}
	}
	return lines;
}

bool offsetMoreThan(loc a, loc b) = a.offset > b.offset;