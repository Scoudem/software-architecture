module Scores

import List;
import IO;
import util::Math;
import Volume;
import UnitSize;
import UnitComplexity;
import Duplication;
import Util;
import CodeLines;
import util::Benchmark;

void demo()
{
	println("Time:            " + toString(round(benchmark(("f" : void() 
		{ppScores(|project://smallsql0.21_src|);}))["f"] / 1000)) + "s");
	println("Time:            " + toString(round(benchmark(("f" : void() 
		{ppScores(|project://hsqldb-2.3.1|);    }))["f"] / 1000)) + "s");
}

alias Metrics = tuple[list[str] codeLines, int numCodeLines, map[int,num] relUnitSizes,
	map[int,int] relUnitComplexities, int numDuplicates, int rankUnitSize,
	int rankUnitComplexity, int rankDuplication, int rankMaintainability,
	int rankAnalysability, int rankChangeability, int rankTestability];

Metrics emptyMetrics = <[], 0, (), (), 0, 0, 0, 0, 0, 0, 0, 0>;

Metrics metrics(loc prj)
{
	Metrics result = emptyMetrics;
	result.codeLines = getCodeLines(prj);
	result.numCodeLines = size(result.codeLines);
	result.relUnitSizes = unitSizes(prj, result.numCodeLines);
	result.relUnitComplexities = unitComplexities(prj, result.numCodeLines);
	result.numDuplicates = countDuplicates(result.codeLines);
	result.rankDuplication = rankDuplication(result.numCodeLines, result.numDuplicates);
	result.rankUnitSize = rankUnitSize(result.relUnitSizes);
	result.rankUnitComplexity = rankUnitComplexity(result.relUnitComplexities);
	result.rankAnalysability = average([rankVolume(result.numCodeLines), result.rankDuplication, result.rankUnitSize]);
	result.rankChangeability = average([result.rankUnitComplexity, result.rankDuplication]);
	result.rankTestability = average([result.rankUnitComplexity, result.rankUnitSize]);
	result.rankMaintainability = average([result.rankAnalysability, result.rankChangeability, result.rankTestability]);
	return result;
}

void ppScores(loc prj)
{
	Metrics m = metrics(prj);
	println("Maintainability: " + rank(m.rankMaintainability));
	println("Analysability:   " + rank(m.rankAnalysability));
	println("Changeability:   " + rank(m.rankChangeability));
	println("Testability:     " + rank(m.rankTestability));
	println("Code lines:      " + toString(m.numCodeLines));
	println("Unit complexity: " + rank(m.rankUnitComplexity));
	println("Unit complexities:");
	ppRelMap(m.relUnitComplexities);
	println("Unit size:       " + rank(m.rankUnitSize));
	println("Unit sizes:");
	ppRelMap(m.relUnitSizes);
	println("Duplication:     " + rank(m.rankDuplication));
	println("Duplicate lines: " + toString(m.numDuplicates));
	println("Duplication %:   " + toString(round(100.0 / m.numCodeLines * m.numDuplicates)) + "%");
}

void ppRelMap(map[int, num] relNums)
{
	println("\tLow risk:       " + toString(relNums[0]) + "%");
	println("\tModerate risk:  " + toString(relNums[1]) + "%");
	println("\tHigh risk:      " + toString(relNums[2]) + "%");
	println("\tVery high risk: " + toString(relNums[3]) + "%");
}

int average(list[int] xs) = toInt(round(toReal(sum(xs)) / size(xs)));