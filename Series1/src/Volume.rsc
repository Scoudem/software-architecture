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

// Lines that are not just whitespace
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

int totalLines(list[str] lines)
{	
	return size(lines);
}

list[&T] concat(list[list[&T]] xs)
{
	return ([]
		| it + x
		| x <- xs);
}