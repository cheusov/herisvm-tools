ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
predicts = ${.OBJDIR}/predicts.txt

test: all
test_output: .PHONY
	@set -e; \
	export PATH=`pwd`:$$PATH; \
	scikit_rf-train ${ds}/tiny_train.libsvm ${model}; \
	scikit_rf-predict ${ds}/tiny_predict.libsvm ${model} ${predicts}; \
	echo '======= test scikit_rf (tiny) ======='; \
	awk '{print $$1}' ${predicts}

CLEANFILES +=	${model} ${predicts}

.include <mkc.minitest.mk>
