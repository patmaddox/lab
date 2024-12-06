genrule(
    name = "patmaddox.com",
    srcs = {
        "CONTENT": ":content",
        "GENERATOR": ":generator--basic"
    },
    cmd = [
        "./${SRCS_GENERATOR} _out ${SRCS_CONTENT}"
    ],
    outs = [
        "_out"
    ]
)

gentest(
    name = "test",
    data = {
        "ROOT": ":patmaddox.com",
        "TESTSUITE": ":testsuite"
    },
    no_test_output = True,
    test_cmd = [
        "ROOTDIR=$(realpath ${DATA_ROOT}) kyua test --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ]
)

gentest(
    name = "debug",
    data = {
        "ROOT": ":patmaddox.com",
        "TESTSUITE": ":testsuite"
    },
    no_test_output = True,
    test_cmd = [
        "ROOTDIR=$(realpath ${DATA_ROOT}) kyua debug --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ],
    labels = ["manual"]
)

export_file(
    name = "content",
    src = "content"
)

export_file(
    name = "generator--basic",
    src = "generators/basic.sh"
)

export_file(
    name = "testsuite",
    src = "tests"
)
