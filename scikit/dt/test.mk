ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
output = ${.OBJDIR}/output.txt

test: all
	@set -e; \
	\
	export PATH=`pwd`:${.OBJDIR}:$$PATH; \
	../../helpers/run_test scikit_dt \
	    ${ds}/tiny_train.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} expect1.out \
	    'Test #1'; \
	echo '      succeeded'; \
	\
	../../helpers/run_test scikit_dt \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} expect2.out \
	    'Test #2.1'; \
	echo '      succeeded'; \
	\
	../../helpers/run_test --criterion=gini --splitter=best \
	    --max_depth=None --min_samples_split=2 --min_samples_leaf=1 \
	    --min_weight_fraction_leaf=0.0 --max_features=None \
	    --random_state=100500 --max_leaf_nodes=None \
	    --min_impurity_decrease=0.0 --min_impurity_split=None \
	    --class_weight=None \
	    scikit_dt \
	    ${ds}/tiny_train2.libsvm ${ds}/tiny_predict.libsvm \
	    ${model:Q} ${output:Q} expect2.out \
	    'Test #2.2'; \
	echo '      succeeded'

CLEANFILES +=	${model} ${output}
