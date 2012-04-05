module uzp_main;

import std.stdio;
import std.datetime;
import argv_expand;
import std.parallelism;
import unzip_parallel;

// unzip source zip files to a destination directory
// Demonstrates use of wildArgvs to expand args for windows, similar to unix shell.
// Demonstrates use of uzdParallel to speed up unzip for multicore systems.

int main(string[] argv)
{
	defaultPoolThreads(8);
 
	//string[] argv;
	//argv ~=  "";
	//argv ~=  r"h:\tzip.zip"; // source
	//argv ~=  r"H:\tz\"; //dest
 

 	if (argv.length < 2){
 		writeln ("unzip zip files to a destination folder.");
 		writeln ("Simple wildcard expansion in the basename of source pathnames.");
 		writeln (r"Example:  uzp d:\mySourcedir\*.zip  d:\destDir");
 		return 0;
 	}
	// unzip to current folder by default
	if (argv.length == 2){
		argv ~= ".";
	}
    // the destination pathname. No wildargv expansion
 	string destPath = argv[$-1]; 

	// the source pathnames can be zip format files with any suffix.
	// these can use wildcard expansion in the basename only

	auto sw = StopWatch(AutoStart.yes);

 	foreach(srcPath;  wildArgvs( argv[1..$-1]))
	{
		writeln("unzipping: ", srcPath );
		unzipParallel(srcPath,destPath); 
	}

	writeln("finished! time: ", sw.peek().msecs, " ms");
	return 0;
}
