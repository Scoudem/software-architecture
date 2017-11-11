module Util

import IO;
import String;
import util::Resources;

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

str rank(int i)
{
	return ["++", "+", "o", "-", "--"][i];
}

list[&T] concat(list[list[&T]] xs)
{
	return ([]
		| it + x
		| x <- xs);
}