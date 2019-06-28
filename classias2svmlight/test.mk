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
	echo 'Test C #5.1'; \
	env \
	    classias2svmlight -F ${output}.fmap -L ${output}.lmap ${ds}/dataset.classias \
	    > ${output}; \
	diff -u expect5.out ${output}; \
	diff -u fmap_expect1.out ${output}.fmap; \
	diff -u lmap_expect1.out ${output}.lmap; \
	rm ${output}.lmap ${output}.fmap; \
	echo '      succeeded'; \
	\
	echo 'Test C #5.2'; \
	env \
	    classias2svmlight -l1 ${ds}/dataset.classias | awk '{$$1 = $$1 - 1; print}' \
	    > ${output}; \
	diff -u expect5.out ${output}; \
	echo '      succeeded'; \
	\
	echo 'Test C #5.3'; \
	env \
	    classias2svmlight -h 2>&1 > /dev/null | awk '{print $$1; exit}' > ${output}; \
	diff -u expect6.out ${output}; \
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
	echo 'Test rb #5.1'; \
	env \
	    classias2svmlight.rb ${ds}/dataset.classias \
	    > ${output}; \
	diff -u expect5.out ${output}; \
	echo '      succeeded'


CLEANFILES +=	${output} ${output}.fmap ${output}.lmap class2id.txt token2id.txt
