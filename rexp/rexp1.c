
/********************************************
rexp1.c
copyright 1991, Michael D. Brennan

This is a source file for mawk, an implementation of
the AWK programming language.

Mawk is distributed without warranty under the terms of
the GNU General Public License, version 2, 1991.
********************************************/

/*$Log:	rexp1.c,v $
 * Revision 3.2  91/08/13  09:10:11  brennan
 * VERSION .9994
 * 
 * Revision 3.1  91/06/07  10:33:22  brennan
 * VERSION 0.995
 * 
*/

/*  re machine  operations  */

#include  "rexp.h"

static MACHINE *PROTO( new_TWO , (int) ) ;


static  MACHINE  *new_TWO(type)
  int type ;
{ 
  static  MACHINE  x ;

  x.start = (STATE *) RE_malloc(2*STATESZ) ;
  x.stop = x.start + 1 ;
  x.start->type = type ;
  x.stop->type = M_ACCEPT ;
  return &x ;
} ;


/*  build a machine that recognizes any  */
MACHINE  RE_any()
{ return  * new_TWO(M_ANY) ; }

/*  build a machine that recognizes the start of string  */
MACHINE  RE_start()
{ return  * new_TWO(M_START) ; }

MACHINE  RE_end()
{ return  * new_TWO(M_END) ; }

/*  build a machine that recognizes a class  */
MACHINE  RE_class( bvp )
  BV *bvp  ;
{ register MACHINE *p = new_TWO(M_CLASS) ;

  p->start->data.bvp = bvp ;
  return *p ;
}


MACHINE  RE_u()
{ return  *new_TWO(M_U) ; }

MACHINE  RE_str( str, len)
  char *str ;
  unsigned len ;
{ register MACHINE *p = new_TWO(M_STR) ;

  p->start->len = len ;
  p->start->data.str = str ;
  return *p ;
}

/*  replace m and n by a machine that recognizes  mn   */
void  RE_cat( mp, np)
  MACHINE  *mp, *np ;
{ unsigned sz1, sz2, sz ;

  sz1 = mp->stop - mp->start  ;
  sz2 = np->stop - np->start + 1 ;
  sz  = sz1 + sz2 ;

  mp->start = (STATE *) RE_realloc( mp->start, sz * STATESZ ) ;
  mp->stop = mp->start + (sz - 1) ;
  (void)  memcpy( mp->start + sz1, np->start, SIZE_T(sz2 * STATESZ) ) ;
  free( np->start ) ;
}

 /*  replace m by a machine that recognizes m|n  */

void  RE_or( mp, np)
  MACHINE  *mp, *np ;
{ register STATE *p ;
  unsigned szm, szn ;

  szm = mp->stop - mp->start + 1 ;
  szn = np->stop - np->start + 1 ;

  p = (STATE *) RE_malloc( (szm+szn+1) * STATESZ ) ;
  (void) memcpy( p+1, mp->start, SIZE_T(szm * STATESZ) ) ;
  free( mp->start) ;
  mp->start = p ;
  (mp->stop  = p + szm + szn) -> type = M_ACCEPT ;
  p->type = M_2JA ;
  p->data.jump = szm+1 ;
  (void) memcpy( p + szm + 1 , np->start, SIZE_T(szn * STATESZ)) ;
  free( np->start ) ;
  (p += szm)->type = M_1J ;
  p->data.jump = szn ;
}

/*  UNARY  OPERATIONS     */

/*  replace m by m*   */

void  RE_close( mp )
  MACHINE  *mp ;
{ register STATE *p ;
  unsigned sz ;

  sz = mp->stop - mp->start + 1 ;
  p = (STATE *) RE_malloc( (sz+2) * STATESZ ) ;
  (void) memcpy( p+1, mp->start, SIZE_T(sz * STATESZ)) ;
  free( mp->start ) ;
  mp->start = p ;
  mp->stop  = p + (sz+1) ;
  p->type = M_2JA ;
  p->data.jump = sz + 1 ;
  (p += sz) -> type = M_2JB ;
  p->data.jump = -(sz-1) ;
  (p+1)->type = M_ACCEPT ;
}

/*  replace m  by  m+  (positive closure)   */

void  RE_poscl( mp )
  MACHINE  *mp ;
{ register STATE *p ;
  unsigned  sz ;

  sz = mp->stop - mp->start + 1 ;
  mp->start = p = (STATE *) RE_realloc(mp->start ,  (sz+1) * STATESZ ) ;
  mp->stop  = p + sz ;
  p +=  --sz ;
  p->type = M_2JB ;
  p->data.jump = -sz ;
  (p+1)->type = M_ACCEPT ;
}

/* replace  m  by  m? (zero or one)  */

void  RE_01( mp )
  MACHINE  *mp ;
{ unsigned  sz ;
  register  STATE *p ;

  sz = mp->stop - mp->start + 1 ;
  p = (STATE *) RE_malloc( (sz+1) * STATESZ ) ;
  (void) memcpy( p+1, mp->start, SIZE_T(sz * STATESZ)) ;
  free( mp->start ) ;
  mp->start = p ;
  mp->stop = p + sz ;
  p->type = M_2JB ;
  p->data.jump = sz ;
}

/*===================================
MEMORY  ALLOCATION
 *==============================*/


VOID *RE_malloc( sz ) 
  unsigned sz ;
{ register VOID *p ;

  if ( ! ( p = malloc(SIZE_T(sz)) ) )  RE_error_trap(MEMORY_FAILURE) ;
  return p ;
}

VOID *RE_realloc( p, sz)
  register VOID *p ; unsigned sz ;
{ if ( ! ( p = realloc( p, SIZE_T(sz)) ) )  RE_error_trap(MEMORY_FAILURE) ;
  return p ;
}

