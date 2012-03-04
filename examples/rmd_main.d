module rmd_main;

import std.stdio;
import std.datetime;
import rmdir_parallel;
import argv_expand;

// This demonstrates use of wildArgvs to expand the args
// and the use of the parallel remove to speed up remove of files and directories.
// The args can be any list of files or folders. 
// They will be removed.

int main(string[] argv)
{
	if (argv.length < 2){
		writeln ("Removes files or directories.");
		writeln ("Wildcard expansion is provided for the basename.");
		writeln ("Example: rmd d:\\mydir\\*.bat  d:\\mydir\\*.asm d:\\mydir\\tempdir");
		return 0;
	}

	auto sw = StopWatch(AutoStart.yes);
	foreach( dir; wildArgvs(argv[1..$])){
		writeln("removing: "~ dir );
		rmdirParallel(dir); 
	}
	writeln("finished! time:", sw.peek().msecs, " ms");
	return 0;
}
