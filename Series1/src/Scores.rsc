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
	println(benchmark(("smallsql" : void() {ppScores(|project://smallsql0.21_src|);})));
	println(benchmark(("hsqldb" : void() {ppScores(|project://hsqldb-2.3.1|);})));
}

void ppScores(loc prj, bool duplication = true)
{
	cls = codeLines(prj);
	nCl = size(cls);
	rus = unitSizes(prj, nCl);
	ruc = unitComplexities(prj, nCl);
	nDl = duplication ? countDuplicates(cls) : 0;
	rD = duplication ? rankDuplication(nCl, nDl) : 2;
	rU = rankUnitSize(rus);
	rC = rankUnitComplexity(ruc);
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
	println("Unit complexities:");
	iprintln(ruc);
	println("Unit size:       " + rank(rU));
	println("Unit sizes:");
	iprintln(rus);
	println("Duplication:     " + (duplication ? rank(rD) : "Not ranked"));
	println("Duplicate lines: " + (duplication ? toString(nDl) : "Not ranked"));
	println("Duplication %:   " + (duplication ? toString(round(100.0 / nCl * nDl)) : "Not ranked"));
}

int maintainability(loc prj, int nCl, list[str] cls, map[int,int] ruc, map[int,num] rus) = average([
	analysability(prj, nCl, cls, rus),
	changeability(prj, nCl, cls, ruc),
	testability(prj, nCl, ruc, rus)]);

int analysability(loc prj, int nCl, list[str] cls, map[int,num] rs) = average([
	rankVolume(nCl),
	rankDuplication(nCl, cls),
	rankUnitSize(rs)]);

int changeability(loc prj, int nCl, list[str] cls, map[int,int] ruc) = average([
	rankUnitComplexity(ruc),
	rankDuplication(nCl, cls)]);

int testability(loc prj, int nCl, map[int,int] ruc, map[int,num] rus) = average([
	rankUnitComplexity(ruc),
	rankUnitSize(rus)]);

int average(list[int] xs) = toInt(round(toReal(sum(xs)) / size(xs)));