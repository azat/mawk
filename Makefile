
# ###################################################
# This is a makefile for mawk,
# an implementation of The AWK Programming Language, 1988.
# 
# 

SHELL=/bin/sh

####################################
# user settable macros
#

CC = cc
#CC = gcc 

RANLIB = ranlib
#RANLIB = :  # SCO

MAKE = make

CFLAGS =   -O
#CFLAGS = -O -YSYSTEM_FIVE # ultrix_vax 4.1 
                           # (don't use -YSYSTEM_FIVE on MIPS)
#CFLAGS = -O -YSYSTEM_FIVE -DHAVE_VOID_PTR=0 #ultrix 3.1
#CFLAGS = -O -f68881  # sun3 with coprocessor

# use your favorite yacc
# if you don't change parse.y or parse2.xc
# then you can use the parse.c and parse.h provided and don't need yacc
# The parse.c and parse.h in the distribution were made with
# Berkeley yacc
#
#YACC=yacc -d
YACC=byacc -d
FIX_YTAB=cat    #  makes parse.c from y.tab.c and parse2.xc

# using bison -- remove call to alloca()
#YACC=bison -dy
#FIX_YTAB=fix_ytab   # uncomment this with bison 1.14
#                      read comments in fix_ytab script
#	               if you use an earlier version of bison

#installation macros
BINDIR=/usr/local/bin
MANDIR=/usr/man/manl
MANEXT=l
#######################################

O=parse.o scan.o memory.o main.o hash.o execute.o code.o\
  da.o error.o init.o bi_vars.o cast.o print.o bi_funct.o\
  kw.o jmp.o array.o field.o  split.o re_cmpl.o zmalloc.o\
  fin.o files.o  scancode.o matherr.o  fcall.o version.o

REXP_C=rexp/rexp.c rexp/rexp0.c rexp/rexp1.c rexp/rexp2.c\
    rexp/rexp3.c rexp/rexpdb.c


mawk_and_test :  mawk  mawk_test  fpe_test

mawk : $(O)  rexp/regexp.a
	$(CC) $(CFLAGS) -o mawk $(O) -lm rexp/regexp.a

mawk_test :  mawk  # test that we have a sane mawk
	@cp mawk test/mawk
	cd test ; ./mawk_test 
	@rm test/mawk

fpe_test :  mawk # test FPEs are handled OK
	@cp mawk test/mawk
	@echo ; echo testing floating point exception handling
	cd test ; ./fpe_test
	@rm test/mawk

rexp/regexp.a :  $(REXP_C)
	cd  rexp ; $(MAKE) CC="$(CC)" RANLIB=$(RANLIB)


parse.c  : parse.y  parse2.xc
	@echo  expect 4 shift/reduce conflicts
	$(YACC)  parse.y
	$(FIX_YTAB) y.tab.c parse2.xc > parse.c && rm y.tab.c
	-if cmp -s y.tab.h parse.h ;\
	   then rm y.tab.h ;\
	   else mv y.tab.h parse.h ; fi

scancode.c :  makescan.c  scan.h
	$(CC) -o makescan.exe  makescan.c
	./makescan.exe > scancode.c
	rm makescan.exe

install :  mawk
	install -s mawk $(BINDIR)
	install -c man/mawk.1 $(MANDIR)/mawk.$(MANEXT)

clean :
	rm -f *.o rexp/*.o rexp/regexp.a test/mawk core test/core



# output from  mawk -f deps.awk *.c
array.o : bi_vars.h sizes.h zmalloc.h memory.h types.h field.h mawk.h config.h symtype.h config/Idefault.h
bi_funct.o : fin.h bi_vars.h sizes.h memory.h zmalloc.h regexp.h types.h field.h repl.h files.h bi_funct.h mawk.h config.h symtype.h init.h config/Idefault.h
bi_vars.o : bi_vars.h sizes.h memory.h zmalloc.h types.h field.h mawk.h config.h symtype.h config/Idefault.h init.h
cast.o : parse.h sizes.h memory.h zmalloc.h types.h field.h scan.h repl.h mawk.h config.h symtype.h config/Idefault.h
code.o : sizes.h memory.h zmalloc.h types.h code.h mawk.h config.h config/Idefault.h init.h
da.o : sizes.h memory.h zmalloc.h types.h field.h repl.h code.h bi_funct.h mawk.h config.h symtype.h config/Idefault.h
error.o : parse.h bi_vars.h sizes.h types.h scan.h mawk.h config.h symtype.h config/Idefault.h
execute.o : bi_vars.h fin.h sizes.h memory.h zmalloc.h regexp.h types.h field.h code.h repl.h bi_funct.h mawk.h config.h symtype.h config/Idefault.h
fcall.o : sizes.h memory.h zmalloc.h types.h code.h mawk.h config.h symtype.h config/Idefault.h
field.o : parse.h bi_vars.h sizes.h memory.h zmalloc.h regexp.h types.h field.h scan.h repl.h mawk.h config.h symtype.h config/Idefault.h init.h
files.o : fin.h sizes.h memory.h zmalloc.h types.h files.h mawk.h config.h config/Idefault.h
fin.o : parse.h fin.h bi_vars.h sizes.h memory.h zmalloc.h types.h field.h scan.h mawk.h config.h symtype.h config/Idefault.h
hash.o : sizes.h memory.h zmalloc.h types.h mawk.h config.h symtype.h config/Idefault.h
init.o : bi_vars.h sizes.h memory.h zmalloc.h types.h field.h code.h mawk.h config.h symtype.h config/Idefault.h init.h
jmp.o : sizes.h memory.h zmalloc.h types.h code.h jmp.h mawk.h config.h config/Idefault.h init.h
kw.o : parse.h sizes.h types.h mawk.h config.h symtype.h config/Idefault.h init.h
main.o : fin.h bi_vars.h sizes.h memory.h zmalloc.h types.h field.h code.h files.h mawk.h config.h config/Idefault.h init.h
makescan.o : parse.h scan.h symtype.h
matherr.o : sizes.h types.h mawk.h config.h config/Idefault.h
memory.o : sizes.h memory.h zmalloc.h types.h mawk.h config.h config/Idefault.h
parse.o : bi_vars.h sizes.h memory.h zmalloc.h types.h field.h code.h files.h bi_funct.h mawk.h jmp.h config.h symtype.h config/Idefault.h
print.o : bi_vars.h parse.h sizes.h memory.h zmalloc.h types.h field.h scan.h files.h bi_funct.h mawk.h config.h symtype.h config/Idefault.h
re_cmpl.o : parse.h sizes.h memory.h zmalloc.h regexp.h types.h scan.h repl.h mawk.h config.h symtype.h config/Idefault.h
scan.o : parse.h fin.h sizes.h memory.h zmalloc.h types.h field.h scan.h repl.h code.h files.h mawk.h config.h symtype.h config/Idefault.h init.h
split.o : bi_vars.h parse.h sizes.h memory.h zmalloc.h regexp.h types.h field.h scan.h bi_funct.h mawk.h config.h symtype.h config/Idefault.h
version.o : patchlev.h sizes.h types.h mawk.h config.h config/Idefault.h
zmalloc.o : sizes.h zmalloc.h types.h mawk.h config.h config/Idefault.h
