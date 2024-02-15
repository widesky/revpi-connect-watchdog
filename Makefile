INSTALL ?= install


all:
	@echo "Nothing to compile"

install:
	$(INSTALL) -o root -g root -m 0755 -t /usr/local/sbin revpi-watchdog.sh
	$(INSTALL) -o root -g root -m 0644 -t /lib/systemd/system revpi-watchdog.service
	systemctl daemon-reload

enable:
	systemctl enable revpi-watchdog.service

disable:
	systemctl disable revpi-watchdog.service
