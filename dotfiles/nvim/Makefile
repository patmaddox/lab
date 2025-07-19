lazy/lazy.nvim:
	@mkdir -p ${.TARGET:H}
	@rm -f ${.TARGET}.tmp
	git clone --branch v11.17.1 https://github.com/folke/lazy.nvim.git ${.TARGET}.tmp
	mv ${.TARGET}.tmp ${.TARGET}
