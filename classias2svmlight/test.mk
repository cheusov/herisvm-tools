ds = ${SRCDIR_datasets}
output = ${.OBJDIR}/output.txt

test: all
	@set -e; \
	\
	export PATH=${.OBJDIR:Q}:$$PATH; \
	\
	echo 'Test C #1'; \
	classias2svmlight < ${ds}/small_train.classias \
	    > ${output}; \
	diff -u expect1.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test C #2'; \
	env HSVM_LABEL_MAP='zero:0 one:1 two:2' \
	    classias2svmlight < ${ds}/small_train.classias \
	    > ${output}; \
	diff -u expect2.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test C #3'; \
	env HSVM_LABEL_MAP='one:1 two:2' \
	    classias2svmlight < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect3.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test C #4.1'; \
	env HSVM_LABEL_MAP='one:1 two:zzz' \
	    classias2svmlight < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test C #4.2'; \
	env HSVM_LABEL_MAP='one:1 two: zero:0' \
	    classias2svmlight < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \
	echo 'Test C #4.3'; \
	env HSVM_LABEL_MAP='one:1 two: zero:0' \
	    classias2svmlight ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test rb #1'; \
	classias2svmlight.rb < ${ds}/small_train.classias \
	    > ${output}; \
	diff -u expect1.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test rb #2'; \
	env HSVM_LABEL_MAP='zero:0 one:1 two:2' \
	    classias2svmlight.rb < ${ds}/small_train.classias \
	    > ${output}; \
	diff -u expect2.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test rb #3'; \
	env HSVM_LABEL_MAP='one:1 two:2' \
	    classias2svmlight.rb < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect3.out ${output}; \
	echo '      succeeded'; \
	echo 'Test rb #4.1'; \
	env HSVM_LABEL_MAP='one:1 two:zzz' \
	    classias2svmlight.rb < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test rb #4.2'; \
	env HSVM_LABEL_MAP='one:1 two: zero:0' \
	    classias2svmlight.rb < ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \
	echo 'Test rb #4.3'; \
	env HSVM_LABEL_MAP='one:1 two: zero:0' \
	    classias2svmlight.rb ${ds}/small_train.classias \
	    2> ${output} >/dev/null || true; \
	diff -u expect4.out ${output}; \
	echo '      succeeded'; \


CLEANFILES +=	${output}
