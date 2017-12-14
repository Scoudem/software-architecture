module CloneDetector

import IO;
import Map;
import List;
import Set;
import String;
import lang::java::jdt::m3::Core;
import lang::xml::DOM;
import util::Benchmark;
import util::Math;
import util::Resources;
import util::ValueUI;

void v2()
{
	//prj = |project://HelloWorld|;
	prj = |project://smallsql0.21_src|;
	//prj = |project://hsqldb-2.3.1|;
	
	println(benchmark(("f" : void() {
	
	cl = getCodeLines(prj, srcFiles(prj));
	numCl = numCodeLines(cl);

	clsp6 = groupPerSixLines(cl);
	clsp6id = addGroupIds(clsp6);
	groups = cloneGroups(clsp6id);
	result = merge(groups);
	writeCloneGroups(result);
	writeCloneGroupsJSON(result);
	//print(calcStatistics(result, numCl));

	}))["f"] / 1000);
}

str calcStatistics(list[tuple[str,loc,list[int]]] clones, int nCodeLines)
{
	int count = 0, dupLines = 0, cClones = size(clones), cClasses = 0;
	tuple[str,loc,list[int],int] biggestClone = <"",|unknown:///|,[],0>;
	tuple[str,int] biggestClass = <"",0>;
	map[str,int] classSizes = ();
	map[str,int] ids = ();
	for(<str i, loc f, list[int] ls> <- clones)
	{
		int curSize = size(ls);
		dupLines += curSize;
		if(i notin ids)
		{
			ids[i] = count;
			count += 1;
			cClasses += 1;
			classSizes[i] = 0;
		}
		if(curSize > biggestClone<3>)
			biggestClone = <i, f, ls, curSize>;
		classSizes[i] += curSize;
		if(classSizes[i] > biggestClass<1>)
			biggestClass = <i, classSizes[i]>;
	}
	int pDuplication = toInt(round(100.0 / nCodeLines * dupLines));
	str result = "";
	result += "% Duplicates lines:     " + toString(pDuplication) + "\n";
	result += "Number of clones:       " + toString(count) + "\n";
	result += "Biggest clone size:     " + toString(biggestClone<3>) + "\n";
	result += "Biggest clone location: " + biggestClone<1>.uri + " at line " + toString(top(biggestClone<2>)) + "\n";
	result += "Biggest class size:     " + toString(biggestClass<1>) + " (see " + toString(ids[biggestClass<0>]) + ".txt for details)\n";
	return result;
}

void writeCloneGroups(list[tuple[str,loc,list[int]]] clones)
{
	cloneDir = toLocation("home:///clones");
	map[int, str] result = ();
	int count = 0;
	map[str,int] ids = ();
	for(<str i, loc f, list[int] ls> <- clones)
	{
		if(i notin ids)
		{
			ids[i] = count;
			count += 1;
		}
		txtFile = cloneDir + (toString(ids[i]) + ".txt");
		if(!exists(txtFile)) writeFile(txtFile, "");
		appendToFile(txtFile, f.file + ":\n" + readFileLines1(f, ls) + "\n");
	}
}

void writeCloneGroupsJSON(list[tuple[str,loc,list[int]]] clones)
{
	jsonFile = toLocation("home:///clones/visualization.json");
	writeFile(jsonFile, "[\n");
	map[int,map[loc,list[tuple[int,int]]]] result = ();
	int count = 0;
	map[str,int] ids = ();
	for(<str i, loc f, list[int] ls> <- clones)
	{
		if(i notin ids)
		{
			ids[i] = count;
			count += 1;
			result[ids[i]] = ();
		}
		if(f notin result[ids[i]])
			result[ids[i]] += (f:[]);
		result[ids[i]][f] += <top(ls),last(ls)>;
	}
	list[str] cs = [];
	for(i <- result)
	{
		str c = "{\"class\": " + toString(i) + ",\n\"files\": [\n";
		list[str] fs = [];
		for(f <- result[i])
		{
			str fent = "{\"file\": \"" + location(f).path + "\",\n\"entries\": [\n";
			list[str] ents = [];
			for(<bl, el> <- result[i][f])
			{
				ents += "{\n"
					+ "\"beginline\": " + toString(bl) + ",\n"
					+ "\"endline\": " + toString(el) + ",\n"
					+ "\"content\": [\""+ intercalate("\",\"", mapper(readFileLines(f)[bl..(el+1)], trim)) +"\"]\n"
					+ "}";
			}
			fent += intercalate(",\n", ents);
			fent += "\n]}";
			fs += fent;
		}
		c += intercalate(",\n", fs);
		c += "]}";
		cs += c;
	}
	appendToFile(jsonFile, intercalate(",\n", cs));
	appendToFile(jsonFile, "]\n");
}

