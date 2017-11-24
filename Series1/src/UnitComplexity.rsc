module UnitComplexity

import lang::java::jdt::m3::AST;
import util::Math;
import Util;
import List;
import Volume;
import IO;

int rankUnitComplexity(map[int,num] relUnitComplexities)
{
	list[tuple[int,num,int]] thresholds =
		[<1,17.9,1>,<2, 9.9,1>,<3, 3.3,1>,
		 <1,23.4,2>,<2,16.9,2>,<3, 6.7,2>,
		 <1,31.3,3>,<2,23.8,3>,<3,10.6,3>,
		 <1,39.1,4>,<2,29.8,4>,<3,16.7,4>];
	return rankThresholds(relUnitComplexities, thresholds);
}

map[int,num] unitComplexities(loc prj, int numCodeLines)
{
	list[int] crs = [6,8,14];
	map[int, num] rs = (0:0, 1:0, 2:0, 3:0);
	for(x <- methodComplexities(prj))
		rs[(0 | x.c > m ? it + 1 : it | m <- crs)] += 
			nCodeLinesFromString(x.l, readFile(x.l));
	for(i <- rs)
		rs[i] = round((100.0 / numCodeLines) * rs[i]);
	return rs;
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