ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
output = ${.OBJDIR}/output.txt

test: all
	@set -e; \
	\
	export PATH=`pwd`:$$PATH; \
	../../helpers/run_test scikit_rf \
	    ${ds}/tiny_train.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #1' expect1.out; \
	echo '      succeeded'; \
	\
	../../helpers/run_test scikit_rf \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #2' expect2.out; \
	echo '      succeeded'

CLEANFILES +=	${model} ${output}
