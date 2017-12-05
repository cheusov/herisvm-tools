ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
predicts = ${.OBJDIR}/predicts.txt

test: all
test_output: .PHONY
	@set -e; \
	export PATH=`pwd`:$$PATH; \
	scikit_dt-train ${ds}/tiny_train.libsvm ${model}; \
	scikit_dt-predict ${ds}/tiny_predict.libsvm ${model} ${predicts}; \
	echo '======= test scikit_dt (tiny) ======='; \
	cat ${predicts}

CLEANFILES +=	${model} ${predicts}

.include <mkc.minitest.mk>
