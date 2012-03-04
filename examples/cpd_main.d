module cpd_main;

import std.stdio;
import std.datetime;
import argv_expand;
import copy_parallel;

// copy source folders and directories to a destination directory
// Demonstrates use of wildArgvs to expand args for windows, similar to unix shell.
// Demonstrates use of copyParallel to speed up copies for multicore systems.

int main(string[] argv)
{
 	if (argv.length < 3){
 		writeln ("Copy source files or folders to a destination folder.");
 		writeln ("Simple wildcard expansion in the basename of source pathnames.");
 		writeln ("Example:  cpd d:\\mySourcedir\\*.sln d:\\mySourcedir\\subdir d:\\destDir");
 		return 0;
 	}
    // the destination pathname. No wildargv expansion
 	string destPath = argv[$-1]; 

	// the source pathnames. can be folders or files or links
	// these can use wildcard expansion in the basename only

	auto sw = StopWatch(AutoStart.yes);

 	foreach(srcPath;  wildArgvs( argv[1..$-1]))
	{
		writeln("copying: ", srcPath );
		copyParallel(srcPath,destPath); 
	}

	writeln("finished! time: ", sw.peek().msecs, " ms");
	return 0;
}
