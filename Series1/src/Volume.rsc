module Volume

import IO;
import List;
import String;
import util::Resources;
import lang::java::jdt::m3::Core;

// All source code lines that are not blank 
// (only contain whitespace) or comment lines
int codeLines(loc prj)
{
	lines   = allLines(javaFiles(prj));
	total   = totalLines(lines);
	empty   = emptyLines(lines);
	comment = commentLines(prj);
	code    = total - empty - comment;
	return code;
}

// All source code files for a java project
set[loc] javaFiles(loc prj)
{
	Resource p = getProject(prj);
	return {f | /file(f) <- p, endsWith(f.file, ".java")};
}

// A list of all lines in the files in the set
list[str] allLines(set[loc] xs) 
{
	return concat([readFileLines(s) | s <- xs]);
}

list[str] nonEmptyLines(list[str] lines)
{
	return [x | x <- lines, /^\s*$/ !:= x];
}

int emptyLines(list[str] lines)
{	
	int total    = totalLines(lines);
	int nonEmpty = size(nonEmptyLines(lines));
	return (total - nonEmpty);
}

int commentLines(loc prj)
{
	doc = createM3FromEclipseProject(prj).documentation;
	docLines = {<x,
				 y.begin.line,
				 y.end.line - y.begin.line + 1> 
				| <x, y> <- doc};
	cLines = [n | <f, x, n> <- docLines, 
		/^\s*\/\/.*$|^\s*\/\*.*$/ := getFileLine(f, x)];
	return (0 | it + x | x <- cLines);
}

int totalLines(list[str] lines)
{	
	return size(lines);
}

// Returns specified line from file (first line is 1)
str getFileLine(loc file, int line)
{
	return top(drop(line - 1, readFileLines(file)));
}

list[&T] concat(list[list[&T]] xs)
{
	return ([]
		| it + x
		| x <- xs);
}