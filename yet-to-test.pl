#!/usr/bin/perl
my $skip = '';
my $writecache=0;
my $suffix="";
my $suffic="";

if ($ARGV[0] eq "svn") {
    $suffix=".svn";
    $suffic="_SVN";
}

if ( -f "pick-one$suffix.cache" ) {
    $writecache=0;
    open(X,"<","pick-one$suffix.cache") || die;
}
else {
    $writecache=1;
    open(X,"find -type d | sort |") || die;
    open(C,">","pick-one$suffix.cache") || die;
}

while (my $path = <X>) {
    chomp $path;
    next unless -d $path;
    next if $path =~ m/\'/;
    next if ($skip ne '' && (substr($path,0,length($skip)) eq $skip));

    # DOSBox-SVN does not support PC-98 games
    next if $path =~ m/^\.\/nec-pc98\// && $suffix eq ".svn";

    # skip if it already has __PASS__ or __FAIL__
    # 2018/02/09: we now require PASS/FAIL to indicate the commit!
    next if (
        ( -f ("$path/__PASS$suffic"."__") && ( -s ("$path/__PASS$suffic"."__")) > 4) ||
        ( -f ("$path/__FAIL$suffic"."__") && ( -s ("$path/__FAIL$suffic"."__")) > 4)
    );

    # skip unless it has an EXE or COM file
    $x=`cd '$path' && ls __BASE__ __base__ 2>/dev/null | head -n 1`; chomp $x;
    next if $x eq "";

    print "$path\n";
    print C "$path\n" if $writecache > 0;

    $skip = $path;
}
close(C) if $writecache > 0;
close(X);

