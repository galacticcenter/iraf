# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include <math/gsurfit.h>

include "dgsurfitdef.h"

# GSACPTS -- Procedure to add a set of points to the normal equations.
# The inner products of the basis functions are calculated and
# accumulated into the GS_NCOEFF(sf) ** 2 matrix MATRIX.
# The main diagonal of the matrix is stored in the first row of
# MATRIX followed by the remaining non-zero diagonals.
# The inner product
# of the basis functions and the data ordinates are stored in the
# NCOEFF(sf)-vector VECTOR.

procedure dgsacpts (sf, x, y, z, w, npts, wtflag)

pointer	sf		# surface descriptor
double	x[npts]		# array of x values
double	y[npts]		# array of y values
double	z[npts]		# data array
double	w[npts]		# array of weights
int	npts		# number of data points
int	wtflag		# type of weighting

int	i, ii, j, jj, k, l
int	xorder, xxorder, ntimes
pointer	sp, vzptr, vindex, mzptr, mindex, bxptr, bbxptr, byptr, bbyptr
pointer	byw, bw

double	adotd()

begin
	# increment the number of points
	GS_NPTS(sf) = GS_NPTS(sf) + npts

	# remove basis functions calculated by any previous gsrefit call
	if (GS_XBASIS(sf) != NULL || GS_YBASIS(sf) != NULL) {

	    if (GS_XBASIS(sf) != NULL)
	        call mfree (GS_XBASIS(sf), TY_DOUBLE)
	    GS_XBASIS(sf) = NULL
	    if (GS_YBASIS(sf) != NULL)
	        call mfree (GS_YBASIS(sf), TY_DOUBLE)
	    GS_YBASIS(sf) = NULL
	    if (GS_WZ(sf) != NULL)
	        call mfree (GS_WZ(sf), TY_DOUBLE)
	    GS_WZ(sf) = NULL
	}

	# calculate weights
	switch (wtflag) {
	case WTS_UNIFORM:
	    call amovkd (1.0d0, w, npts)
	case WTS_SPACING:
	    if (npts == 1)
		w[1] = 1.0d0
	    else
	        w[1] = abs (x[2] - x[1])
	    do i = 2, npts - 1
		w[i] = abs (x[i+1] - x[i-1])
	    if (npts == 1)
		w[npts] = 1.0d0
	    else
	        w[npts] = abs (x[npts] - x[npts-1])
	case WTS_USER:
	    # user supplied weights
	default:
	    call amovkd (1.0d0, w, npts)
	}


	# allocate space for the basis functions
	call smark (sp)

	# calculate the non-zero basis functions
	switch (GS_TYPE(sf)) {
	case GS_LEGENDRE:
	    call salloc (GS_XBASIS(sf), npts * GS_XORDER(sf), TY_DOUBLE)
	    call salloc (GS_YBASIS(sf), npts * GS_YORDER(sf), TY_DOUBLE)
	    call dgs_bleg (x, npts, GS_XORDER(sf), GS_XMAXMIN(sf),
	    		  GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_bleg (y, npts, GS_YORDER(sf), GS_YMAXMIN(sf),
	    		  GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	case GS_CHEBYSHEV:
	    call salloc (GS_XBASIS(sf), npts * GS_XORDER(sf), TY_DOUBLE)
	    call salloc (GS_YBASIS(sf), npts * GS_YORDER(sf), TY_DOUBLE)
	    call dgs_bcheb (x, npts, GS_XORDER(sf), GS_XMAXMIN(sf),
	    		  GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_bcheb (y, npts, GS_YORDER(sf), GS_YMAXMIN(sf),
	    		  GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	case GS_POLYNOMIAL:
	    call salloc (GS_XBASIS(sf), npts * GS_XORDER(sf), TY_DOUBLE)
	    call salloc (GS_YBASIS(sf), npts * GS_YORDER(sf), TY_DOUBLE)
	    call dgs_bpol (x, npts, GS_XORDER(sf), GS_XMAXMIN(sf),
	    		  GS_XRANGE(sf), XBASIS(GS_XBASIS(sf)))
	    call dgs_bpol (y, npts, GS_YORDER(sf), GS_YMAXMIN(sf),
	    		  GS_YRANGE(sf), YBASIS(GS_YBASIS(sf)))
	default:
	    call error (0, "GSACCUM: Illegal curve type.")
	}


	# allocate temporary storage space for matrix accumulation
	call salloc (byw, npts, TY_DOUBLE)
	call salloc (bw, npts, TY_DOUBLE)

	# one index the pointers
	vzptr = GS_VECTOR(sf) - 1
	mzptr = GS_MATRIX(sf)
	bxptr = GS_XBASIS(sf)
	byptr = GS_YBASIS(sf)

	switch (GS_TYPE(sf)) {

	case GS_LEGENDRE, GS_CHEBYSHEV, GS_POLYNOMIAL:

	    xorder = GS_XORDER(sf)
	    ntimes = 0

	    do l = 1, GS_YORDER(sf) {

		call amuld (w, YBASIS(byptr), Memd[byw], npts)
	        bxptr = GS_XBASIS(sf)
	        do k = 1, xorder {
	            call amuld (Memd[byw], XBASIS(bxptr), Memd[bw], npts) 
		    vindex = vzptr + k
	            VECTOR(vindex) = VECTOR(vindex) + adotd (Memd[bw], z,
		        npts)
		    bbyptr = byptr
	            bbxptr = bxptr
		    xxorder = xorder
		    jj = k
	            ii = 0
		    do j = k + ntimes, GS_NCOEFF(sf) {
		        mindex = mzptr + ii
		        do i = 1, npts
		            MATRIX(mindex) = MATRIX(mindex) + Memd[bw+i-1] *
				XBASIS(bbxptr+i-1) * YBASIS(bbyptr+i-1)	
			if (mod (jj, xxorder) == 0) {
			    jj = 1
			    bbxptr = GS_XBASIS(sf)
			    bbyptr = bbyptr + npts
			    if (GS_XTERMS(sf) == NO)
				xxorder = 1
			} else {
			    jj = jj + 1
			    bbxptr = bbxptr + npts
			}
		        ii = ii + 1
		    }
		    mzptr = mzptr + GS_NCOEFF(sf)
		    bxptr = bxptr + npts
	        }

		vzptr = vzptr + xorder
		ntimes = ntimes + xorder
		if (GS_XTERMS(sf) == NO)
		    xorder = 1
		byptr = byptr + npts
	    }

	default:
	    call error (0, "GSACCUM: Unknown curve type.")
	}

	# release the space
	call sfree (sp)
	GS_XBASIS(sf) = NULL
	GS_YBASIS(sf) = NULL
end