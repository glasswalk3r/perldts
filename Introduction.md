# Getting your feets wet #

Although it's possible to use all features here by using only [Win32::OLE](http://search.cpan.org/search?query=Win32::OLE) module, PerlDTS (being more specific, it's childs classes) provides a much easier interface (pure Perl) and (hopefully) a better documentation. Since it's build over [Win32::OLE](http://search.cpan.org/search?query=Win32::OLE) module, PerlDTS will only work with ActivePerl distribution running in a Microsoft Windows operational system.

The API for this class will give only read access to a package attributes. No write methods are available are directly available at this time, but could be executed since at each PerlDTS object created a related object is passed as an reference to new object. This related object is a MS SQL Server DTS object and has all methods and properties as defined by the MS API. This object reference is kept as an "private" property called `sibling` and generally can be obtained with a `get_sibling` method call. Once the reference is recovered, all methods from it are available.

## Why having all this trouble? ##

You may be asking yourself why having all this trouble to write such API as an layer to access data thought [Win32::OLE](http://search.cpan.org/search?query=Win32::OLE) module.

The very simple reason is: MS SQL Server 2000 API is terrible to work with (lots and lots of indirection), the documentation is not as good as it should be and one has to convert examples from it of VBScript code to Perl.

PerlDTS API was created to provide an easier (and more "perlish") way to fetch data from a DTS package. One can use this API to easily create reports or implement automatic tests using a module as [Test::More](http://search.cpan.org/author/MSCHWERN/Test-Simple-0.80/lib/Test/More.pm) (see EXAMPLES directory in the tarball distribution of this module).

# Perldoc #

[Here](http://search.cpan.org/search?query=DTS+Alceu&mode=all) is all modules documentation generated automatically in HTML from the POD text.

# UML Diagrams #

PerlDTS tries to follows the same classes implemented by MS DTS API, but there are some differences. You should check those diagrams for an overview of how the classes were implemented in Perl. Here is the list of diagrams:

  * [All classes diagram (overview)](http://code.google.com/p/perldts/wiki/UMLOverview)
  * [Assignment classes diagram](http://code.google.com/p/perldts/wiki/UMLOverview)
  * [Assignment Destination classes diagram](http://code.google.com/p/perldts/wiki/AssignmentDestination)
  * [Tasks classes diagram](http://code.google.com/p/perldts/wiki/Tasks)

All of them were created using Visual Paradigm UML tool for comunity. If you would like to have the sources, let me know by email.

# Project status #

PerlDTS should be considered beta, but the code is stable enough for testing DTS packages that are already done. Development is not being as active as I would like, meanly because MS SQL Server 2000 is not so popular those days and I'm not actively involved with it anymore.

Anyway, I can reply e-mails and accept patches as fast as I can. Bug reports and suggestions are quite welcome too.

# Download #

You can download the PerlDTS distribuition tarball directly from CPAN in [http://search.cpan.org/~arfreitas](http://search.cpan.org/~arfreitas). There is a PPM package available for ActivePerl users in the [Downloads](http://code.google.com/p/perldts/downloads/list) section of this project.

# Install #

PerlDTS setup should be easier for average Perl developer. An important notice is that PerlDTS distribuition will work **only** in computador with an operational system from Microsoft and with the MS SQL Server client installed. PerlDTS distribution relies heavily in SQL Server DTS API and [Win32::OLE](http://search.cpan.org/search?query=Win32::OLE) module to provide COM interface to the DTS API.

Additional information about [install is here](Install.md).

# License #

Copyright (C) 2006 by Alceu Rodrigues de Freitas Junior

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may have available.


---


[![](http://nau.sourceforge.net/sm_perl.gif)](http://www.perl.com/)