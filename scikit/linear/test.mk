ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
output = ${.OBJDIR}/output.txt
libsvm_dataset = libsvm_dataset

test: all
	@set -e; \
	export PATH=${SRCDIR_classias2svmlight}:$$PATH; \
	export PATH=${SRCDIR_predict}:${OBJDIR_predict}:$$PATH; \
	export PATH=${.CURDIR}:${.OBJDIR}:$$PATH; \
	../../helpers/run_test scikit_linear \
	    ${ds}/tiny_train.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #1' expect1.out; \
	echo '      succeeded'; \
	\
	../../helpers/run_test scikit_linear \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} \
	    'Test #2' expect2.out; \
	echo '      succeeded'; \
	\
	classias2svmlight ${ds}/dataset.classias > ${libsvm_dataset}; \
	\
	echo 'Test #3.1' 1>&2; \
	export SVM_TRAIN_CMD='scikit_linear-train --random_state 2 -c 1 --loss hinge --penalty l2 --multi_class ovr'; \
	export SVM_PREDICT_CMD='scikit_linear-predict'; \
	heri-eval -e ${libsvm_dataset} ${libsvm_dataset} > ${output:Q}; \
	a=`../../helpers/get_accuracy ${output:Q}`; \
	../../helpers/cmp_accuracy $$a 0.25; \
	echo '      succeeded'; \
	\
	echo 'Test #3.2' 1>&2; \
	export SVM_TRAIN_CMD='scikit_linear-train --random_state 2'; \
	export SVM_PREDICT_CMD='scikit_linear-predict'; \
	heri-eval -e ${libsvm_dataset} ${libsvm_dataset} > ${output:Q}; \
	a=`../../helpers/get_accuracy ${output:Q}`; \
	../../helpers/cmp_accuracy $$a 0.25; \
	echo '      succeeded'; \
	\
	echo 'Test #3.3' 1>&2; \
	export SVM_TRAIN_CMD='scikit_linear-train --random_state 2 --max_iter 10000'; \
	export SVM_PREDICT_CMD='scikit_linear-predict'; \
	heri-eval -e ${libsvm_dataset} ${libsvm_dataset} > ${output:Q}; \
	a=`../../helpers/get_accuracy ${output:Q}`; \
	../../helpers/cmp_accuracy $$a 0.25; \
	echo '      succeeded'

CLEANFILES +=	${model} ${output} ${libsvm_dataset}
