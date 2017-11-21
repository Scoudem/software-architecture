module Duplication

import IO;
import List;
import Set;
import String;
import util::Math;
import Util;

int rankDuplication(int numCodeLines, int numDuplicates)
{
	list[int] thresholds = [3,5,10,20];
	int p = toInt(round(100.0 / numCodeLines * numDuplicates));
	return rankThresholds(p, thresholds);
}

list[tuple[int,str]] groupPerSixLines(lrel[list[str], loc] codeLines)
{
	result = [];
	lineCount = 0;
	for(<cl, _> <- codeLines)
	{
		for(i <- [0..max(0, size(cl) - 5)])
			result += <lineCount + i, ("" | it + cl[j] + "\n" | j <- [i..i+6])>;
		lineCount += size(cl);
	}
	return result; 
}

int countDuplicates(lrel[list[str], loc] cls)
{
	clsp6 = groupPerSixLines(cls);
	seenCode = {};
	seenCodeLines = ();
	set[int] duplicateLines = {};
	for(<i, c> <- clsp6)
	{
		if(c in seenCode)
		{
			duplicateLines += i;
			if(c in seenCodeLines)
			{
				duplicateLines += seenCodeLines[c];
				seenCodeLines -= (c:0);
			}
		}
		else
		{
			seenCode += c;
			seenCodeLines += (c:i);
		}
	}
	return (<0, 0> | <i, it[1] + ((i >= it[0] + 6) ? 6 : (i - it[0]))> | i <- sort(duplicateLines))[1];
}