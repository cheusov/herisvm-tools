#!/usr/bin/env groovy

@Grapes([
        @Grab(group = 'commons-io', module = 'commons-io', version = '2.4'),
        @Grab(group='commons-cli', module='commons-cli', version='1.2'),
        @Grab(group='com.google.re2j', module='re2j', version='1.0'),
        @Grab(group='org.apache.commons', module='commons-lang3', version='3.0'),
        @Grab(group='com.carrotsearch', module='hppc', version='0.6.1'),
        @Grab(group='fastutil', module='fastutil', version='5.0.9')
])

/**
 * Created by Aleksey Cheusov on 8/5/16.
 */
import com.carrotsearch.hppc.LongLongOpenHashMap
import com.google.re2j.Matcher
import com.google.re2j.Pattern
import org.apache.commons.cli.*
import org.apache.commons.io.FileUtils
import org.apache.commons.lang3.StringEscapeUtils
import it.unimi.dsi.fastutil.longs.Long2LongOpenHashMap

import java.nio.charset.StandardCharsets

/**
 * Created by Aleksey Cheusov on 8/5/16.
 */
class classias2svmlight {
    static private final Options options = new Options();

    static {
        options.addOption("h", false, "Display this screen");
        options.addOption("m", true, "use Map<String, Integer>");
        options.addOption("j", true, "use Map<Integer, Integer>");
    }

    static long hash_func(String str) {
//        long h  = 0;
//
//        for (char c : str) {
//            println("c: " + c);
//            println("h: " + h);
//            h += (int) c;
//            h = h * 2654435789d;		/* prime near %$\frac{\sqrt{5}-1}{2}2^{32}$% */
//        }
//
//        return h;
        return str.hashCode();
    }

    static private interface IStringsToUniqId {
        long getId(String str);
        void clear();
    }

    static private class StringsToUniqId implements IStringsToUniqId {
        private long count = 0;
        private Map<String, Integer> str2id = new HashMap<>();

        @Override
        long getId(String str) {
            Integer id = str2id.get(str);
            if (id == null) {
                id = ++count;
                str2id.put(str, id);
            }

            return id;
        }

        void clear() {
            count = 0;
            str2id.clear();
        }
    }

    static private class StringsToUniqIdHash implements IStringsToUniqId {
        private long count = 0;
        private Map<Long, Integer> long2id = new HashMap<>();

        @Override
        long getId(String str) {
            long h = hash_func(str);
            Integer id = long2id.get(h);
            if (id == null) {
                id = ++count;
                long2id.put(h, id);
            }

            return id;
        }

        void clear() {
            count = 0;
            long2id.clear();
        }
    }

    static private class StringsToUniqIdHppc implements IStringsToUniqId {
        private long count = 0;
        private LongLongOpenHashMap long2id = new LongLongOpenHashMap();

        @Override
        long getId(String str) {
            long h = hash_func(str);
            if (long2id.containsKey(h)) {
                return long2id.get(h);
            } else {
                long id = ++count;
                long2id.put(h, id);
                return id;
            }
        }

        void clear() {
            count = 0;
            long2id.clear();
        }
    }

    static private class StringsToUniqIdFastUtils implements IStringsToUniqId {
        private long count = 0;
        private Long2LongOpenHashMap long2id = new Long2LongOpenHashMap();

        @Override
        long getId(String str) {
            long h = hash_func(str);
            if (long2id.containsKey(h)) {
                return long2id.get(h);
            } else {
                long id = ++count;
                long2id.put(h, id);
                return id;
            }
        }

        void clear() {
            count = 0;
            long2id.clear();
        }
    }

    static private void processFile(String filename) {
        BufferedReader resultReader;
        IStringsToUniqId idGenerator = new StringsToUniqIdHppc();
//        IStringsToUniqId idGenerator = new StringsToUniqIdFastUtils();
//        IStringsToUniqId idGenerator = new StringsToUniqId();
//        IStringsToUniqId idGenerator = new StringsToUniqIdHash();

        try {
            resultReader = new BufferedReader(new FileReader(filename));
            String line;
//            StringBuilder sb = new StringBuilder();

            while ((line = resultReader.readLine()) != null) {
                line = line.replaceAll("  +", " ").trim();
                if (line.isEmpty())
                    continue;

                String[] tokens = line.split(" ");

                StringBuilder sb = new StringBuilder();

                sb.append(tokens[0]);
                sb.append(' ');

                int len = tokens.length;
                for (int i = 1; i < len; ++i) {
                    String token = tokens[i];

                    String feature = token;
                    String value = "1";

                    int lastColon = token.lastIndexOf(':');
                    if (lastColon != -1) {
                        feature = token.substring(0, lastColon);
                        value = token.substring(lastColon + 1);
                    }
//                    System.out.println(token + " " + feature + "/" + value);
//                    System.out.println(token + " " + idGenerator.getId(feature) + ":" + value);
//                    sb.append("10000");
                    sb.append(idGenerator.getId(feature));
                    sb.append(':');
                    sb.append(value);
                    if (i < len - 1)
                        sb.append(' ');
                }

                System.out.println(sb);
            }
        }
        catch (IOException e) {
            System.err.println(e.getStackTrace());
            System.exit(1);
        }
        finally {
            resultReader.close();
        }
    }

    static void main(String[] args) throws IOException {
        // handling options
        CommandLineParser parser = new PosixParser();
        CommandLine cmd = parser.parse(options, args);

        if (cmd.hasOption("h")) {
            new HelpFormatter().printHelp("classias2svmlight", options);
            System.exit(0);
        }

//        String multFields = cmd.getOptionValue("m");

        args = cmd.getArgs();
        for (String filename : args) {
            processFile(filename);
        }
//        IStringsToUniqId long2id = new StringsToUniqId();
//        println(long2id.getId("mama"));
//        println(long2id.getId("papa"));
//        println(long2id.getId("Aleksey"));
//        println(long2id.getId("Cheusov"));
//        println(long2id.getId("papa"));
//        println(long2id.getId("mama"));
    }
}
