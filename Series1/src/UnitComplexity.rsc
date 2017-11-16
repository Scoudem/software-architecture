module UnitComplexity

import lang::java::jdt::m3::AST;
import util::Math;
import Util;
import List;
import Volume;
import IO;

int rankUnitComplexity(loc prj)
{
	list[int] crs = [10,20,50];
	// Aggregated unit complexities
	map[int, int] rs = (0:0, 1:0, 2:0, 3:0);
	for(x <- methodComplexities(prj))
		rs[(0 | x.c > m ? it + 1 : it | m <- crs)] += 
			codeLinesFromString(x.l, readFile(x.l));
	// To percentages
	int n = codeLines(prj);
	for(i <- rs)
		rs[i] = toInt(round((100.0 / n) * rs[i]));
	return determineRank(rs);
}

int determineRank(map[int,int] xs)
{
	lrel[int,int,int] thresholds = 
		[<1,25,1>,<2, 0,1>,<3,0,1>,
		 <1,30,2>,<2, 5,2>,<3,0,2>,
		 <1,40,3>,<2,10,3>,<3,0,3>,
		 <1,50,4>,<2,15,4>,<3,5,4>];
	return (0 | (xs[a] > b ? xs[a] > it) ? c : it 
			| <a,b,c> <- thresholds);
}

list[tuple[int c,loc l]] methodComplexities(loc prj)
{
	list[Statement] ms = [];
	for(m : /method(_,_,_,_, Statement x) 
			<- createAstsFromEclipseProject(prj, false))
		ms += x;
	return [<calcCC(m), m.src> | m <- ms];
}

int calcCC(Statement impl) = (1 | it + incCC(x) | /x <- impl);

int incCC(conditional(_,_,_)) = 1;
int incCC(infix(_,"&&",_))    = 1;
int incCC(infix(_,"||",_))    = 1;
int incCC(do(_,_))            = 1;
int incCC(foreach(_,_,_))     = 1;
int incCC(\for(_,_,_,_))      = 1;
int incCC(\for(_,_,_))        = 1;
int incCC(\if(_,_))           = 1;
int incCC(\if(_,_,_))         = 1;
int incCC(\case(_))           = 1;
int incCC(\catch(_,_))        = 1;
int incCC(\while(_,_))        = 1;
default int incCC(value _)    = 0;