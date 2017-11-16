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
	int n = codeLines(prj) / 1000;
	int r = (0
			| n > x ? it + 1 : it
			| x <- kloc[lng]);
	return r;
}

// All source code lines that are not blank 
// (only contain whitespace) or comment lines
int codeLines(loc prj)
{
	lines   = allLines(javaFiles(prj));
	total   = size(lines);
	empty   = emptyLines(lines);
	comment = commentLines(prj);
	code    = total - empty - comment;
	return code;
}

// All source code lines from string that are not blank 
// (only contain whitespace) or comment lines
int codeLinesFromString(loc prj, str contents)
{
	lines   = split("\n", contents);
	total   = size(lines);
	empty   = emptyLines(lines);
	comment = commentLinesFromString(prj, contents);
	code    = total - empty - comment;
	return code;
}

// Lines that are not just whitespace
list[str] nonEmptyLines(list[str] lines)
{
	return [x | x <- lines, /^\s*$/ !:= x];
}

int emptyLines(list[str] lines)
{	
	int total    = size(lines);
	int nonEmpty = size(nonEmptyLines(lines));
	return (total - nonEmpty);
}

int commentLines(loc prj)
{
	doc = createM3FromEclipseProject(prj).documentation;
	// Get all documentation and lengths from source files
	docLines = {<toBeginColumn(x),
				 x.end.line - x.begin.line + 1> 
				| <_, x> <- doc, endsWith(x.file, ".java")};
	// Add length if the line starts with comment
	// Add length - 1 if not, because there is also code on the (first) line
	return (0 
		| it + ((/^\s*\/\/.*$|^\s*\/\*.*$/ := readFile(x)) ? n : (n - 1)) 
		| <x, n> <- docLines);
}

int commentLinesFromString(loc prj, str contents)
{
	doc = createM3FromString(prj, contents).documentation;
	// Get all documentation and lengths from string
	docLines = {<x.offset,
				 x.length,
				 x.end.line - x.begin.line + 1> 
				| <_, x> <- doc};
	// Add length if the line starts with comment
	// Add length - 1 if not, because there is also code on the (first) line
	return (0 
		| it + ((/^\s*\/\/.*$|^\s*\/\*.*$/ 
				:= substring(contents, offset, offset + length))
			 ? n : (n - 1)) 
		| <offset, length, n> <- docLines);
}

// Get a location that starts at the the first column at the line
// specified by the location argument
loc toBeginColumn(loc x)
{
	int bl = x.begin.line;
	int bc = 0;
	int el = x.end.line;
	int ec = x.end.column;
	int offset = x.offset - x.begin.column;
	int length = x.length + x.begin.column;
	return toLocation(x.uri)(offset,length,<bl,bc>,<el,ec>);
}