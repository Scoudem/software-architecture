module Duplication

import IO;
import List;
import String;
import util::Math;

int rankDuplication(int nCl, list[str] cls)
{
	nDs = (0 | it + d | <_,_,d> <- duplicates(cls));
	list[int] thresholds = [3,5,10,20];
	int p = toInt(round(100.0 / nCl * nDs));
	int r = (0
			| p > x ? it + 1 : it
			| x <- thresholds);
	return r;
}

int simpleHash(str s) = (<1,0> | <it[0] + 1, it[1] + toInt(pow(c, it[0]))> | c <- chars(s))[1];

list[tuple[int,int,int]] duplicates(list[str] cls)
{
	result = [];
	for(i <- [0..size(cls)])
	{
		if(i+6 < size(cls))
		{
			for(j <- [i+6..size(cls)])
			{
				int d = 0;
				while(d < j - i && j+d < size(cls) && cls[i+d] == cls[j+d])
				{
					a = cls[i+d];
					b = cls[j+d];
					d += 1;
				}
				if(d >= 6 && d < j - i) result += <i,j,d>;
			}
			//println(100.0 / size(cls) * i);
		}
	}
	return result;
}
