#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <maa.h>
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

static char *label_map = NULL;
static int label_map_initializing = 1;

static char *feature_map_filename = NULL;
static char *label_map_filename = NULL;

static lst_List feature_names = NULL;
static lst_List label_names = NULL;

static int compar(const void *a, const void *b)
{
	const feature_t *fa = (const feature_t *) a;
	const feature_t *fb = (const feature_t *) b;
	if (fa->feature_id < fb->feature_id) return -1;
	if (fa->feature_id > fb->feature_id) return 1;
	return 0;
}

/*
static uint64_t hash_func(const char *str, size_t str_len)
{
	uint64_t h  = 0;
	size_t i;

	for (i = 0; i < str_len; ++i) {
		h += (uint8_t) str[i];
		h *= 2654435789U;		// prime near %$\frac{\sqrt{5}-1}{2}2^{32}$%
	}

	return h & 0xffffffff;
}
*/

static int get_uniq_id(char *str, size_t str_len, PPvoid_t hash, int *id)
{
	PWord_t ret = (PWord_t) JudyHSIns(hash, (void *)str, str_len, NULL);
//	PWord_t ret = (PWord_t) JudyLIns(hash, hash_func(str, str_len), NULL);
	if (ret == PJERR){
		fprintf(stderr, "Out of memory -- exit\n");
		exit(EXIT_FAILURE);
	}

//	fprintf(stderr, "str=%s str_len=%d id=%d\n", str, (int)str_len, *id);

	if (*ret == 0){
		*id += 1;
		*ret = *id;

		if (feature_names != NULL && hash == &features_hash){
			lst_append(feature_names, xstrdup(str));
		} else if (label_names != NULL && hash == &labels_hash){
			lst_append(label_names, xstrdup(str));
		}

		if (label_map != NULL && !label_map_initializing && hash == &labels_hash){
			fprintf(stderr, "Unknown label '%s', set HSVM_LABEL_MAP environment variable properly\n", strndup(str, str_len));
			exit(EXIT_FAILURE);
		}
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
   -h               display this screen\n\
   -l <num>         numeric value for the first label (usually 0 or 1),\n\
                    the default values is 0\n\
   -F <filename>    set the filename where to store\n\
                    feature name to integer map\n\
   -L <filename>    set the filename where to store\n\
                    label to integer map\n\
");
}

static int process_args(int argc, char **argv)
{
	int c;

	while (c = getopt (argc, argv, "hl:F:L:"), c != EOF){
		switch (c){
			case 'h':
				usage();
				exit(EXIT_SUCCESS);
			case 'l':
				label_id = atoi(optarg);
				break;
			case 'F':
				feature_map_filename = xstrdup(optarg);
				break;
			case 'L':
				label_map_filename = xstrdup(optarg);
				break;
			default:
				usage ();
				exit (EXIT_FAILURE);
		}
	}

	return optind;
}

static void init_label_map(void)
{
	size_t i;
	char *colon;
	char *end_of_digit = NULL;

	label_map = getenv("HSVM_LABEL_MAP");
	if (label_map == NULL)
		return;

	size_t len = strlen(label_map);
	for (i=0; i<len; ++i){
		switch (label_map[i]){
			case ' ':
			case '\t':
				label_map[i] = '\0';
		}
	}

	for (i=0; i<len; ++i){
		if ('\0' == label_map[i])
			continue;

		colon = strchr(label_map + i, ':');
		if (colon == NULL){
			fprintf(stderr, "Missing colon symbol in HSVM_LABEL_MAP environment variable\n");
			exit(EXIT_FAILURE);
		}
		*colon++ = '\0';

		long id = (int)strtol(colon, &end_of_digit, 10);
		if (*end_of_digit != '\0' || end_of_digit == colon){
			fprintf(stderr, "Incorrect numeric identifier within HSVM_LABEL_MAP environment variable\n");
			exit(EXIT_FAILURE);
		}
		id = get_uniq_id(label_map + i, strlen(label_map + i), &labels_hash, (int *)&id);

//		fprintf(stderr, "%s -> '%s'\n", label_map+i, colon);
//		fprintf(stderr, "%s -> '%d'\n", label_map+i, id);

		i = strchr(colon, 0) - label_map;
//		printf("i=%d\n", i);
	}
}

static void save_map(char *filename, Pvoid_t *hash, lst_List names, int real_id_offset)
{
	lst_Position p;
	char *name;
	FILE *fd;
	int ret;

	if (!names)
		return;

	fd = fopen(filename, "w");
	if (fd == NULL){
		perror("fopen(3) failed:");
		exit(1);
	}

	LST_ITERATE(names, p, name) {
		int id = get_uniq_id(name, strlen(name), hash, NULL);
		ret = fprintf(fd, "%s %d\n", name, id + real_id_offset);
		if (!ret){
			perror("fprintf(3) failed:");
			exit(1);
		}
	}

	ret = fclose(fd);
	if (ret){
		perror("fclose(3) failed:");
		exit(1);
	}
}

static void save_maps(void)
{
	save_map(feature_map_filename, &features_hash, feature_names, 1);
	save_map(label_map_filename, &labels_hash, label_names, 0);
}

static void init(void)
{
	if (feature_map_filename)
		feature_names = lst_create();
	if (label_map_filename)
		label_names = lst_create();
}

int main(int argc, char **argv)
{
	char msg[PATH_MAX + 100];
	FILE *fd;
	int i;
	int seen = process_args(argc, argv);
	argc -= seen;
	argv += seen;

	init();

	label_map_initializing = 1;
	init_label_map();
	label_map_initializing = 0;

	if (argc){
		for (i=0; i < argc; ++i){
			fd = fopen(argv[i], "rt");
			if (fd == NULL){
				snprintf(msg, sizeof(msg), "Cannot open file '%s'", argv[i]);
				perror(msg);
				exit(EXIT_FAILURE);
			}

			process_stream(fd);
			fclose(fd);
		}
	}else{
		process_stream(stdin);
	}
	save_maps();

	return 0;
}
