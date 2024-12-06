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
        "MUFFET=${TOOLS_MUFFET} URLCHECK=$(realpath ${DATA_URLCHECK}) kyua test --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ],
    test_tools = {
        "MUFFET": CONFIG.MUFFET_TOOL
    }
)

gentest(
    name = "debug",
    data = {
        "URLCHECK": ":urlcheck",
        "TESTSUITE": ":testsuite"
    },
    no_test_output = True,
    test_cmd = [
        "MUFFET=${TOOLS_MUFFET} URLCHECK=$(realpath ${DATA_URLCHECK}) kyua debug --kyuafile=${DATA_TESTSUITE}/Kyuafile"
    ],
    test_tools = {
        "MUFFET": CONFIG.MUFFET_TOOL
    },
    labels = ["manual"]
)

export_file(
    name = "testsuite",
    src = "test"
)
