PROJECTNAME =	herisvm-tools

subprojects = scikit liblinear classias vowpal_wabbit jliblinear jsvm \
  svmlight_tools bagging curves datasets

subprojects += scikit/linear:scikit scikit/dt:scikit scikit/rf:scikit

SUBPRJ = ${subprojects} doc scripts

MKC_REQD    =	0.29.1

.include <mkc.mk>
