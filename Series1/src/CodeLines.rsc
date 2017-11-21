module CodeLines

import IO;
import List;
import String;
import lang::java::jdt::m3::Core;
import Util;

int numCodeLines(lrel[list[str], loc] codeLines) = (0 | it + size(cl[0]) | cl <- codeLines);

lrel[list[str], loc] getCodeLines(loc prj, set[loc] srcFiles)
{
	rel[loc,loc] m3Doc = createM3FromEclipseProject(prj).documentation;
	ls = [<withoutComments(f, m3Doc), f> | f <- srcFiles];
	ls = [<removeEmptyLines(lls<0>), lls<1>> | lls <- ls];
	ls = [<mapper(lls<0>, trim), lls<1>> | lls <- ls];
	return ls;
}

list[str] withoutComments(loc f, rel[loc,loc] m3Doc)
{
	list[loc] doc = sort([x | <_, x> <- m3Doc, x.uri == f.uri], offsetMoreThan);
	return removeComments(doc, readFileLines(f));
}

list[str] removeComments(list[loc] doc, list[str] lines)
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
			for(j <- [e-1..b]) lines[j] = "";
			lines[b] = lines[b][0..bc];
		}
	}
	return lines;
}

list[str] removeEmptyLines(list[str] ls) = [x | x <- ls, /^\s*$/ !:= x];

bool offsetMoreThan(loc a, loc b) = a.offset > b.offset;