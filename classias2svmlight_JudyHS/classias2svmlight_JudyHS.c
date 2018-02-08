#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <Judy.h>

static Pvoid_t features_hash = NULL;
static int feature_id = 0;

static Pvoid_t labels_hash = NULL;
static int label_id = 0;

typedef struct {
	int feature_id;
	const char *feature_value;
} feature_t;

static feature_t *features = NULL;
static int features_count = 0;
static int features_array_size = 0;

static int compar(const void *a, const void *b)
{
	const feature_t *fa = (const feature_t *) a;
	const feature_t *fb = (const feature_t *) b;
	if (fa->feature_id < fb->feature_id) return -1;
	if (fa->feature_id > fb->feature_id) return 1;
	return 0;
}

static uint64_t hash_func(const char *str, size_t str_len)
{
	uint64_t h  = 0;
	size_t i;

	for (i = 0; i < str_len; ++i) {
		h += (uint8_t) str[i];
		h *= 2654435789U;		/* prime near %$\frac{\sqrt{5}-1}{2}2^{32}$% */
	}

	return h & 0xffffffff;
}

static int get_uniq_id(const char *str, size_t str_len, PPvoid_t hash, int *id)
{
	PWord_t ret = (PWord_t) JudyHSIns(hash, (void *)str, str_len, NULL);
//	PWord_t ret = (PWord_t) JudyLIns(hash, hash_func(str, str_len), NULL);
	if (ret == PJERR){
		fprintf(stderr, "Out of memory -- exit\n");
		exit(1);
	}

	if (*ret == 0){
		*id += 1;
		*ret = *id;
	}

	return *ret - 1;
}

static void parse_feature_line(char *line)
{
	int i;

	features_count = 0;

	while (*line == ' ' || *line == '\t') // skip leading spaces
		++line;

	char *lbl = line;
	while (*line != ' ' && *line != '\t' && *line != '\0') // skip label symbols
		++line;
	*line = '\0';
	++line;
	int lbl_id = get_uniq_id(lbl, strlen(lbl), &labels_hash, &label_id);
//	printf("label=`%s` label_id=%d\n", lbl, lbl_id);

	while (*line == ' ' || *line == '\t') // skip spaces after label
		++line;

	while (*line){
//		printf("line=`%s`\n", line);
		char *feature_name = line;
		// skip feature name symbols until colon or space character
		while (*line != ':' && *line != ' ' && *line != '\t' && *line != '\0')
			++line;

		// 
		const char *feature_value = "1";
		if (*line == ':'){
			*line = '\0';
			++line;
			feature_value = line;
			while (*line != ' ' && *line != '\t' && *line != '\0') // skip feature label symbols
				++line;
		}

		int exitnow = (*line == '\0');

		*line = '\0';
		int new_id = get_uniq_id(feature_name, strlen(feature_name), &features_hash, &feature_id);
//		printf("f=%s  v=%s f_id=%d\n", feature_name, feature_value, new_id);

		if (features_count >= features_array_size){
			if (features_array_size == 0)
				features_array_size = 256;
			else
				features_array_size *= 2;

			features = (feature_t*) realloc(
				features, features_array_size * sizeof(features[0]));
		}
		feature_t *feature = features + features_count;
		feature->feature_id = new_id + 1;
		feature->feature_value = feature_value;

		++features_count;

		if (!exitnow){
			++line;
			while (*line == ' ' || *line == '\t') // skip feature:value
				++line;
		}
	}

	qsort(features, features_count, sizeof(feature_t), compar);

	printf("%d", lbl_id);
	for (i = 0; i < features_count; ++i){
		printf(" %d:%s", features[i].feature_id, features[i].feature_value);
	}
	printf("\n");
}

static void process_stream(FILE *stream)
{
	ssize_t len;
	char *line = NULL;
	size_t n = 0;

//	Word_t freed_mem = 0;

	while ((len = getline(&line, &n, stream)) != -1){
		if (len > 0){
			line[len-1] = 0;
		}

//		printf("line=`%s`\n", line);
		parse_feature_line(line);
	}

//	JHSFA(freed_mem, features_hash);
//	printf("JudyHSFreeArray() free'ed %lu bytes of memory\n", (unsigned long)freed_mem);
}

static void usage (void)
{
	fprintf(stderr, "\
classias2svmlight programs converts dataset in classias format\n\
   to svmlight format.\n\
Usage: classias2svmlight [OPTIONS] [files...]\n\
OPTIONS:\n\
   -h      dislay this screen\
");
}

static int process_args(int argc, char **argv)
{
	int c;

	while (c = getopt (argc, argv, "h"), c != EOF){
		switch (c){
			case 'h':
				usage();
				exit(0);;
			default:
				usage ();
				exit (1);
		}
	}

	return optind;
}

int main(int argc, char **argv)
{
	int seen = process_args(argc, argv);
	argc -= seen;
	argv += seen;

	process_stream(stdin);

	return 0;
}
