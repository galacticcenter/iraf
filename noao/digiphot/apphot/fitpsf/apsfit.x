include "../lib/apphotdef.h"
include "../lib/fitpsfdef.h"
include "../lib/noisedef.h"
include "../lib/fitpsf.h"

# APSFFIT -- Procedure to fit an analytic function to the PSF.

int procedure apsffit (ap, im, wx, wy)

pointer	ap		# pointer to the apphot structure
pointer	im		# pointer to the IRAF image
real	wx, wy		# object coordinates

int	ier, fier
pointer	psf, nse
real	datamin, datamax
int	apfbuf(), apsfradgauss(), apsfelgauss(), apsfmoments()

begin
	# Initialize.
	psf = AP_PPSF(ap)
	nse = AP_NOISE(ap)
	AP_PFXCUR(psf) = wx
	AP_PFYCUR(psf) = wy

	# Fetch the buffer of pixels.
	ier = apfbuf (ap, im, wx, wy)
	if (ier == AP_NOPSFAREA)
	    return (AP_NOPSFAREA)

	switch (AP_PSFUNCTION(psf)) {

	case AP_RADGAUSS:

	    fier = apsfradgauss (Memr[AP_PSFPIX(psf)], AP_PNX(psf), AP_PNY(psf),
	        AP_FWHMPSF(ap) * AP_SCALE(ap), AP_NOISEFUNCTION(nse),
		AP_READNOISE(nse) / AP_EPADU(nse), AP_PMAXITER(psf),
		AP_PK2(psf), AP_PNREJECT(psf), Memr[AP_PPARS(psf)],
		Memr[AP_PPERRS(psf)], AP_PSFNPARS(psf))

	    Memr[AP_PPARS(psf)+1] = Memr[AP_PPARS(psf)+1] + wx - AP_PXC(psf)
	    Memr[AP_PPARS(psf)+2] = Memr[AP_PPARS(psf)+2] + wy - AP_PYC(psf) 
	    Memr[AP_PPARS(psf)+3] = sqrt (abs (Memr[AP_PPARS(psf)+3]))

	case AP_ELLGAUSS:

	    fier = apsfelgauss (Memr[AP_PSFPIX(psf)], AP_PNX(psf), AP_PNY(psf),
	        AP_FWHMPSF(ap) * AP_SCALE(ap), AP_NOISEFUNCTION(nse),
		AP_READNOISE(nse) / AP_EPADU(nse), AP_PMAXITER(psf),
		AP_PK2(psf), AP_PNREJECT(psf), Memr[AP_PPARS(psf)],
		Memr[AP_PPERRS(psf)], AP_PSFNPARS(psf))

	    Memr[AP_PPARS(psf)+1] = Memr[AP_PPARS(psf)+1] + wx - AP_PXC(psf)
	    Memr[AP_PPARS(psf)+2] = Memr[AP_PPARS(psf)+2] + wy - AP_PYC(psf) 
	    Memr[AP_PPARS(psf)+3] = sqrt (abs (Memr[AP_PPARS(psf)+3]))
	    Memr[AP_PPARS(psf)+4] = sqrt (abs (Memr[AP_PPARS(psf)+4]))

	case AP_MOMENTS:

	    call alimr (Memr[AP_PSFPIX(psf)], AP_PNX(psf) * AP_PNY(psf),
	        datamin, datamax)

	    if (AP_POSITIVE(ap) == YES)
	        fier = apsfmoments (Memr[AP_PSFPIX(psf)], AP_PNX(psf),
		    AP_PNY(psf), datamin + AP_THRESHOLD(nse), AP_POSITIVE(ap),
		    Memr[AP_PPARS(psf)], Memr[AP_PPERRS(psf)], AP_PSFNPARS(psf))
	    else
	        fier = apsfmoments (Memr[AP_PSFPIX(psf)], AP_PNX(psf),
		    AP_PNY(psf), datamax - AP_THRESHOLD(nse), AP_POSITIVE(ap),
		    Memr[AP_PPARS(psf)], Memr[AP_PPERRS(psf)], AP_PSFNPARS(psf))

	    Memr[AP_PPARS(psf)+1] = Memr[AP_PPARS(psf)+1] + wx - AP_PXC(psf)
	    Memr[AP_PPARS(psf)+2] = Memr[AP_PPARS(psf)+2] + wy - AP_PYC(psf) 

	default:

	    # do nothing gracefully

        }

	# Return the appropriate error code.
	if (fier == AP_OK) {
	    if (ier == AP_PSF_OUTOFBOUNDS)
		return (AP_PSF_OUTOFBOUNDS)
	    else
		return (AP_OK)
	} else if (fier == AP_NPSF_TOO_SMALL) {
	    call amovkr (INDEFR, Memr[AP_PPARS(psf)], AP_PSFNPARS(psf))
	    call amovkr (INDEFR, Memr[AP_PPERRS(psf)], AP_PSFNPARS(psf))
	    return (AP_NPSF_TOO_SMALL)
	} else
	    return (fier)
end