module UnitSize

import IO;
import List;
import util::Math;
import Volume;
import Util;

import lang::java::jdt::m3::Core;

str rankUnitSize(loc prj)
{
	str lng = "java";
	map[str,list[int]] mloc = ("java" : [30,44,74]);
	// Aggregated unit sizes
	map[int, num] rs = (0:0, 1:0, 2:0, 3:0);
	for(x <- methodCodeLines(prj))
		rs[(0 | x > m ? it + 1 : it | m <- mloc[lng])] += x;
	// To percentages
	// Note that codeLines count all code lines and not just methods,
	// thus the percentages do not add up to 100
	int n = codeLines(prj);
	for(i <- rs)
		rs[i] = round((100.0 / n) * rs[i]);
	return rank(determineRank(rs));
}

int determineRank(map[int,num] xs)
{
	lrel[int,num,int] thresholds = 
		[<1,19.5,1>,<2,10.9,1>,<3,3.9,1>,
		 <1,26.0,2>,<2,15.5,2>,<3,6.5,2>,
		 <1,34.1,3>,<2,22.2,3>,<3,11.0,3>,
		 <1,45.9,4>,<2,31.4,4>,<3,18.1,4>];
	return (0 | (xs[a] > b ? xs[a] > it) ? c : it 
			| <a,b,c> <- thresholds);
}

// List of method sizes (LOC)
list[int] methodCodeLines(loc prj)
{
	ms = methods(createM3FromEclipseProject(prj));	
	return [codeLinesFromString(prj, readFile(m)) | m <- ms];
}