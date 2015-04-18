part of targets_cli;

/// Useful utility methods and classes used by the Targets CLI

List<File> getFilesWithExtension(String extension){
    List<File> files = allFilesInDirectory(new Directory(wd));
    List<File> goodFiles = [];
    for(File f in files){
        if(f.path.endsWith(extension)) goodFiles.add(f);
    }
    return goodFiles;
}

List<File> allFilesInDirectory(Directory dir){
    List<File> files = [];
    if(dir.path==wd+Platform.pathSeparator+"targets") return files;
    var directs = dir.listSync();
    for(var dir in directs){
        if(dir is Directory){
            files.addAll(allFilesInDirectory(dir));
        }else{
            files.add(dir);
        }
    }
    return files;
}

copyDirectory(Directory from, Directory to){
    var ps = Platform.pathSeparator;
    if(!from.existsSync()) return;
    if(!to.existsSync()) to.createSync();
    for(var item in from.listSync()){
        if(item is Directory){
            copyDirectory(item, new Directory(to.path+ps+item.path.split(ps).last));
        }else if(item is File){
            item.copySync(to.path+ps+item.path.split(ps).last);
        }
    }
}
 
openBrowser(url){
    print("Results at: $url");
    if(Platform.isMacOS){
        Process.start('open', [url]);
    }else if(Platform.isLinux){
        Process.start('x-www-browser', [url]);
    }else if(Platform.isWindows){
        Process.start('explorer', [url]);
    }
}

const String PLAIN = "plain";
const String GREEN = "green";
const String RED = "red";
const String BLUE = "blue";

/// Let's us print with colors if we're on Unix
/// Also lets us rebind print to redirect output
Function print = (String str, [String type=PLAIN]){
    if(type==PLAIN||Platform.isWindows){
        stdout.writeln(str);
    }else if(type==RED){
        stdout.writeln("\u001b[0;31m"+str+"\u001b[0;0m");
    }else if(type==GREEN){
        stdout.writeln("\u001b[0;32m"+str+"\u001b[0;0m");
    }else if(type==BLUE){
        stdout.writeln("\u001b[0;36m"+str+"\u001b[0;0m");
    }
};

String prompt(String str, [String type=PLAIN]){
    if(type==PLAIN||Platform.isWindows){
        stdout.write(str);
    }else if(type==RED){
        stdout.write("\u001b[0;31m"+str+"\u001b[0;0m ");
    }else if(type==GREEN){
        stdout.write("\u001b[0;32m"+str+"\u001b[0;0m ");
    }else if(type==BLUE){
        stdout.write("\u001b[0;36m"+str+"\u001b[0;0m ");
    }
    return stdin.readLineSync();
}

/**
 * Customized version of Base64 that replaces / with ^ so that it can
 * be included in a URL
 */
class Base64 {
    static const List<String> _encodingTable = const [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
      'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
      't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
      '8', '9', '+', '^'];
 
    static String encode(String income ) {
    
        List<int> data = income.codeUnits;
        
        List<String> characters = new List<String>();
        int i;
        for (i = 0; i + 3 <= data.length; i += 3) {
            int value = 0;
            value |= data[i + 2];
            value |= data[i + 1] << 8;
            value |= data[i] << 16;
            for (int j = 0; j < 4; j++) {
                int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
                characters.add(_encodingTable[index]);
            }
        }
        // Remainders.
        if (i + 2 == data.length) {
            int value = 0;
            value |= data[i + 1] << 8;
            value |= data[i] << 16;
            for (int j = 0; j < 3; j++) {
                int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
                characters.add(_encodingTable[index]);
            }
            //characters.add("=");
        } else if (i + 1 == data.length) {
            int value = 0;
            value |= data[i] << 16;
            for (int j = 0; j < 2; j++) {
                int index = (value >> ((3 - j) * 6)) & ((1 << 6) - 1);
                characters.add(_encodingTable[index]);
            }
            //characters.add("=");
            //characters.add("=");
        }
        StringBuffer output = new StringBuffer();
        for (i = 0; i < characters.length; i++) {
            if (i > 0 && i % 76 == 0) {
                output.write("\r\n");
            }
            output.write(characters[i]);
        }
        return output.toString();
  }
}