str readFileLines1(loc f, list[int] ls)
{
	fls = readFileLines(f);
	return ("" | it + fls[i] + "\n" | i <- ls);
}

list[tuple[str,loc,list[int]]] getClonesFromProject(loc prj) = merge(cloneGroups(addGroupIds(groupPerSixLines(getCodeLines(prj, srcFiles(prj))))));

int numCodeLines(lrel[list[tuple[str,int]], loc] codeLines) = (0 | it + size(cl[0]) | cl <- codeLines);

lrel[list[tuple[str,int]], loc] getCodeLines(loc prj, set[loc] srcFiles)
{
	rel[loc,loc] m3Doc = createM3FromEclipseProject(prj).documentation;
	ls = [<withoutComments(f, m3Doc), f> | f <- srcFiles];
	ls2 = [<removeEmptyLinesNumberAndTrim(lls<0>), lls<1>> | lls <- ls];
	return ls2;
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

list[tuple[str,int]] removeEmptyLinesNumberAndTrim(list[str] ls)
{
	return for(i <- [0..size(ls)])
	{
		x = ls[i];
		if(/^\s*$/ !:= x)
			append <trim(x),i>;
	}
}

bool offsetMoreThan(loc a, loc b) = a.offset > b.offset;

set[loc] srcFolders(loc prj) = {prj + path |
	/element(_,"classpathentry",[attribute(_,"path",path),attribute(_,"kind","src")])
		<- parseXMLDOMTrim(readFile(find(".classpath", [prj])))};

set[loc] srcFiles(loc prj)
{
	set[loc] srcDirs = srcFolders(prj);
	return {f | /file(f) <- [contents | /folder(dir, contents) <- getProject(prj), dir in srcDirs], endsWith(f.file, ".java")};
}

set[tuple[str,loc,list[int]]] groupPerSixLines(lrel[list[tuple[str,int]], loc] codeLines)
{
	result = {};
	for(<cl, f> <- codeLines)
		for(i <- [0..max(0, size(cl) - 5)])
		{
			code = "";
			lns = [];
			for(j <- [i..i+6])
			{
				code += cl[j]<0> + "\n";
				lns += cl[j]<1>;
			}
			result += <code, f, lns>;
		}
	return result; 
}

set[tuple[str,loc,list[int]]] cloneGroups(set[tuple[str,loc,list[int]]] clsp6id)
{
	result = {};
	map[str, tuple[str,loc,list[int]]] seen = ();
	for(cur: <str id, loc f, list[int] ls> <- clsp6id)
		if(id in seen)
		{
			result += seen[id];
			result += cur;
		}
		else
			seen[id] = cur;
	return result;
}

int getId(tuple[int,loc,list[int]] x) = x<0>;

set[tuple[str,loc,list[int]]] addGroupIds(set[tuple[str,loc,list[int]]] clsp6) = 
	{ <badHash(cl), f, ls> | <cl,f,ls> <- clsp6 };

bool offsetMoreThan(loc a, loc b) = a.offset > b.offset;

bool fileThenLineLessThan(tuple[str,loc,list[int]] a, tuple[str,loc,list[int]] b) 
{
	if(a<1>.file == b<1>.file)
		if(top(a<2>) < top(b<2>))
			return true;
	if(a<1>.file < b<1>.file)
		return true;
	return false;
}

list[tuple[str,loc,list[int]]] merge(set[tuple[str,loc,list[int]]] clsp6id)
{
	list[tuple[str,loc,list[int]]] clsp6srt = sort(clsp6id, fileThenLineLessThan);
	result = [];
	map[str,str] mergedGroupIds = ();
	tuple[str,loc,list[int]] prev = <"",|unknown:///|,[]>;
	int pos = -1;
	for(<str id, loc f, list[int] ls> <- clsp6srt)
	{
		if(id in mergedGroupIds)
			id = mergedGroupIds[id];
		cur = <"",|unknown:///|,[]>;
		if(prev<1> == f && last(prev<2>) >= top(ls))
		{
			cur = <prev<0>, f, dup(prev<2> + ls)>;
			result[pos] = cur;
			mergedGroupIds += (id : prev<0>);
		}
		else
		{
			cur = <id, f, ls>;
			result += cur;
			pos += 1;
		}
		prev = cur;
	}
	return result;
}

str badHash(str cl) = cl;