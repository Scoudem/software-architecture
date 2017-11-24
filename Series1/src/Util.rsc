module Util

import IO;
import String;
import util::Resources;
import lang::xml::DOM;

set[loc] srcFolders(loc prj) = {prj + path |
	/element(_,"classpathentry",[attribute(_,"path",path),attribute(_,"kind","src")])
		<- parseXMLDOMTrim(readFile(find(".classpath", [prj])))};

set[loc] srcFiles(loc prj)
{
	set[loc] srcDirs = srcFolders(prj);
	return {f | /file(f) <- [contents | /folder(dir, contents) <- getProject(prj), dir in srcDirs], endsWith(f.file, ".java")};
}

str rank(int i) = ["++", "+", "o", "-", "--"][i];

int rankThresholds(int val, list[int] thresholds) =
	(0 | val > t ? it + 1 : it | t <- thresholds);

int rankThresholds(map[int,num] relVals, list[tuple[int,num,int]] thresholds) = 
	(0 | (relVals[a] > b ? relVals[a] > it) ? c : it | <a,b,c> <- thresholds);

list[&T] concat(list[list[&T]] xs) = ([] | it + x | x <- xs);