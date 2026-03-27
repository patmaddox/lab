INDEX = INDEX.md

PLANS != find -s . -name '*.md' ! -name INDEX.md -type f

.DELETE_ON_ERROR:
.PHONY: index clean

index: ${INDEX}

${INDEX}: ${PLANS}
	@rm -f ${.TARGET}
	@printf '# Plans Index\n\n' > ${.TARGET}
	@printf 'Generated from plan frontmatter. Do not edit.\n\n' >> ${.TARGET}
	@for status in active ready draft done abandoned rejected; do \
		files=$$(grep -l "status: $${status}" ${PLANS} 2>/dev/null || true); \
		if [ -n "$${files}" ]; then \
			printf '## %s\n\n' "$${status}" >> ${.TARGET}; \
			for f in $${files}; do \
				name=$$(echo "$${f}" | sed 's|^\./||; s|\.md$$||'); \
				title=$$(grep '^# ' "$${f}" | head -1 | sed 's/^# //'); \
				printf -- '- [%s](%s) — %s\n' "$${name}" "$${f}" "$${title}" >> ${.TARGET}; \
			done; \
			printf '\n' >> ${.TARGET}; \
		fi; \
	done
	@chmod a-w ${.TARGET}

clean:
	rm -f ${INDEX}
