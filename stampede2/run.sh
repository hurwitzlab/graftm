#!/bin/bash

module load tacc-singularity
#module load launcher

function lc() {
    FILE=$1
    [[ -f "$FILE" ]] && wc -l "$FILE" | cut -d ' ' -f 1
}

#PARAMRUN="$TACC_LAUNCHER_DIR/paramrun"
#export LAUNCHER_PLUGIN_DIR="$TACC_LAUNCHER_DIR/plugins"
#export LAUNCHER_WORKDIR="$PWD"
#export LAUNCHER_RMI="SLURM"
#export LAUNCHER_SCHED="interleaved"

set -u

IMG="graftm.img"
OUT_DIR="$PWD/graftm-out"

[[ -d "$OUT_DIR" ]] && rm -rf "$OUT_DIR"

if [[ ! -f "$IMG" ]]; then
    echo "Cannot find Singularity image \"$IMG\""
    exit 1
fi

ARGS=""
FORWARD=""
REVERSE=""
PACKAGE=""
while (($#)); do
    if [[ $1 == '-f' ]]; then
        FORWARD="$FORWARD $2"
        shift 2
    elif [[ $1 == '-r' ]]; then
        REVERSE="$REVERSE $2"
        shift 2
    elif [[ $1 == '-o' ]]; then
        OUT_DIR="$2"
        shift 2
    elif [[ $1 == '-p' ]]; then
        PACKAGE="$2"
        shift 2
    else
        ARGS="$ARGS $1"
        shift
    fi
done

ARGS="$ARGS --output_directory $OUT_DIR --threads 12"

if [[ -z "$FORWARD" ]]; then
    echo "No -f FORWARD"
    exit 1
fi

if [[ -z "$PACKAGE" ]]; then
    PKG_BASE="/work/05066/imicrobe/iplantc.org/data/imicrobe/graftm/packages"
    PKG_DIR="$PKG_BASE/${PACKAGE}.gpkg"
    if [[ -d "$PKG_DIR" ]]; then
        ARGS="$ARGS --graftm_package=$PKG_DIR"
    else
        echo "Bad PACKAGE \"$PACKAGE\""
        exit 1
    fi
fi

FORWARD_LIST=$(mktemp)
for QRY in $FORWARD; do
    if [[ -f "$QRY" ]]; then
        echo "$QRY" >> "$FORWARD_LIST"
    elif [[ -d "$QRY" ]]; then
        find "$QRY" -type f >> "$FORWARD_LIST"
    else
        echo "FORWARD arg \"$QRY\" is neither file nor directory"
    fi
done

REVERSE_LIST=$(mktemp)
for QRY in $REVERSE; do
    if [[ -f "$QRY" ]]; then
        echo "$QRY" >> "$REVERSE_LIST"
    elif [[ -d "$QRY" ]]; then
        find "$QRY" -type f >> "$REVERSE_LIST"
    else
        echo "REVERSE arg \"$QRY\" is neither file nor directory"
    fi
done

NUM_FORWARD=$(lc "$FORWARD_LIST")

if [[ $NUM_FORWARD -lt 1 ]]; then
    echo "No good input files in FORWARD \"$FORWARD\""
    exit 1
fi

#PARAM="$$.param"
FORWARD_FILES=$(cat "$FORWARD_LIST" | xargs echo)
ARGS="$ARGS --forward $FORWARD_FILES"

NUM_REVERSE=$(lc "$REVERSE_LIST")
if [[ $NUM_REVERSE -gt 0 ]]; then
    REVERSE_FILES=$(cat "$REVERSE_LIST" | xargs echo)
    ARGS="$ARGS --reverse $REVERSE_FILES"
fi

echo "ARGS $ARGS"
singularity exec $IMG graftM graft $ARGS

#$PARAMRUN
#rm "$PARAM"

echo "Done"
echo "Comments to Ken Youens-Clark kyclark@email.arizona.edu"
