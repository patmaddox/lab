export_file(
    name = "urlcheck",
    src = "urlcheck.sh",
    visibility = ["//src/patmaddox.com/..."]
)

gentest(
    name = "test",
    data = {
        "URLCHECK": ":urlcheck",
        "TESTSUITE": ":testsuite"
    },
    no_test_output = True,
    test_cmd = [
        "URLCHECK=$(realpath ${DATA_URLCHECK}) kyua test --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ]
)

gentest(
    name = "debug",
    data = {
        "URLCHECK": ":urlcheck",
        "TESTSUITE": ":testsuite"
    },
    no_test_output = True,
    test_cmd = [
        "PATTESTSUITE=$(realpath ${DATA_TESTSUITE}) URLCHECK=$(realpath ${DATA_URLCHECK}) kyua debug --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ],
    labels = ["manual"]
)

export_file(
    name = "testsuite",
    src = "test"
)
