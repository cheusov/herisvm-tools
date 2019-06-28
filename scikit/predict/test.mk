output = ${.OBJDIR}/output.txt

test: all
	@set -e; \
	\
	export PATH=${SRCDIR_predict}:${OBJDIR_predict}:$$PATH; \
	export PATH=${.CURDIR}:${.OBJDIR}:$$PATH; \
	\
	echo 'Test #1.1' 1>&2; \
	scikit-predict -h 2>${output:Q}; \
	test -s "${output:Q}"; \
	echo '      succeeded'; \
	\
	echo 'Test #1.2' 1>&2; \
	scikit-predict -h 2>${output:Q}; \
	test -s "${output:Q}"; \
	echo '      succeeded'

CLEANFILES +=	${output}
