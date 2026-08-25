.PHONY: all cert test clean

CERTFILES= ${HOME}/Downloads/www_patmaddox_com.pem ${HOME}/Downloads/www_patmaddox_com.key

all: cert test clean

cert: ${CERTFILES}
	cat ${.ALLSRC} | ssh root@patmaddox.com "cat > /root/www_patmaddox_com.haproxy.pem && service haproxy reload"

test:
	echo | openssl s_client -showcerts -servername patmaddox.com -connect patmaddox.com:443 2>/dev/null | openssl x509 -inform pem -noout -text

clean:
	rm -f ${CERTFILES}
