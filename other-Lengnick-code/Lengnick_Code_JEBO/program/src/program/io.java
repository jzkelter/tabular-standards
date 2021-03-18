package program;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class io {

    String Folder = "results_more_Agents";

    // For File Buffer
    PrintWriter OutputFile;
    String Content_Buffer;

    void Set_Folder(String Fold){
        Folder = Fold;
    }

    public void WriteToFile(String Filename, String Content, boolean Append){
        //Append=1 -> append at end of file, =0 -> create new file

        //Create Folder if it does not exist
        File myPath = new File(Folder);
        if (!myPath.isDirectory()) {
            myPath.mkdirs();
        }

        try {
            FileWriter outFile = new FileWriter(Folder + System.getProperty("file.separator") + Filename, Append);
            PrintWriter out = new PrintWriter(outFile);
            out.print(Content);
            out.close();

        } catch (IOException e){
            e.printStackTrace();
        }

        //Make pause if the file was newly created
        if (Append) {try{Thread.sleep(1);}catch(Exception e){}}
    }

    public void deleteFile(String Folder, String Filename) {
        File f = new File(Folder + System.getProperty("file.separator") + Filename);
        boolean success = f.delete();
    }

    public void copyFile(String src_, String dest_, int bufSize, boolean force) {

        File src = new File(src_);
        File dest = new File(dest_);

        if(dest.exists()) {
            if(force) {
                dest.delete();
            }
        }
        byte[] buffer = new byte[bufSize];
        int read = 0;
        InputStream in = null;
        OutputStream out = null;
        try {
            in = new FileInputStream(src);
            out = new FileOutputStream(dest);
            while(true) {
                read = in.read(buffer);
                if (read == -1) {
                    //-1 bedeutet EOF
                    break;
                }
                out.write(buffer, 0, read);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (Exception e) {
                    System.out.println(e.getMessage());
                } finally {
                    if (out != null) {
                        try {
                            out.close();
                        } catch (Exception e) {
                            System.out.println(e.getMessage());
                        }
                    }
                }
            }
        }
    }

    void Open_File_For_Writing(String Filename, boolean Append) {
        //Append=1 -> append at end of file, =0 -> create new file

        //Create Folder if it does not exist
        File myPath = new File(Folder);
        if (!myPath.isDirectory()) {
            myPath.mkdirs();
        }


        try {
            FileWriter outFile = new FileWriter(Folder + System.getProperty("file.separator") + Filename, Append);
            OutputFile = new PrintWriter(outFile);
        } catch (IOException e){
            e.printStackTrace();
        }

        Content_Buffer = "";
    }

    void Write_To_Open_File(String Content) {
        Content_Buffer = Content_Buffer + Content;
        if (Content_Buffer.length() > 500) {
            OutputFile.print(Content_Buffer);
            Content_Buffer = "";
        }
    }

    void Close_Open_File() {
        OutputFile.print(Content_Buffer);
        Content_Buffer = "";
        OutputFile.close();
    }


    String Get_Folder() {
        return Folder;
    }




}
