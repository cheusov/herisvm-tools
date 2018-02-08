ds = ${SRCDIR_datasets}
model = ${.OBJDIR}/model.model
predicts = ${.OBJDIR}/predicts.txt

test: all
test_output: .PHONY
	@set -e; \
	export PATH=`pwd`:$$PATH; \
	linear-train -q ${ds}/tiny_train.libsvm ${model}; \
	linear-predict -q ${ds}/tiny_predict.libsvm ${model} ${predicts}; \
	echo '======= test liblinear (tiny) ======='; \
	awk '{print $$1}' ${predicts}

CLEANFILES +=	${model} ${predicts}

.include <mkc.minitest.mk>
