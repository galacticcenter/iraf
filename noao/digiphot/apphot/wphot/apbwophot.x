include <fset.h>
include "../lib/apphot.h"
include "../lib/display.h"
include "../lib/center.h"
include "../lib/fitsky.h"

# AP_BWOPHOT -- Procedure to compute the magnitudes for a list of objects
# interactively.

procedure ap_bwophot (ap, im, cl, sd, out, id, ld, gd, mgd, gid, interactive)

pointer ap			# pointer to apphot structure
pointer	im			# pointer to IRAF image
int	cl			# starlist file descriptor
int	sd			# sky file descriptor
int	out			# output file descriptor
int	id, ld			# sequence and list numbers
pointer	gd			# pointer to stdgraph stream
pointer	mgd			# pointer to the plot metacode stream
pointer	gid			# pointer to image display stream
int	interactive		# interactive pr batch mode

int	stdin, ild, cier, sier, pier
pointer	sp, str
real	wx, wy
int	fscan(), nscan(), apfitsky(), apfitcenter(), apwmag(), strncmp()
int	apstati()
real	apstatr()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call fstats (cl, F_FILENAME, Memc[str], SZ_FNAME)

	# Initialize
	ild = ld

	# Print query.
	if (strncmp ("STDIN", Memc[str], 5) == 0)
	    stdin = YES
	else
	    stdin = NO
	if (stdin == YES) {
	    call printf ("Type object x and y coordinates (^D or ^Z to end): ")
	    call flush (STDOUT)
	}

	# Loop over the coordinate file.
	while (fscan (cl) != EOF) {

	    # Get and store the coordinates.
	    call gargr (wx)
	    call gargr (wy)
	    if (nscan () != 2) {
		if (stdin == YES) {
	    	    call printf ("Type object x and y coordinates (^D or ^Z to end): ")
	    	    call flush (STDOUT)
		}
		next
	    }
	    call apsetr (ap, CWX, wx)
	    call apsetr (ap, CWY, wy)

	    # Center the coordinatess, fit the sky and compute magnitudes.
	    cier = apfitcenter (ap, im, wx, wy)
	    sier = apfitsky (ap, im, apstatr (ap, XCENTER), apstatr (ap,
	        YCENTER), sd, gd)
	    pier = apwmag (ap, im, apstatr (ap, XCENTER), apstatr (ap, YCENTER),
	        apstati (ap, POSITIVE), apstatr (ap, SKY_MODE),
		apstatr (ap, SKY_SIGMA), apstati (ap, NSKY))

	    # Write the results.
	    if (interactive == YES) {
		call ap_qpmag (ap, cier, sier, pier)
		if (gid != NULL)
		    call apmark (ap, gid, apstati (ap, MKCENTER), apstati (ap,
			MKSKY), apstati (ap, MKAPERT))
	    }
	    if (id == 1)
	        call ap_param (ap, out, "wphot")
	    call ap_pmag (ap, out, id, ild, cier, sier, pier)
	    call appplot (ap, im, id, cier, sier, pier, mgd, YES)

	    # Prepare for the next object.
	    id = id + 1
	    ild = ild + 1
	    call apsetr (ap, WX, wx)
	    call apsetr (ap, WY, wy)
	    if (stdin == YES) {
		call printf ("Type object x and y coordinates (^Z or ^D to end): ")
		call flush (STDOUT)
	    }
	}

	call sfree (sp)
end