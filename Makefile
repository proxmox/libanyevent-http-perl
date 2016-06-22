RELEASE=4.2

VERSION=2.22
PKGREL=1

PACKAGE=libanyevent-http-perl

DEBSRC=libanyevent-http-perl_${VERSION}-${PKGREL}.debian.tar.xz
PKGDIR=AnyEvent-HTTP-${VERSION}
PKGSRC=libanyevent-http-perl_${VERSION}.orig.tar.gz

GITVERSION:=$(shell cat .git/refs/heads/master)

ARCH=all
DEB=${PACKAGE}_${VERSION}-${PKGREL}_${ARCH}.deb

all: ${DEB}

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

.PHONY: deb
deb ${DEB}: 
	rm -rf ${PKGDIR}
	tar xf ${PKGSRC}
	cd ${PKGDIR}; tar xf ../${DEBSRC}
	echo "git clone git://git.proxmox.com/git/libanyevent-http-perl.git\\ngit checkout ${GITVERSION}" >  ${PKGDIR}/debian/SOURCE
	echo "debian/SOURCE" >> ${PKGDIR}/debian/docs
#cd ${PKGDIR}; patch -p1 <../update-changelog.patch
	cd ${PKGDIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: clean
clean:
	rm -rf *~ *.deb *.changes ${PKGDIR}

.PHONY: distclean
distclean: clean

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

