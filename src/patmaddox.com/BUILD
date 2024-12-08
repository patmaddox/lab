def build_site(name:str, args=""):
    genrule(
        name = name,
        srcs = {
            "CONTENT": ":content",
            "ZOLA": ":generator--zola"
        },
        cmd = [
            f"zola -r ${SRCS_ZOLA} build {args}",
            f"mv ${SRCS_ZOLA}/public {name}"
        ],
        outs = [
            name
        ]
    )

build_site("patmaddox.com")
build_site("localhost", args="-u http://localhost:62123")

def test_cmd(name:str):
    gentest(
        name = name,
        data = {
            "ROOT": ":localhost",
            "TESTSUITE": ":testsuite"
        },
        no_test_output = True,
        test_cmd = [
            f"MUFFET=${TOOLS_MUFFET} URLCHECK=${TOOLS_URLCHECK} ROOTDIR=$(realpath ${DATA_ROOT}) kyua {name} --kyuafile=${DATA_TESTSUITE}/Kyuafile"
        ],
        test_tools = {
            "MUFFET": CONFIG.MUFFET_TOOL,
            "URLCHECK": "//src/urlcheck:urlcheck"
        }
    )

test_cmd("test")
test_cmd("debug")

export_file(
    name = "content",
    src = "content"
)

export_file(
    name = "generator--basic",
    src = "generators/basic.sh"
)

export_file(
    name = "generator--zola",
    src = "generators/zola"
)

export_file(
    name = "testsuite",
    src = "tests"
)
