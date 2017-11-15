module Util

import IO;
import String;
import util::Resources;

// All source code files for a java project
set[loc] javaFiles(loc prj) =
	{f | /file(f) <- getProject(prj), endsWith(f.file, ".java")};

// A list of all lines in the files in the set
list[str] allLines(set[loc] xs) = concat([readFileLines(s) | s <- xs]);

str rank(int i) = ["++", "+", "o", "-", "--"][i];

list[&T] concat(list[list[&T]] xs) = ([] | it + x | x <- xs);