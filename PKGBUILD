pkgdesc="FreeRTOS compiled into static library"
arch=($CARCH)
license=('custom')
provides=('freertos')
conflicts=('freertos')
options=('!strip')

_do_build() {
    make all
}

_do_check() {
	make -k check
}

_do_package() {
	make install
}

