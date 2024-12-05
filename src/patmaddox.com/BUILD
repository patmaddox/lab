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
        "TEST_RUNNER": ":test-script"
    },
    no_test_output = True,
    test_cmd = "./${DATA_TEST_RUNNER} ${DATA_ROOT}"
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
    name = "test-script",
    src = "tests/test.sh"
)
