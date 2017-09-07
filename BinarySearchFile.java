package com.file;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.StopWatch;

public class FileThread extends Thread
{
    
    
    
    public FileThread(String threadName)
    {
        super(threadName);
    }
    
    public void run()
    {
        
    }
    
    /**
     * Find the position of the start of the first line in the file that is
     * greater than or equal to the target line, using a binary search.
     * 
     * @param file
     *            the file to search.
     * @param target
     *            the target to find.
     * @return the position of the first line that is greater than or equal to
     *         the target line.
     * @throws IOException
     */
    public static long search(RandomAccessFile file, String target)
            throws IOException {
        /*
         * because we read the second line after each seek there is no way the
         * binary search will find the first line, so check it first.
         */
        file.seek(0);
        String line = file.readLine();

/*        // skip empty line
        while (StringUtils.isBlank(line)){
            long pos = file.getFilePointer();
            System.out.println("[POS] ----> " + Long.toString(pos));
            line = file.readLine();
        }
        
        System.out.println("Line ----> " + line);*/
        
        if (line == null || compare(line, target) >= 0) {
            /*
             * the start is greater than or equal to the target, so it is what
             * we are looking for.
             */
            return 0;
        }

        /*
         * set up the binary search.
         */
        long beg = 0;
        long end = file.length();
        while (beg <= end) {
            /*
             * find the mid point.
             */
            long mid = beg + (end - beg) / 2;
            file.seek(mid);
            file.readLine();
            line = file.readLine();

            if (line == null || compare(line, target) >= 0 ) {
                System.out.println("Line -> " + line);
                
                /*
                 * what we found is greater than or equal to the target, so look
                 * before it.
                 */
                System.out.println("end ----> " + Long.toString(end));
                end = mid - 1;
                
            } else {
                System.out.println("Line -> " + line);
                
                /*
                 * otherwise, look after it.
                 */
                beg = mid + 1;
                
                System.out.println("beg ----> " + Long.toString(beg));
            }
        }

        /*
         * The search falls through when the range is narrowed to nothing.
         */
        file.seek(beg);
        file.readLine();
        
        long pointer = file.getFilePointer();
        
        System.out.println(pointer);
        
        return file.getFilePointer();
    }
    
    public static int compare(String source, String target){
        int result = -1;
        
        if (source == null || target == null){
            throw new IllegalArgumentException();
        }
        
        Long sourceNum = Long.parseLong(source);
        Long targetNum = Long.parseLong(target);
        
        return sourceNum.compareTo(targetNum); 
    }
    
    public static void generateFile(){
        long MAX = 9;
        Path path = Paths.get("D:","temp", "file", "data.txt");
        
        try {
            if (Files.exists(path)){
                Files.delete(path);
            }else{
                Path parentDir = path.getParent();
                if (!Files.exists(parentDir)){
                    Files.createDirectory(parentDir);
                }
            }
            Files.createFile(path);
        
            BufferedWriter writer = Files.newBufferedWriter(path, StandardCharsets.ISO_8859_1);
            for (long i=1; i<=MAX; i++){
                writer.write(Long.toString(i));
                writer.newLine();
            }
            writer.flush();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }
    
    public static void searchFile(String target){
        Path path = Paths.get("D:","temp", "file", "data.txt");
        
        StopWatch watch = new StopWatch();
        watch.start();
        
        try {
            if (Files.exists(path)){
                
                watch.split();
                System.out.println(watch.getSplitTime());
                
                List<String> lines = Files.readAllLines(path);
                
                watch.split();
                System.out.println(watch.getSplitTime());
                
                for (String line : lines){
                    if ( line.equalsIgnoreCase(target) ){
                        
                        watch.stop();
                        System.out.println(watch.getTime());
                        
                        break;
                    }
                }
            }
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }    
    
    public static void main(String[] args)
    {
        //generateFile();
        //searchFile("98764");
        
//        StopWatch watch = new StopWatch();
//        watch.start();
        
        try
        {
            search(new RandomAccessFile(Paths.get("D:","temp", "file", "data.txt").toFile(), "r"), "2");
            
//            watch.stop();
//            System.out.println(watch.getTime());
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }
}
