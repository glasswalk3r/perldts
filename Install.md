# Introduction #

DTS distribution can be downloaded in two forms: a PPM package and the source tarball. The PPM package **is not** available from ActivePerl repository or any other that I know.

Setup is different from those methods. The only common requirements are:

  1. operation system: must be one offered by Microsoft that supports the MS SQL Server 2000 client setup
  1. MS SQL Server 2000 must be available
  1. ActivePerl 5.8

## Installing from a PPM package ##

The most recent PPM package can be found in the [Downloads](http://code.google.com/p/perldts/downloads/list) section. The package contains several files grouped and compacted in a ZIP format. The zipped file will contain:

  * a PPD file (DTS.ppd).
  * a tarball with the already "built" files from the distribution.

To install it, you will need to unzip the file and process the PPD file with the `ppm` utility from ActivePerl. The example below shows how to install the package:

`ppm install DTS.ppd`

The tarball must be available in the same directory where the DTS.ppd is located.

The advantage of using the PPM package is the ease to setup the distribution and the proper documentation. The disadvantage is that you will not be able to run the automated tests (the simple tests or the advance ones).

## Installing from the tarball ##

You can fetch the most recent tarball from the [CPAN](http://search.cpan.org). The install from downloading directly the tarball or using the CPAN shell is well documented in the ActivePerl documentation (see "Getting stared", "Using PPM").

The advantage of using this method is that you have access to the testing while running the "make" utility, even running extended tests. The disadvantage is that this method is more complex and will require other tools, like the make utility.

### Extended tests ###

Extended tests are available only for the tarball method. After executing `perl Makefile.PL`, there will be a dialog asking for executing or not the extended tests. If you reply "yes", the tests will try to connect to a SQL Server and fetch values from a DTS package called 'test-all.dts'. So you will need to:

  1. save the test-all.dts package into an SQL Server
  1. edit the XML file test-conf.xml with all connections details to the SQL Server

Once this is done, you can execute `nmake test` (supposing that you're using Microsoft's make utility) and see all methods from the DTS classes being tested. That's a lot of testing and you will want to see this done only if you're developing new features or changing the distribution code.