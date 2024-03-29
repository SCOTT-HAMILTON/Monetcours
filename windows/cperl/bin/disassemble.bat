@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#! perl
#line 15
use B::Disassembler qw(disassemble_fh);
use FileHandle;

=pod

=head1 NAME

disassemble

=head1 SYNOPSIS

  disassemble [--bare] [bytecode.plc] > bytecode.asm
  assemble bytecode.asm > bytecode.plc

=head1 DESCRIPTION

Decompiles binary bytecode to readable and recompilable
bytecode assembler.

byteocde is a binary file wih either the magic 4 bytes 'PLBC'
at the start, or something like "#! /usr/bin/perl\n
use ByteLoader '0.07'"

Without the filename uses STDIN.

=head1 OPTION --bare

Without the option --bare the output will be commented.

Note that older assembler, before B::Assembler version 0.07, i.e.
up to perl-5.8.x, will not be able to parse this commented
assembler.

But --bare is only optional, so the default is not backwards
compatible. Rationale: Disassembling is primarily done to make
binary bytecode readable, and not necessarily recompilable with
older assemblers.

=cut

BEGIN {
  if ($B::Disassembler::VERSION > '1.05') {
    B::Disassembler->import('print_insn');
  } else {
    sub print_insn {
      my ($insn, $arg) = @_;
      if (defined($arg)) {
	printf "%s %s\n", $insn, $arg;
      } else {
	print $insn, "\n";
      }
    }
  }
}

my $verbose = '1';
if ($ARGV[0] eq "--bare") {
  shift;
  $verbose = 0;
  *print_insn = *B::Disassembler::print_insn_bare;
}

my $fh;
if (@ARGV == 0) {
  $fh = \*STDIN;
} elsif (@ARGV == 1) {
  $fh = new FileHandle "<$ARGV[0]";
} else {
  die "Usage: disassemble [--bare] [filename]\n";
}

disassemble_fh($fh, \&print_insn, $verbose);


__END__
:endofperl
