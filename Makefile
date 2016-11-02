PROJECTNAME =	herisvm-tools

subprojects = scikit liblinear classias vowpal_wabbit jliblinear jsvm \
  svmlight_tools

SUBPRJ = ${subprojects:S/$/:scripts/} doc scripts:tests

MKC_REQD    =	0.29.1

NODEPS      =	*:test-tests

test : all-tests test-tests
	@:

.include <mkc.mk>
