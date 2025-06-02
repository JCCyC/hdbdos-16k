#!/bin/bash
cd "`dirname $0`"
CURDIR=`pwd`

if [ -d ../toolshed.old ]; then
	rm -rf ../toolshed.old
fi
if ls ../toolshed.old >/dev/null 2>&1; then
	echo "Unexpected structure: bad 'toolshed.old' directory" >&2
	exit 1
fi

if ls ../toolshed >/dev/null 2>&1; then
	mv ../toolshed ../toolshed.old >/dev/null 2>&1
	if ls ../toolshed >/dev/null 2>&1; then
		echo "Unexpected structure: bad 'toolshed' directory" >&2
		exit 1
	fi
fi

cd .. && \
git clone https://github.com/nitros9project/toolshed && \
cd toolshed && \
patch -p1 <"$CURDIR/hdbdos-16k.patch" && \
make -C cocoroms && \
make -C hdbdos && \
echo && \
echo "HDB-DOS/16 successfully built!" && \
echo && \
rm -f "$CURDIR/16k-*.rom" && \
cp hdbdos/16k-*.rom "$CURDIR" && \
cd "$CURDIR" && \
ls 16k-*.rom && \
echo
exit $?
