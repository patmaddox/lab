host_name := "$(basename $(pwd))"
newbe_src := "../../../src/new-be"
freebsd_src := "../../../src/freebsd-src"

help:
  just -l

# Build host image via ninja
build:
    ninja -C ../../.. ninja-out/infra/hosts/{{host_name}}/{{host_name}}.be.zfs

# Deploy the image using ansible (builds if needed)
deploy: build
    ../../common/deploy.sh

# Create a new, fully-configured boot environment
new-be:
  {{newbe_src}}/new-be {{host_name}}.conf

# Import any dist files that have been edited on the system
import-config:
  ../../common/import-config.sh

# Update portsfile with list of manually-installed ports
update-ports:
  {{newbe_src}}/list-ports | tee ports

# Clean build artifacts
clean:
    rm -rf _build dist
    ninja -C ../../.. -t clean ninja-out/infra/hosts/{{host_name}}/{{host_name}}.be.zfs
