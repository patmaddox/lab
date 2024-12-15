genrule(
    name = "devbsd",
    srcs = {
        "BASE_TXZ": "//src/freebsd-src:dev--base.txz|TXZ",
        "KERNEL_TXZ": "//src/freebsd-src:dev--kernel.GENERIC-NODEBUG.txz|TXZ",
        "BUILD_SH": "//infra/images:build_image.sh",
        "METALOG": ":metalog",
        "DISTFILES": ":distfiles"
    },
    cmd = [
        "doas sh ${SRCS_BUILD_SH}",
        "whoami > whoami.txt",
        "doas chown $(cat whoami.txt) ${OUTS_IMG}",
        "doas chflags -R noschg _build",
        "doas rm -rf -R $(cat whoami.txt) _build"
    ],
    outs = {"IMG": ["devbsd.zfs"]}
)

filegroup(
    name = "distfiles",
    srcs = [
        "dist/boot/loader.conf",
        "dist/etc/fstab",
        "dist/etc/rc.conf",
        "dist/etc/resolv.conf",
        "dist/etc/ssh/sshd_config",
        "dist/root/.ssh/authorized_keys"
    ]
)

export_file(
    name = "metalog",
    src = "dist/METALOG"
)

sh_cmd(
    name = "install",
    deps = [":devbsd"],
    cmd = "doas cp $(out_location :devbsd) /vm/devbsd/"
)
