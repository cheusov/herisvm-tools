ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
predicts = ${.OBJDIR}/predicts.txt

test: all
test_output: .PHONY
	@set -e; \
	export PATH=$$PATH:`pwd`; \
	scikit_linear-train ${ds}/tiny_train.libsvm ${model}; \
	scikit_linear-predict ${ds}/tiny_predict.libsvm ${model} ${predicts}; \
	echo '======= test scikit_linear (tiny) ======='; \
	cat ${predicts}

CLEANFILES +=	${model} ${predicts}

.include <mkc.minitest.mk>
