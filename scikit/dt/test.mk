ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
output = ${.OBJDIR}/output.txt

test: all
	@set -e; \
	\
	export PATH=`pwd`:$$PATH; \
	../../helpers/run_test scikit_dt \
	    ${ds}/tiny_train.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} expect1.out \
	    'Test #1'; \
	echo '      succeeded'; \
	\
	../../helpers/run_test scikit_dt \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} expect2.out \
	    'Test #2'; \
	echo '      succeeded'

CLEANFILES +=	${model} ${output}
