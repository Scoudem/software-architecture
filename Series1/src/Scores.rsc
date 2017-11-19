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
	println(benchmark(("smallsql" : void() {ppScores(|project://smallsql0.21_src|, duplication = true);})));
	println(benchmark(("hsqldb" : void() {ppScores(|project://hsqldb-2.3.1|);})));
}

void ppScores(loc prj, bool duplication = false)
{
	cls = codeLines(prj);
	nCl = size(cls);
	rD = duplication ? rankDuplication(nCl, cls) : 2;
	rU = rankUnitSize(prj, nCl);
	rC = rankUnitComplexity(prj, nCl);
	an = average(duplication ? [rankVolume(nCl), rD, rU] : [rankVolume(nCl), rU]);
	ch = duplication ? average([rC, rD]) : rC;
	te = average([rC, rU]);
	ma = average([an, ch, te]);
	println("Maintainability: " + rank(ma));
	println("Analysability:   " + rank(an));
	println("Changeability:   " + rank(ch));
	println("Testability:     " + rank(te));
	println("Code lines:      " + toString(nCl));
	println("Unit complexity: " + rank(rC));
	println("Unit size:       " + rank(rU));
	println("Duplication:     " + (duplication ? rank(rD) : "Not ranked"));
}

int maintainability(loc prj, int nCl, list[str] cls) = average([
	analysability(prj, nCl, cls),
	changeability(prj, nCl, cls),
	testability(prj, nCl)]);

int analysability(loc prj, int nCl, list[str] cls) = average([
	rankVolume(nCl),
	rankDuplication(nCl, cls),
	rankUnitSize(prj, nCl)]);

int changeability(loc prj, int nCl, list[str] cls) = average([
	rankUnitComplexity(prj, nCl),
	rankDuplication(nCl, cls)]);

int testability(loc prj, int nCl) = average([
	rankUnitComplexity(prj, nCl),
	rankUnitSize(prj, nCl)]);

int average(list[int] xs) = toInt(round(toReal(sum(xs)) / size(xs)));