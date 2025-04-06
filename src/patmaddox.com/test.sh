#!/usr/bin/env atf-sh

zola_root=$(atf_get_srcdir)/generators/zola
port=62123
www=http://localhost:${port}
outfile=output.html
urlcheck=$(cd ${zola_root} && realpath $(jj root)/ninja-out/bin/urlcheck.sh)

httpd::start() {
    zola -r ${zola_root} build -o html -u ${www}
    darkhttpd html --addr 127.0.0.1 --daemon --pidfile httpd.pid --port ${port} || exit 1
}

httpd::stop() {
    if [ -f httpd.pid ]; then
	kill $(cat httpd.pid)
    fi
}

check_get() {
    local url
    url=${1}; shift

    atf_check ${urlcheck} ${www} ${url}
}

atf_init_test_cases() {
    atf_add_test_case index
    atf_add_test_case sitemap
}

## index
atf_test_case index cleanup
index_head() {
    atf_set "descr" "Check index page presence and content"
}

index_body() {
    httpd::start
    check_get ${www}
    atf_check fetch -q -o ${outfile} ${www}
    # check for at least one internal link
    atf_check grep -q ${www} ${outfile}
}

index_cleanup() {
    httpd::stop
}

## sitemap
atf_test_case sitemap cleanup
sitemap_head() {
    atf_set "descr" "Check all pages in the sitemap"
}

sitemap_body() {
    httpd::start

    local urls
    urls=$(sed -e "s|^https://patmaddox.com|${www}|" < html/sitemap.txt)
    for u in ${urls}; do
	check_get ${u}
	echo "${u}" >> ${outfile}
    done

    # make sure that something got got
    atf_check grep -q ${www} ${outfile}
}

sitemap_cleanup() {
    httpd::stop
}
