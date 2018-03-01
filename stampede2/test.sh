#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J fiztest
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user kyclark@email.arizona.edu

set -u

./run.sh -f "$WORK/data/graftM_example/forward/Carbonic_anhydrase_Mycocosm_numbered_clean.faa" --graftm_package "$WORK/data/graftM_example/refpkg/beta.ref.gpkg" --output_directory "$WORK/data/graftM_example/Carbonic_anhydrase_Mycocosm_numbered_clean.beta.out"
