/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define	import_spp
#define import_knames
#include <iraf.h>

/* ACHTB_ -- Unpack an unsigned byte array into an SPP array.
 * The loop runs in the reverse direction so that the unpack can be
 * performed in place (a and b can be the same array).
 */
void
ACHTBI (
  XCHAR		*a,
  XINT	*b,
  XINT		*npix
)
{
	register XUBYTE	*ip, *first = (XUBYTE *)a;
	register XINT	*op;

	for (ip = &first[*npix], op = &((XINT *)b)[*npix];  ip > first;  )
		*--op = *--ip;
}
