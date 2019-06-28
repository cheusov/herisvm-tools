ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
output = ${.OBJDIR}/output.txt
libsvm_dataset = dataset.libsvm

test: all
	@set -e; \
	export TRAIN_CMD_OPTS='-- -q'; \
	export PREDICT_CMD_OPTS='-q'; \
	export PATH=${SRCDIR_classias2svmlight}:$$PATH; \
	export PATH=${.CURDIR}:${.OBJDIR}:$$PATH; \
	export SVM_TRAIN_CMD='linear-train -- -q -s 0'; \
	export SVM_PREDICT_CMD='linear-predict -q -b 1'; \
	\
	export PATH=`pwd`:$$PATH; \
	../helpers/run_test linear \
	    ${ds}/tiny_train.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #1' expect1.out; \
	echo '      succeeded'; \
	\
	../helpers/run_test linear \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #2' expect2.out; \
	echo '      succeeded'; \
	\
	classias2svmlight ${ds}/dataset.classias > ${libsvm_dataset}; \
	echo 'Test #3' 1>&2; \
	heri-eval -e ${libsvm_dataset} ${libsvm_dataset} > ${output:Q}; \
	a=`../helpers/get_accuracy ${output:Q}`; \
	../helpers/cmp_accuracy $$a 0.5; \
	echo '      succeeded'

CLEANFILES +=	${model} ${output} ${libsvm_dataset}
